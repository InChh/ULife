//
//  ForumDetailViewController.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//  帖子详情页

// Controller/ForumDetailViewController.swift
import UIKit
import Kingfisher
import UlifeLib

class ForumDetailViewController: UIViewController {

    let detailView = ForumDetailView()
    
    // 记录评论表的高度约束，方便重复更新
    private var commentTableHeightConstraint: NSLayoutConstraint?

    // 弹出输入框
    private var commentContainerView: UIView?
    private var backgroundView: UIView?
    private var commentInputView: CommentInputView?

    // 接收从上一个 Controller 传入的帖子数据（初始化传入）
    private var post: PostDetail

    // 初始化
    init(post: PostDetail) {
        self.post = post
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
        detailView.authorNameLabel.text = post.author?.name
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

        detailView.createTimeLabel.text = post.createdAt
        
        //设置头像
        let avatarImageView = detailView.authorAvatar
        // 加载提示器,加载完成前转圈动画
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: URL(string: post.author?.avatarUrl ?? ""),
            placeholder: UIImage(named: "avatar_placeholder"),
            options: [
                .scaleFactor(UIScreen.main.scale), //告诉 Kingfisher 当前屏幕的缩放因子
                .transition(.fade(0.25)), // 渐变动画
            ],
            progressBlock: nil
        ) { result in
            switch result {
            case .success(let value):
                print("Loaded: \(value.source.url?.absoluteString ?? "")")
                break
            case .failure(let error):
                print("KF load failed: \(error.localizedDescription)")
            }
        }

