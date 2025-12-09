//
//  ForumDetailViewController.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//  帖子详情页

// Controller/ForumDetailViewController.swift
import UIKit

class ForumDetailViewController: UIViewController {

    let detailView = ForumDetailView()
    
    // 记录评论表的高度约束，方便重复更新
    private var commentTableHeightConstraint: NSLayoutConstraint?

    // 接收从上一个 Controller 传入的帖子数据（初始化传入）
    private let post: ForumPost

    // 初始化
    init(post: ForumPost) {
        self.post = post
        isPostLiked = post.isLiked
        iscollected = post.isreplyed
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始数据绑定
        configurePostDetails()
        setupBindings()

        setupViews()

        // 更新点赞按钮状态
        updateLikeButtonState()
        updatecollectedButtonState()
    }
    
    // 确保在宽度确定后再重新计算一次高度!
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }

    private func setupViews() {
        detailView.commentTableView.delegate = self
        detailView.commentTableView.dataSource = self

        self.view = detailView
    }

    //绑定事件
    private func setupBindings() {
        detailView.likeButton.addTarget(
            self,
            action: #selector(handleLikeTap),
            for: .touchUpInside
        )
        detailView.CollectButton.addTarget(
            self,
            action: #selector(handleCollectionTap),
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

    // 初始数据绑定
    private func configurePostDetails() {
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

        // 获取评论列表
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            comments = MockCommentData.comments

            // 更新评论区标题和 TableView
            self.detailView.commentHeaderLabel.text =
                "评论 (\(comments.count))"

            self.detailView.commentTableView.reloadData()  // tabelview
            // 通知 ScrollView 更新内容高度
            self.updateTableViewHeight()
        }

        // 假设这里会使用你的图片加载库加载 post.authorAvatar
        // detailView.authorAvatar.kf.setImage(with: URL(string: post.authorAvatar))
    }

    // 动态调整 TableView 高度，解决 ScrollView 嵌套 TableView 的问题
    private func updateTableViewHeight() {
        // 使用 DispatchQueue.main.async 确保在 TableView 渲染完成后计算高度
        DispatchQueue.main.async {
            // 先强制 tableView 根据最新数据完成布局
            self.detailView.commentTableView.layoutIfNeeded()

            let height = self.detailView.commentTableView.contentSize.height

            if let heightConstraint = self.commentTableHeightConstraint {
                heightConstraint.constant = height
            } else {
                let constraint = self.detailView.commentTableView
                    .heightAnchor.constraint(equalToConstant: height)
                constraint.isActive = true
                self.commentTableHeightConstraint = constraint
            }

            self.view.layoutIfNeeded()
        }
    }

    //点赞
    @objc private func handleLikeTap() {
        isPostLiked.toggle()

        updateLikeButtonState()

        /// 成功调用 API 后，你应该更新 post.likeCount 并通知列表页刷新
    }

    //收藏
    @objc private func handleCollectionTap() {
        iscollected.toggle()

        updatecollectedButtonState()

        /// 成功调用 API 后，你应该更新 post.likeCount 并通知列表页刷新
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

    // 举报其他内容时弹出举报内容框
    private func showOtherReportInput() {
        let inputAlert = UIAlertController(
            title: "举报详情",
            message: "请填写具体的举报原因",
            preferredStyle: .alert
        )

        inputAlert.addTextField { textField in
            textField.placeholder = "请输入详细理由..."
            textField.returnKeyType = .done
        }

        let submitAction = UIAlertAction(title: "提交", style: .default) { _ in
            // 获取输入框的内容
            guard let text = inputAlert.textFields?.first?.text, !text.isEmpty
            else {
                // 如果用户没填，可以提示或者直接当作"其他"处理
                print("举报理由: 其他,用户未填写详情")
                Toast.show("举报成功", style: .normal)
                return
            }
            // 提交带详情的举报
            print("举报理由: 其他\(text)")
            Toast.show("举报成功", style: .normal)
        }

        inputAlert.addAction(UIAlertAction(title: "取消", style: .cancel))
        inputAlert.addAction(submitAction)

        present(inputAlert, animated: true)
    }

    // 评论帖子
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
                let newComment = Comment2(
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

    // 将一条新的一级评论插入到列表顶部，并刷新 UI
    private func insertNewComment(_ comment: Comment2) {
        comments.insert(comment, at: 0)
        detailView.commentHeaderLabel.text = "评论 (\(comments.count))"
        detailView.commentTableView.reloadData()
        updateTableViewHeight()  //更新 tabelview 的高度
    }

    // 更新底部工具栏点赞按钮的 UI 样式
    private func updateLikeButtonState() {
        let systemName = isPostLiked ? "hand.thumbsup.fill" : "hand.thumbsup"
        let color: UIColor = isPostLiked ? .systemRed : .label
        let text = isPostLiked ? "\(post.likeCount + 1)" : "点赞"

        // 获取当前的配置进行修改
        var config = detailView.likeButton.configuration
        config?.image = UIImage(systemName: systemName)
        config?.baseForegroundColor = color

        // 更新文字
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config?.attributedTitle = AttributedString(
            text,
            attributes: titleContainer
        )

        detailView.likeButton.configuration = config
    }

    // 更新底部工具栏收藏按钮的 UI 样式
    private func updatecollectedButtonState() {
        let systemName = iscollected ? "star.fill" : "star"
        let color: UIColor = iscollected ? .systemRed : .label
        let text = iscollected ? "\(post.replyCount + 1)" : "收藏"

        var config = detailView.CollectButton.configuration
        config?.image = UIImage(systemName: systemName)
        config?.baseForegroundColor = color

        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config?.attributedTitle = AttributedString(
            text,
            attributes: titleContainer
        )

        detailView.CollectButton.configuration = config
    }

    // MARK: - 实现 点击评论(回复,删除) 评论点赞
    // 切换某条评论的点赞状态
    func toggleCommentLike(at index: Int) {
        // 获取这条评论
        guard comments.indices.contains(index) else { return }
        let comment = comments[index]

        // 改变数据
        if likedCommentIDs.contains(comment.id) {
            likedCommentIDs.remove(comment.id)
        } else {
            likedCommentIDs.insert(comment.id)
        }

        // 重新加载该条评论
        let indexPath = IndexPath(row: index, section: 0)
        detailView.commentTableView.reloadRows(at: [indexPath], with: .none)
        updateTableViewHeight()
    }

    // 切换某条回复的点赞状态
    func toggleReplyLike(_ reply: CommentReply, inCommentAt index: Int) {
        guard comments.indices.contains(index) else { return }

        //修改数据
        if likedReplyIDs.contains(reply.id) {
            likedReplyIDs.remove(reply.id)
        } else {
            likedReplyIDs.insert(reply.id)
        }

        let indexPath = IndexPath(row: index, section: 0)
        detailView.commentTableView.reloadRows(at: [indexPath], with: .none)
        updateTableViewHeight()
    }

    // 本人的评论点击主评论 选择进行删除还是回复
    func CommentReplyOrDelete(_ commentIndex: Int) {
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
                    comments.remove(at: commentIndex)
                    self.detailView.commentHeaderLabel.text =
                        "评论 (\(comments.count))"
                    self.detailView.commentTableView.reloadData()
                    self.updateTableViewHeight()
                    Toast.show("删除成功", style: .normal)
                }
            )
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    // 本人的回复点击回复 选择进行删除还是回复
    func ReplyReplyOrDelete(_ commentIndex: Int, _ reply: CommentReply) {
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
                    comments.indices.contains(commentIndex),
                    var replies = comments[commentIndex].replies,  // 取出原来的数组
                    let idx = replies.firstIndex(of: reply)  // 找到要删的那条
                else { return }

                // 从本地数组删除
                replies.remove(at: idx)
                // 写回到数据源
                comments[commentIndex].replies = replies

                // 刷新列表和高度
                self.detailView.commentTableView.reloadData()
                self.updateTableViewHeight()
                Toast.show("删除成功", style: .normal)
            }
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    // 弹出回复框
    func presentReplyAlert(
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
                    commentIndex < comments.count,
                    let text = alert.textFields?.first?.text?
                        .trimmingCharacters(in: .whitespacesAndNewlines),
                    !text.isEmpty
                else {
                    Toast.show("回复内容不能为空", style: .error)
                    return
                }

                //获取回复的评论和回复
                var comment = comments[commentIndex]
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

                comment.replies = existingReplies

                comments[commentIndex] = comment
                self.detailView.commentTableView.reloadData()  //刷新数据
                self.updateTableViewHeight()  //更新高度
            }
        )

        let cancelAction = UIAlertAction(title: "取消", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(sendAction)

        present(alert, animated: true)
    }
}
