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

    // 评论数据源
    private var comments: [Comment] = []

    // 状态属性
    private var isPostLiked: Bool = false  // 假设帖子初始状态未点赞

    init(post: ForumPost) {
        self.post = post
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

        // 格式化日期
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        detailView.createTimeLabel.text = formatter.string(
            from: post.createTime
        )

        // 假设这里会使用你的图片加载库加载 post.authorAvatar
        // detailView.authorAvatar.kf.setImage(with: URL(string: post.authorAvatar))
    }

    private func fetchComments() {
        // MARK: - ⚠️ 模拟 API 调用
        // 实际开发中，这里应该调用你的 NetworkManager 来请求 API
        // 例如：NetworkManager.shared.fetchComments(for: post.id) { result in ... }

        // --- 模拟回复数据 ---
        let replies1: [CommentReply] = [
            CommentReply(
                id: "r1",
                authorName: "小助手",
                repliedToUser: nil,
                content: "感谢你的肯定！我们致力于提供高质量内容。",
                createTime: Date(timeIntervalSinceNow: -60 * 5)
            ),
            CommentReply(
                id: "r2",
                authorName: "热心网友C",
                repliedToUser: "评论者A",
                content: "确实，楼主的观点非常独到，受益匪浅。",
                createTime: Date(timeIntervalSinceNow: -60 * 3)
            ),
            CommentReply(
                id: "r3",
                authorName: "潜水艇",
                repliedToUser: nil,
                content: "偷偷点个赞！",
                createTime: Date(timeIntervalSinceNow: -60 * 2)
            ),
            CommentReply(
                id: "r4",
                authorName: "路人甲",
                repliedToUser: nil,
                content: "这条回复不会被默认显示，除非点击'查看更多'。",
                createTime: Date(timeIntervalSinceNow: -60 * 1)
            ),
        ]
        // 假设成功获取评论数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.comments = [
                Comment(
                    id: "c1",
                    authorName: "评论者A",
                    authorAvatar: "",
                    content: "楼主写得太好了，内容很有启发性！我已经在别处分享了你的帖子。",
                    createTime: Date(timeIntervalSinceNow: -60 * 20),
                    likeCount: 5,
                    replies: replies1  // 包含 4 条回复
                ),

                // 2. 没有回复的评论
                Comment(
                    id: "c2",
                    authorName: "评论者B",
                    authorAvatar: "",
                    content: "我也有同样的问题，希望能找到解决方案。不过帖子本身描述得很清晰。",
                    createTime: Date(timeIntervalSinceNow: -60 * 15),
                    likeCount: 2,
                    replies: []  // 明确没有回复
                ),

                // 3. 只有一条回复的评论
                Comment(
                    id: "c3",
                    authorName: "好奇宝宝",
                    authorAvatar: "",
                    content: "请问一下，帖子中提到的那个工具叫什么名字？",
                    createTime: Date(timeIntervalSinceNow: -60 * 10),
                    likeCount: 8,
                    replies: [
                        CommentReply(
                            id: "r5",
                            authorName: "楼主本人",
                            repliedToUser: "好奇宝宝",
                            content: "那个工具是 SwiftLint，非常好用。",
                            createTime: Date(timeIntervalSinceNow: -60 * 6)
                        )
                    ]
                ),

                // 4. 较长的评论内容（测试高度自适应）
                Comment(
                    id: "c4",
                    authorName: "资深用户",
                    authorAvatar: "",
                    content:
                        "关于这个问题，我做了一些深入的研究，我认为除了楼主提到的几点之外，我们还需要考虑内存管理和线程安全的问题。特别是在高性能要求的场景下，细微的同步问题都可能导致程序崩溃，所以建议大家在实际应用中要非常小心谨慎。代码写得好只是第一步，稳定性和可维护性才是长久之计。",
                    createTime: Date(timeIntervalSinceNow: -60 * 4),
                    likeCount: 15,
                    replies: nil  // nil 表示尚未加载回复或没有回复
                ),
            ]

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
        // 弹出评论输入框或跳转到全屏评论输入页面
        print("弹出评论输入界面")
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

        cell.configure(with: comments[indexPath.row])
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
        return 200 // 估算高度，帮助系统优化滚动
    }
}