        Task {
            // 获取评论列表
            comments = try await NetworkManager.client.getPostComments(postId: post.id, page: 1, pageSize: UInt64.max) // 评论暂时不分页，获取全部
            
            maincomments = comments.filter { item in
                // 检查 parentid 是否存在 (非 nil)
                // 如果存在，检查其值是否等于目标 ID
                return item.parentId == nil
            }

            // 更新评论区标题和 TableView
            self.detailView.commentHeaderLabel.text =
                "评论 (\(comments.count))"

            self.detailView.commentTableView.reloadData()  // tabelview
            // 通知 ScrollView 更新内容高度
            self.updateTableViewHeight()
        }
        
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
        updateLikeButtonState()
    }

    //收藏
    @objc private func handleCollectionTap() {
        updatecollectedButtonState()
    }

    //举报
    @objc private func handleReportTap() {
        let alert = UIAlertController(
            title: "举报内容",
            message: "请选择举报理由",
            preferredStyle: .actionSheet
        )

        let reasons = ["垃圾广告", "政治敏感", "人身攻击"]
        for reason in reasons {
            alert.addAction(
                UIAlertAction(
                    title: reason,
                    style: .default,
                    handler: { _ in
                        Task {
                            do {
                                let request = CreateReportRequest(targetType: ReportTargetType.post.rawValue, targetId: self.post.id, reason: reason, description: nil)
                                let _ = try await NetworkManager.client.createReport(input: request)
                                print("举报理由: \(reason)")
                                Toast.show("举报成功", style: .normal)
                            } catch {
                                Toast.show("举报失败，请稍后重试", style: .error)
                            }
                        }
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
                Task {
                    do {
                        // 如果用户没填，可以提示或者直接当作"其他"处理
                        // 发送举报请求到服务器
                        let request = CreateReportRequest(targetType: ReportTargetType.post.rawValue, targetId: self.post.id, reason: "其他", description: nil)
                        let _ = try await NetworkManager.client.createReport(input: request)
                        print("举报理由: 其他,用户未填写详情")
                        Toast.show("举报成功", style: .normal)
                    } catch {
                        Toast.show("举报失败，请稍后重试", style: .error)
                    }
                }
                return
            }
            Task {
                do {
                    // 提交带详情的举报
                    // 发送举报请求到服务器
                    let request = CreateReportRequest(targetType: ReportTargetType.post.rawValue, targetId: self.post.id, reason: "其他", description: text)
                    let _ = try await NetworkManager.client.createReport(input: request)
                    print("举报理由: 其他\(text)")
                    Toast.show("举报成功", style: .normal)
                } catch {
                    Toast.show("举报失败，请稍后重试", style: .error)
                }
            }
        }

        inputAlert.addAction(UIAlertAction(title: "取消", style: .cancel))
        inputAlert.addAction(submitAction)

        present(inputAlert, animated: true)
    }

    // 评论帖子
    @objc private func handleCommentTap() {
        showCommentInput()
    }

    // 将一条新的一级评论插入到列表顶部，并刷新 UI
    private func insertNewComment(_ comment: Comment) {
        comments.insert(comment, at: 0)
        maincomments.insert(comment, at: 0)
        detailView.commentHeaderLabel.text = "评论 (\(comments.count))"
        detailView.commentTableView.reloadData()
        updateTableViewHeight()  //更新 tabelview 的高度
    }

    // 显示中间弹出的多行评论输入窗口
    private func showCommentInput() {
        // 已经显示则不重复创建
        if backgroundView != nil { return }

        // 全屏背景窗口 暗淡
        let bgView = UIView()
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        //评论窗口外嵌一层内容窗口
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(container)

        let inputView = CommentInputView()
        inputView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(inputView)

        NSLayoutConstraint.activate([
            //居中
            container.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            // 固定一个相对宽度，避免过宽或过窄
            container.widthAnchor.constraint(equalTo: bgView.widthAnchor, multiplier: 0.82),

            inputView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            inputView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            inputView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            inputView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])

        // 绑定手势 点击空白区域关闭窗口
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tap.cancelsTouchesInView = false //保证手势识别不会静止其他事件
        bgView.addGestureRecognizer(tap) //点击背景页面

        // 按钮绑定方法
        inputView.onSend = { [weak self] text in
            guard let self = self else { return }
            let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !content.isEmpty else {
                Toast.show("评论内容不能为空", style: .error)
                return
            }

            Task {
                do {
                    let newComment = try await NetworkManager.client.createComment(input: CreateCommentRequest(postId: self.post.id, content: content, replyToCommentId: nil)).comment!

                    self.insertNewComment(newComment)
                    self.hideCommentInput()
                } catch {
                    Toast.show("创建评论失败，请稍后重试", style: .error)
                }
            }
        }

        backgroundView = bgView
        commentContainerView = container
        commentInputView = inputView

        // 弹出键盘
        inputView.beginEditing()
    }

    // 点击遮罩层时收起评论窗口（点击内容区域不会关闭）
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        guard let bgView = backgroundView,
              let container = commentContainerView else { return }

        let location = gesture.location(in: bgView) //获取手势点击的位置
        if !container.frame.contains(location) {
            hideCommentInput()
        }
    }

    // 点击评论后消除所有 UI
    private func hideCommentInput() {
        view.endEditing(true)
        backgroundView?.removeFromSuperview() //将 backgroundView 从父视图删除
        backgroundView = nil
        commentContainerView = nil
        commentInputView = nil
    }

    // 更新底部工具栏点赞按钮的 UI 样式
    private func updateLikeButtonState() {
        Task {
            do {
                var isLiked = post.userInteraction?.isLiked ?? false
                
                var responseData: LikePostData
                if isLiked {
                    responseData = try await NetworkManager.client.unlikePost(postId: post.id)
                    post.userInteraction?.isLiked = false
                } else {
                    responseData = try await NetworkManager.client.likePost(postId: post.id)
                    post.userInteraction?.isLiked = true
                }
                
                let isLikedAfterUpdate = responseData.isLiked
                let systemName = isLikedAfterUpdate ? "hand.thumbsup.fill" : "hand.thumbsup"
                let color: UIColor = isLikedAfterUpdate ? .systemRed : .label
                let text = isLikedAfterUpdate ? "\(responseData.currentLikeCount)" : "点赞"

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
            } catch {
                Toast.show("操作失败，请稍后重试", style: .error)
            }
        }
    }

    // 更新底部工具栏收藏按钮的 UI 样式
    private func updatecollectedButtonState() {
        Task {
            do {
                var isCollected = post.userInteraction?.isCollected ?? false
                var responseData: CollectPostData
                
                if isCollected {
                    responseData = try await NetworkManager.client.uncollectPost(postId: post.id)
                    post.userInteraction?.isCollected = false
                } else {
                    responseData = try await NetworkManager.client.collectPost(postId: post.id)
                    post.userInteraction?.isCollected = true
                }
                
                let isCollectedAfterUpdate = responseData.isCollected
                let systemName = isCollectedAfterUpdate ? "star.fill" : "star"
                let color: UIColor = isCollectedAfterUpdate ? .systemRed : .label
                let text = isCollectedAfterUpdate ? "已收藏" : "收藏"

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

            } catch {}
        }
    }

    // 切换某条评论的点赞状态
    func toggleCommentLike(at index: Int) {
        // 获取这条评论
        guard maincomments.indices.contains(index) else { return }
        
        Task {
            do {
                var comment = maincomments[index]
                let isLiked = comment.userInteraction?.isLiked ?? false
                if isLiked {
                    let _ = try await NetworkManager.client.unlikeComment(commentId: comment.id)
                    comment.userInteraction?.isLiked = false
                } else {
                    let _ = try await NetworkManager.client.likeComment(commentId: comment.id)
                    comment.userInteraction?.isLiked = true
                }
                
                // 重新加载该条评论
                maincomments[index] = comment
                let indexPath = IndexPath(row: index, section: 0)
                detailView.commentTableView.reloadRows(at: [indexPath], with: .none)
                updateTableViewHeight()
            } catch {
                Toast.show("操作失败，请稍后重试", style: .error)
            }
        }
    }

    // 切换某条回复的点赞状态
    func toggleReplyLike(_ reply: Comment, inCommentAt index: Int) {
        guard maincomments.indices.contains(index) else { return }

        Task {
            do {
                let replyindex = comments.firstIndex(where: { $0.id == reply.id })
                var comment = comments[replyindex!]
                let isLiked = comment.userInteraction?.isLiked ?? false
                if isLiked {
                    let _ = try await NetworkManager.client.unlikeComment(commentId: comment.id)
                    comment.userInteraction?.isLiked = false
                } else {
                    let _ = try await NetworkManager.client.likeComment(commentId: comment.id)
                    comment.userInteraction?.isLiked = true
                }
                
                comments[replyindex!] = comment
                let indexPath = IndexPath(row: index, section: 0)
                detailView.commentTableView.reloadRows(at: [indexPath], with: .none)
                updateTableViewHeight()
            } catch {
                Toast.show("操作失败，请稍后重试", style: .error)
            }
        }
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
                    self.showReplyInput(
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
                    Task {
                        do {
                            let id = maincomments[commentIndex].id
                            try await NetworkManager.client.deleteComment(commentId: id)
                            
                            maincomments.remove(at: commentIndex)
                            comments.removeAll { comment in
                                return comment.parentId == id || comment.id == id
                            }
                            
                            self.detailView.commentHeaderLabel.text =
                                "评论 (\(comments.count))"
                            self.detailView.commentTableView.reloadData()
                            self.updateTableViewHeight()
                            Toast.show("删除成功", style: .normal)
                        } catch {
                            Toast.show("删除失败，请稍后重试", style: .error)
                        }
                    }
                }
            )
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    // 本人的回复点击回复 选择进行删除还是回复
    func ReplyReplyOrDelete(_ commentIndex: Int, _ reply: Comment) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "回复", style: .default) { [weak self] _ in
                self?.showReplyInput(
                    commentIndex: commentIndex,
                    replyingToName: reply.author?.name
                )
            }
        )

        alert.addAction(
            UIAlertAction(title: "删除", style: .destructive) { _ in
                comments.removeAll { comment in
                    return comment.id == reply.id
                }
                Task {
                    do {
                        try await NetworkManager.client.deleteComment(commentId: reply.id)
                        // 刷新列表和高度
                        self.detailView.commentTableView.reloadData()
                        self.updateTableViewHeight()
                        Toast.show("删除成功", style: .normal)
                    } catch {
                        Toast.show("删除失败，请稍后重试", style: .error)
                    }
                }

            }
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    // 弹出回复框
    func showReplyInput( commentIndex: Int, replyingToName: String?) {
        // 已经显示则不重复创建
        if backgroundView != nil { return }

        // 全屏背景窗口 暗淡
        let bgView = UIView()
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        //评论窗口外嵌一层内容窗口
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(container)

        let inputView = CommentInputView()
        inputView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(inputView)

        NSLayoutConstraint.activate([
            //居中
            container.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            // 固定一个相对宽度，避免过宽或过窄
            container.widthAnchor.constraint(equalTo: bgView.widthAnchor, multiplier: 0.82),

            inputView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            inputView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            inputView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            inputView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])

        // 绑定手势 点击空白区域关闭窗口
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tap.cancelsTouchesInView = false //保证手势识别不会静止其他事件
        bgView.addGestureRecognizer(tap) //点击背景页面

        // 按钮绑定方法
        inputView.onSend = { [weak self] text in
            guard let self = self else { return }
            let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !content.isEmpty else {
                Toast.show("评论内容不能为空", style: .error)
                return
            }
            Task {
                do {
                    //获取回复的评论和回复
                    let comment = maincomments[commentIndex]

                    let response = try await NetworkManager.client.createComment(input: CreateCommentRequest(postId: comment.postId, content: content, replyToCommentId: comment.id))
                    comments.append(response.comment!)

                    self.detailView.commentTableView.reloadData()  //刷新数据
                    self.updateTableViewHeight()  //更新高度

                    self.hideCommentInput()
                } catch {
                    Toast.show("创建评论失败，请稍后重试", style: .error)
                }
            }
        }

        backgroundView = bgView
        commentContainerView = container
        commentInputView = inputView

        // 弹出键盘
        inputView.beginEditing()
    }


}
