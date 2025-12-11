//
//  ForumDetailViewController.swift
//  ULife
//
//  帖子详情页 - 参考活动模块重写

import UIKit
import Kingfisher

class ForumDetailViewController: UIViewController {

    // MARK: - Properties
    private var post: Post
    private var comments: [Comment] = []
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let commentsTableView = UITableView(frame: .zero, style: .plain)
    private var commentsHeightConstraint: NSLayoutConstraint?
    
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let timeLabel = UILabel()
    private let contentLabel = UILabel()
    private let tagsLabel = UILabel()
    private let statsLabel = UILabel()
    
    private let likeButton = UIButton(type: .system)
    private let collectButton = UIButton(type: .system)
    private let commentButton = UIButton(type: .system)

    // MARK: - Init
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "帖子详情"
        view.backgroundColor = .systemBackground
        setupUI()
        render()
        loadPostDetail()
        loadComments()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 标题
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.numberOfLines = 0
        
        // 作者信息
        authorLabel.font = .systemFont(ofSize: 14)
        authorLabel.textColor = .secondaryLabel
        
        // 时间
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .tertiaryLabel
        
        // 内容
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.numberOfLines = 0
        
        // 标签
        tagsLabel.font = .systemFont(ofSize: 13)
        tagsLabel.textColor = .systemBlue
        tagsLabel.numberOfLines = 0
        
        // 统计
        statsLabel.font = .systemFont(ofSize: 13)
        statsLabel.textColor = .secondaryLabel
        
        // 评论列表
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        commentsTableView.isScrollEnabled = false
        commentsTableView.separatorStyle = .none
        
        // 底部工具栏
        setupBottomToolbar()
        
        [titleLabel, authorLabel, timeLabel, contentLabel, tagsLabel, statsLabel, createSeparator(), commentsTableView].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        let toolbar = createToolbar()
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBottomToolbar() {
        likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        likeButton.setTitle("点赞", for: .normal)
        likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        collectButton.setImage(UIImage(systemName: "star"), for: .normal)
        collectButton.setTitle("收藏", for: .normal)
        collectButton.addTarget(self, action: #selector(handleCollect), for: .touchUpInside)
        
        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        commentButton.setTitle("评论", for: .normal)
        commentButton.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
    }

    private func createToolbar() -> UIView {
        let toolbar = UIView()
        toolbar.backgroundColor = .systemBackground
        toolbar.layer.shadowColor = UIColor.black.cgColor
        toolbar.layer.shadowOffset = CGSize(width: 0, height: -1)
        toolbar.layer.shadowOpacity = 0.1
        toolbar.layer.shadowRadius = 2
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [likeButton, collectButton, commentButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        toolbar.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: toolbar.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor, constant: -8)
        ])
        
        [likeButton, collectButton, commentButton].forEach { button in
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.setTitleColor(.label, for: .normal)
            button.tintColor = .label
            var config = UIButton.Configuration.plain()
            config.imagePadding = 4
            config.imagePlacement = .top
            button.configuration = config
        }
        
        return toolbar
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
                }

    // MARK: - Render
    private func render() {
        titleLabel.text = post.title
        authorLabel.text = "\(post.author.name) · \(post.author.college)"
        timeLabel.text = post.createdAt.timeAgoString()
        contentLabel.text = post.content
        tagsLabel.text = post.tags.map { "#\($0)" }.joined(separator: " ")
        updateStatsLabel()
        
        updateLikeButton()
        updateCollectButton()
    }

    private func updateStatsLabel() {
        statsLabel.text = "👁 \(post.stats.viewCount)  👍 \(post.stats.likeCount)  💬 \(post.stats.commentCount)"
    }
    
    private func updateLikeButton() {
        let isLiked = post.userInteraction.isLiked
        likeButton.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .label
    }
    
    private func updateCollectButton() {
        let isCollected = post.userInteraction.isCollected
        collectButton.setImage(UIImage(systemName: isCollected ? "star.fill" : "star"), for: .normal)
        collectButton.tintColor = isCollected ? .systemYellow : .label
    }
    
    // MARK: - Data Loading
    private func loadPostDetail() {
        Task {
            do {
                let detail = try await ForumRequest().GetPostDetail(id: post.id)
                await MainActor.run {
                    self.post = detail
                    self.render()
                }
            } catch {
                print("加载帖子详情失败: \(error)")
            }
        }
    }
    
    private func loadComments() {
        Task {
            do {
                let list = try await ForumRequest().GetCommentList(postId: self.post.id)
                await MainActor.run {
                    self.comments = list
                    self.commentsTableView.reloadData()
                    self.updateCommentsHeight()
                }
            } catch {
                print("加载评论失败: \(error)")
            }
        }
    }
    
    private func updateCommentsHeight() {
        commentsTableView.layoutIfNeeded()
        let height = commentsTableView.contentSize.height
        
        if let constraint = commentsHeightConstraint {
            constraint.constant = height
        } else {
            let constraint = commentsTableView.heightAnchor.constraint(equalToConstant: height)
            constraint.isActive = true
            commentsHeightConstraint = constraint
        }
    }
    
    // MARK: - Actions
    @objc private func handleLike() {
        post.userInteraction.isLiked.toggle()
        updateLikeButton()
        
        Task {
            do {
                let request = LikeOrDisListRequest(action: post.userInteraction.isLiked ? .like : .unlike)
                _ = try await ForumRequest().LikeOrDisList(Request: request, postId: post.id)
            } catch {
                print("点赞失败: \(error)")
                await MainActor.run {
                    self.post.userInteraction.isLiked.toggle()
                    self.updateLikeButton()
    }
            }
        }
    }
    
    @objc private func handleCollect() {
        post.userInteraction.isCollected.toggle()
        updateCollectButton()
        
        Task {
            do {
                let request = ColectOrDisColectRequest(action: post.userInteraction.isCollected ? .collect : .uncollect)
                _ = try await ForumRequest().ColectOrDisColect(Request: request, postId: post.id)
            } catch {
                print("收藏失败: \(error)")
                await MainActor.run {
                    self.post.userInteraction.isCollected.toggle()
                    self.updateCollectButton()
    }
            }
        }
    }
    
    @objc private func handleComment() {
        let alert = UIAlertController(title: "发表评论", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "说点什么..."
        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "发送", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            self?.sendComment(text)
        })
        
        present(alert, animated: true)
    }

    private func sendComment(_ content: String) {
        Task {
            do {
                let request = CreateCommentRequest(content: content, replyToCommentId: nil)
                let resp = try await ForumRequest().CreateComment(postId: post.id, request: request)
                await MainActor.run {
                    // 直接插入新评论到顶部，提升体验
                    self.comments.insert(resp.comment, at: 0)
                    self.post.stats.commentCount += 1
                    self.updateStatsLabel()
                    self.commentsTableView.reloadData()
                    self.updateCommentsHeight()
                    // 再次从服务端同步，确保与后台状态一致
                    self.loadComments()
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "评论失败", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension ForumDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}
