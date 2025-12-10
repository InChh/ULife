//
//  ForumDetailViewController.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//  帖子详情页

// Controller/ForumDetailViewController.swift
import UIKit

class ForumDetailViewController: UIViewController {

    // 视图属性
    private var detailView: ForumDetailView {
        return self.view as! ForumDetailView
    }

    // 接收从上一个 Controller 传入的帖子数据（必须初始化传入）
    private let post: ForumPost

    private var comments: [Comment] = []  // 评论数据源
    // 已点赞的评论、回复 ID 集合（仅前端状态）
    private var likedCommentIDs: Set<String> = []
    private var likedReplyIDs: Set<String> = []
    private var isPostLiked: Bool  //是否点赞

    private var iscollected: Bool  //是否收藏

    init(post: ForumPost) {
        self.post = post
        isPostLiked = post.isLiked
        iscollected = post.isreplyed
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // 将自定义 View 加载为 Controller 的主视图
        self.view = ForumDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()

        setupBindings()
        // 初始数据绑定
        configurePostDetails()

        // 加载评论数据 (模拟 API 调用)
        fetchComments()

        // 更新点赞按钮状态
        updateLikeButtonState()
        updatecollectedButtonState()
    }

    private func setupViews() {
        // 1. 设置代理
        detailView.commentTableView.delegate = self
        detailView.commentTableView.dataSource = self
    }

    //绑定事件
    private func setupBindings() {
        // 2. 绑定交互事件
        detailView.likeButton.addTarget(
            self,
            action: #selector(handleLikeTap),
            for: .touchUpInside
        )
        detailView.CollectButton.addTarget(
            self,
            action: #selector(handleDislikeTap),
            for: .touchUpInside
        )
        detailView.commentButton.addTarget(
            self,
            action: #selector(handleCommentTap),
            for: .touchUpInside
        )
        detailView.reportButton.addTarget(
            self,
            action: #selector(handleReportTap),
            for: .touchUpInside
        )
    }

    // MARK: - Data Configuration

    private func configurePostDetails() {
        // 将帖子数据绑定到 View 的各个 Label 上
        detailView.titleLabel.text = post.title
        detailView.authorNameLabel.text = post.authorName
        detailView.contentBodyLabel.text = post.content

        // 标签展示：将 tags 数组渲染为 #tag 样式
        if post.tags.isEmpty {
            detailView.tagsLabel.text = nil
        } else {
            let displayTags = post.tags.map { tag in
                tag.hasPrefix("#") ? tag : "#\(tag)"
            }.joined(separator: "  ")
            detailView.tagsLabel.text = "\(displayTags)"
        }

        // 格式化日期
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        detailView.createTimeLabel.text = formatter.string(
            from: post.publishTime
        )

        // 假设这里会使用你的图片加载库加载 post.authorAvatar
        // detailView.authorAvatar.kf.setImage(with: URL(string: post.authorAvatar))
    }

