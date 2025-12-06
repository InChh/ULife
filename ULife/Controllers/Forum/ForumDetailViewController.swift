//
//  ForumDetailViewController.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//


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
    private var isPostLiked: Bool = false // 假设帖子初始状态未点赞
    
    // MARK: - Initialization
    
    init(post: ForumPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        // 将自定义 View 加载为 Controller 的主视图
        self.view = ForumDetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "帖子详情"
        view.backgroundColor = .systemBackground
        
        // 1. 设置代理
        detailView.commentTableView.delegate = self
        detailView.commentTableView.dataSource = self
        
        // 2. 绑定交互事件
        detailView.likeButton.addTarget(self, action: #selector(handleLikeTap), for: .touchUpInside)
        detailView.commentButton.addTarget(self, action: #selector(handleCommentTap), for: .touchUpInside)
        
        // 3. 初始数据绑定
        configurePostDetails()
        
        // 4. 加载评论数据 (模拟 API 调用)
        fetchComments()
        
        // 5. 更新点赞按钮状态
        updateLikeButtonState()
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
        detailView.createTimeLabel.text = formatter.string(from: post.createTime)
        
        // 假设这里会使用你的图片加载库加载 post.authorAvatar
        // detailView.authorAvatar.kf.setImage(with: URL(string: post.authorAvatar))
    }
    
    private func fetchComments() {
        // MARK: - ⚠️ 模拟 API 调用
        // 实际开发中，这里应该调用你的 NetworkManager 来请求 API
        // 例如：NetworkManager.shared.fetchComments(for: post.id) { result in ... }
        
        // 假设成功获取评论数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.comments = [
                Comment(id: "c1", authorName: "评论者A", authorAvatar: "", content: "楼主写得太好了，内容很有启发性！", timeAgo: "10分钟前", likeCount: 5),
                Comment(id: "c2", authorName: "评论者B", authorAvatar: "", content: "我也有同样的问题，希望能找到解决方案。", timeAgo: "5分钟前", likeCount: 2)
            ]
            
            // 更新评论区标题和 TableView
            self.detailView.commentHeaderLabel.text = "评论 (\(self.comments.count))"
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
            if let heightConstraint = self.detailView.commentTableView.constraints.first(where: { $0.firstAttribute == .height }) {
                heightConstraint.constant = height
            } else {
                let heightConstraint = self.detailView.commentTableView.heightAnchor.constraint(equalToConstant: height)
                heightConstraint.isActive = true
            }
            
            // 强制 View 重新布局
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UI Interaction
    
    @objc private func handleLikeTap() {
        // MARK: - ⚠️ 实际开发中，这里需要调用点赞 API
        
        // 切换点赞状态
        isPostLiked.toggle()
        
        // 仅在前端更新状态
        updateLikeButtonState()
        
        // 成功调用 API 后，你应该更新 post.likeCount 并通知列表页刷新
    }
    
    @objc private func handleCommentTap() {
        // 弹出评论输入框或跳转到全屏评论输入页面
        print("弹出评论输入界面")
    }
    
    // 更新点赞按钮的 UI 样式
    private func updateLikeButtonState() {
        let systemName = isPostLiked ? "heart.fill" : "heart"
        let color: UIColor = isPostLiked ? .systemRed : .systemGray
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        
        detailView.likeButton.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        detailView.likeButton.tintColor = color
        
        // 可选：更新点赞数量
        let currentLikes = isPostLiked ? post.likeCount + 1 : post.likeCount
        detailView.likeButton.setTitle("\(currentLikes)", for: .normal)
        
        // 重新对齐 (因为标题文本可能变了)
        detailView.likeButton.alignTextBelowImage(spacing: 4)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource (评论列表)

extension ForumDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 确保是我们的评论 TableView
        if tableView == detailView.commentTableView {
            return comments.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: comments[indexPath.row])
        return cell
    }
    
    // 由于我们在 didLoad 中设置了更新高度的逻辑，这里不需要实现 heightForRowAt
    // 但是为了确保正确性，可以返回 UITableView.automaticDimension
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // 估算高度，帮助系统优化滚动
    }
}