    private func fetchComments() {
        // MARK: - ⚠️ 模拟 API 调用
        // 实际开发中，这里应该调用你的 NetworkManager 来请求 API
        // 例如：NetworkManager.shared.fetchComments(for: post.id) { result in ... }

        // 假设成功获取评论数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.comments = MockCommentData.comments

            // 更新评论区标题和 TableView
            self.detailView.commentHeaderLabel.text =
                "评论 (\(self.comments.count))"
            self.detailView.commentTableView.reloadData()

            // 关键：在 TableView 重新加载数据后，需要通知 ScrollView 更新内容高度
            self.updateTableViewHeight()
        }
    }

    // 关键：动态调整 TableView 高度，解决 ScrollView 嵌套 TableView 的问题
    private func updateTableViewHeight() {
        // 使用 DispatchQueue.main.async 确保在 TableView 渲染完成后计算高度
        DispatchQueue.main.async {
            let height = self.detailView.commentTableView.contentSize.height

            // 找到 TableView 的高度约束并更新，如果没找到则创建
            if let heightConstraint = self.detailView.commentTableView
                .constraints.first(where: { $0.firstAttribute == .height })
            {
                heightConstraint.constant = height
            } else {
                let heightConstraint = self.detailView.commentTableView
                    .heightAnchor.constraint(equalToConstant: height)
                heightConstraint.isActive = true
            }

            // 强制 View 重新布局
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - UI Interaction

    //点赞
    @objc private func handleLikeTap() {
        // 切换点赞状态
        isPostLiked.toggle()

        // 仅在前端更新状态
        updateLikeButtonState()

        // 成功调用 API 后，你应该更新 post.likeCount 并通知列表页刷新
    }

    //踩
    @objc private func handleDislikeTap() {
        // 切换点赞状态
        iscollected.toggle()

        // 仅在前端更新状态
        updatecollectedButtonState()

        // 成功调用 API 后，你应该更新 post.likeCount 并通知列表页刷新
    }

    //举报
    @objc private func handleReportTap() {
        let alert = UIAlertController(
            title: "举报内容",
            message: "请选择举报理由",
            preferredStyle: .actionSheet
        )

        let reasons = ["垃圾广告", "不友善内容", "违法违规"]
        for reason in reasons {
            alert.addAction(
                UIAlertAction(
                    title: reason,
                    style: .default,
                    handler: { _ in
                        // TODO: 发送举报请求到服务器
                        print("举报理由: \(reason)")

                        Toast.show("举报成功", style: .normal)
                    }
                )
            )
        }
        alert.addAction(
            UIAlertAction(
                title: "其他",
                style: .default,
                handler: { _ in
                    self.showOtherReportInput()
                }
            )
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    private func showOtherReportInput() {
        let inputAlert = UIAlertController(
            title: "举报详情",
            message: "请填写具体的举报原因",
            preferredStyle: .alert
        )

        // 添加输入框
        inputAlert.addTextField { textField in
            textField.placeholder = "请输入详细理由..."
            textField.returnKeyType = .done
        }

        // 确认按钮
        let submitAction = UIAlertAction(title: "提交", style: .default) { _ in
            // 获取输入框的内容
            guard let text = inputAlert.textFields?.first?.text, !text.isEmpty
            else {
                // 如果用户没填，可以提示或者直接当作"其他"处理
                print("举报理由: 其他,用户未填写详情")
                return
            }
            // 提交带详情的举报
            print("举报理由: 其他\(text)")

            Toast.show("举报成功", style: .normal)
        }

        // 取消按钮
        inputAlert.addAction(UIAlertAction(title: "取消", style: .cancel))
        inputAlert.addAction(submitAction)

        present(inputAlert, animated: true)
    }

    //评论
    @objc private func handleCommentTap() {
        // 弹出评论输入框
        let alert = UIAlertController(
            title: "发表评论",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "友善评论，传递温暖..."
            textField.returnKeyType = .done  //将键盘右下角的“换行键”（Return Key）的样式和功能设置为 Done（完成）
        }

        let sendAction = UIAlertAction(
            title: "发送",
            style: .default,
            handler: { [weak self] _ in
                guard
                    let self = self,
                    let text = alert.textFields?.first?.text?
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                    !text.isEmpty
                else {
                    Toast.show("评论内容不能为空", style: .error)
                    return
                }

                // 创建本地评论对象（实际项目中应调用后端接口）
                let newComment = Comment(
                    id: UUID().uuidString,
                    authorName: "我",
                    authorAvatar: "",
                    content: text,
                    createTime: Date(),
                    likeCount: 0,
                    replies: nil
                )

                self.insertNewComment(newComment)
            }
        )

        let cancelAction = UIAlertAction(title: "取消", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(sendAction)

        present(alert, animated: true)
    }

    /// 将一条新的一级评论插入到列表顶部，并刷新 UI 点击按钮评论后为帖子添加评论
    private func insertNewComment(_ comment: Comment) {
        comments.insert(comment, at: 0)
        detailView.commentHeaderLabel.text = "评论 (\(comments.count))"
        detailView.commentTableView.reloadData()
        updateTableViewHeight()  //更新 tabelview 的高度
    }

    /// 统一弹出“回复评论/回复”的输入框
    private func presentReplyAlert(
        commentIndex: Int,
        replyingToName: String?
    ) {
        let title: String = {
            if let name = replyingToName {
                return "回复 \(name)"
            } else {
                return "回复评论"
            }
        }()

        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "友善回复，传递温暖..."
            textField.returnKeyType = .done
        }

        let sendAction = UIAlertAction(
            title: "发送",
            style: .default,
            handler: { [weak self] _ in
                //校验数据
                guard
                    let self = self,
                    commentIndex < self.comments.count,
                    let text = alert.textFields?.first?.text?
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                    !text.isEmpty
                else {
                    Toast.show("回复内容不能为空", style: .error)
                    return
                }

                //获取回复的评论和回复
                var comment = self.comments[commentIndex]
                var existingReplies = comment.replies ?? []

                let reply = CommentReply(
                    id: UUID().uuidString,
                    authorName: "我",
                    repliedToUser: replyingToName,
                    content: text,
                    createTime: Date(),
                    likeCount: 0
                )
                existingReplies.append(reply)

                // 生成带有新 replies 的 Comment（因为 Comment 各字段是 let）
                let updated = Comment(
                    id: comment.id,
                    authorName: comment.authorName,
                    authorAvatar: comment.authorAvatar,
                    content: comment.content,
                    createTime: comment.createTime,
                    likeCount: comment.likeCount,
                    replies: existingReplies
                )

                self.comments[commentIndex] = updated
                self.detailView.commentTableView.reloadData()  //刷新数据
                self.updateTableViewHeight()  //更新高度
            }
        )

        let cancelAction = UIAlertAction(title: "取消", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(sendAction)

        present(alert, animated: true)
    }

    // 更新点赞按钮的 UI 样式
    private func updateLikeButtonState() {
        let systemName = isPostLiked ? "hand.thumbsup.fill" : "hand.thumbsup"

        let color: UIColor = isPostLiked ? .systemRed : .label
        let text = isPostLiked ? "\(post.likeCount + 1)" : "点赞"  // 或显示具体数字

        // 获取当前的配置进行修改
        var config = detailView.likeButton.configuration
        config?.image = UIImage(systemName: systemName)
        config?.baseForegroundColor = color  // 控制图片和文字颜色

        // 更新文字 (保留字体设置)
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config?.attributedTitle = AttributedString(
            text,
            attributes: titleContainer
        )

        // 重新赋值回去
        detailView.likeButton.configuration = config
    }

    private func updatecollectedButtonState() {
        let systemName = iscollected ? "star.fill" : "star"

        let color: UIColor = iscollected ? .systemRed : .label
        let text = iscollected ? "\(post.replyCount + 1)" : "收藏"  // 或显示具体数字

        // 获取当前的配置进行修改
        var config = detailView.CollectButton.configuration
        config?.image = UIImage(systemName: systemName)
        config?.baseForegroundColor = color  // 控制图片和文字颜色

        // 更新文字 (保留字体设置)
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config?.attributedTitle = AttributedString(
            text,
            attributes: titleContainer
        )

        // 重新赋值回去
        detailView.CollectButton.configuration = config
    }

    // MARK: - 评论 & 回复点赞逻辑

    /// 切换某条评论的点赞状态
    private func toggleCommentLike(at index: Int) {
        guard comments.indices.contains(index) else { return }
        let comment = comments[index]
        if likedCommentIDs.contains(comment.id) {
            likedCommentIDs.remove(comment.id)
        } else {
            likedCommentIDs.insert(comment.id)
        }

        let indexPath = IndexPath(row: index, section: 0)
        detailView.commentTableView.reloadRows(at: [indexPath], with: .none)
        updateTableViewHeight()
    }

    /// 切换某条回复的点赞状态
    private func toggleReplyLike(_ reply: CommentReply, inCommentAt index: Int)
    {
        guard comments.indices.contains(index) else { return }

        if likedReplyIDs.contains(reply.id) {
            likedReplyIDs.remove(reply.id)
        } else {
            likedReplyIDs.insert(reply.id)
        }

        let indexPath = IndexPath(row: index, section: 0)
        detailView.commentTableView.reloadRows(at: [indexPath], with: .none)
        updateTableViewHeight()
    }

    private func CommentReplyOrDelete(_ commentIndex: Int) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "回复",
                style: .default,
                handler: { _ in
                    self.presentReplyAlert(
                        commentIndex: commentIndex,
                        replyingToName: nil
                    )
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: "删除",
                style: .destructive,
                handler: { _ in
                    self.comments.remove(at: commentIndex)
                    self.detailView.commentHeaderLabel.text =
                        "评论 (\(self.comments.count))"
                    self.detailView.commentTableView.reloadData()
                    self.updateTableViewHeight()
                    Toast.show("删除成功", style: .normal)
                }
            )
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    private func ReplyReplyOrDelete(_ commentIndex: Int, _ reply: CommentReply)
    {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "回复", style: .default) { [weak self] _ in
                self?.presentReplyAlert(
                    commentIndex: commentIndex,
                    replyingToName: reply.authorName
                )
            }
        )

        alert.addAction(
            UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
                guard
                    let self = self,
                    self.comments.indices.contains(commentIndex),
                    var replies = self.comments[commentIndex].replies,  // 取出原来的数组
                    let idx = replies.firstIndex(of: reply)  // 找到要删的那条
                else { return }

                // 从本地数组删除
                replies.remove(at: idx)
                // 写回到数据源
                self.comments[commentIndex].replies = replies

                // 刷新列表和高度
                self.detailView.commentTableView.reloadData()
                self.updateTableViewHeight()
                Toast.show("删除成功", style: .normal)
            }
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource (评论列表)

extension ForumDetailViewController: UITableViewDelegate, UITableViewDataSource
{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        // 确保是我们的评论 TableView
        if tableView == detailView.commentTableView {
            return comments.count
        }
        return 0
    }

    //初始化tabelview 中每个 cell 设置点击方法
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentCell.identifier,
                for: indexPath
            ) as? CommentCell
        else {
            return UITableViewCell()
        }

        let comment = comments[indexPath.row]
        let isLiked = likedCommentIDs.contains(comment.id)
        cell.configure(
            with: comment,
            isLiked: isLiked,
            likedReplyIDs: likedReplyIDs
        )

        //判断是否为自己的评论
        if true {
            cell.onCommentTap = { [weak self] in
                self?.CommentReplyOrDelete(indexPath.row)
            }
        } else {
            // 点击整条评论：回复该评论
            cell.onCommentTap = { [weak self] in
                self?.presentReplyAlert(
                    commentIndex: indexPath.row,
                    replyingToName: nil
                )
            }
        }

        // 点赞整条评论
        cell.onCommentLikeTap = { [weak self] in
            self?.toggleCommentLike(at: indexPath.row)
        }

        if true {
            cell.onReplyTap = { [weak self] reply in
                self?.ReplyReplyOrDelete(indexPath.row, reply)
            }
        } else {
            // 点击某一条回复：回复这条回复的作者
            cell.onReplyTap = { [weak self] reply in
                self?.presentReplyAlert(
                    commentIndex: indexPath.row,
                    replyingToName: reply.authorName
                )
            }
        }

        // 点赞某一条回复
        cell.onReplyLikeTap = { [weak self] reply in
            self?.toggleReplyLike(reply, inCommentAt: indexPath.row)
        }
        return cell
    }

    // 由于我们在 didLoad 中设置了更新高度的逻辑，这里不需要实现 heightForRowAt
    // 但是为了确保正确性，可以返回 UITableView.automaticDimension
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 200  // 估算高度，帮助系统优化滚动
    }
}
