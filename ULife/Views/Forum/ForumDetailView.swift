// View/ForumDetailView.swift
import UIKit

class ForumDetailView: UIView {
    
    // MARK: - UI Components
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .systemBackground
        return sv
    }()
    
    private lazy var contentViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    // --- 帖子信息区 ---
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var authorInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    lazy var authorAvatar: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 18
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    lazy var createTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy var contentBodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0 // 显示全部内容
        return label
    }()
    
    // --- 评论区 ---
    
    lazy var commentHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "评论 (0)"
        return label
    }()
    
    // 嵌套的 TableView 用于评论列表
    lazy var commentTableView: UITableView = {
        let tv = UITableView()
        tv.isScrollEnabled = false // 关键：让外层 UIScrollView 负责滚动
        tv.separatorStyle = .singleLine
        tv.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        return tv
    }()
    
    // --- 底部工具栏 ---
    
    lazy var bottomToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowOpacity = 0.1 // 底部工具栏加阴影
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    // 底部点赞按钮
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.setTitle("点赞", for: .normal)
        button.tintColor = .systemGray
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.alignTextBelowImage(spacing: 4) // 自定义方法：图片在上，文字在下
        return button
    }()
    
    // 底部评论按钮
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: "message", withConfiguration: config), for: .normal)
        button.setTitle("评论", for: .normal)
        button.tintColor = .systemGray
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.alignTextBelowImage(spacing: 4)
        return button
    }()
    
    // MARK: - Init & Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // 1. 设置滚动视图和内容容器
        addSubview(scrollView)
        scrollView.addSubview(contentViewContainer)
        
        // 2. 将所有帖子和评论内容添加到 contentViewContainer
        authorInfoStack.addArrangedSubview(authorAvatar)
        authorInfoStack.addArrangedSubview(authorNameLabel)
        authorInfoStack.addArrangedSubview(createTimeLabel)
        
        [titleLabel, authorInfoStack, contentBodyLabel, commentHeaderLabel, commentTableView].forEach {
            contentViewContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 3. 设置底部工具栏
        addSubview(bottomToolbar)
        bottomToolbar.addSubview(likeButton)
        bottomToolbar.addSubview(commentButton)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentViewContainer.translatesAutoresizingMaskIntoConstraints = false
        authorAvatar.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // ScrollView 填充屏幕，但避开底部工具栏
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            
            // contentViewContainer 约束 (内容容器)
            contentViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            // 关键：宽度必须等于 ScrollView 的宽度
            contentViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // MARK: 内容布局
            
            // 标题
            titleLabel.topAnchor.constraint(equalTo: contentViewContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentViewContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentViewContainer.trailingAnchor, constant: -16),
            
            // 作者信息 Stack
            authorInfoStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            authorInfoStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorAvatar.widthAnchor.constraint(equalToConstant: 36),
            authorAvatar.heightAnchor.constraint(equalToConstant: 36),
            
            // 内容正文
            contentBodyLabel.topAnchor.constraint(equalTo: authorInfoStack.bottomAnchor, constant: 20),
            contentBodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentBodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // 评论区标题
            commentHeaderLabel.topAnchor.constraint(equalTo: contentBodyLabel.bottomAnchor, constant: 30),
            commentHeaderLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            commentHeaderLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // 评论 TableView
            commentTableView.topAnchor.constraint(equalTo: commentHeaderLabel.bottomAnchor, constant: 12),
            commentTableView.leadingAnchor.constraint(equalTo: contentViewContainer.leadingAnchor),
            commentTableView.trailingAnchor.constraint(equalTo: contentViewContainer.trailingAnchor),
            // 关键：底部必须连接到 contentViewContainer 的底部
            commentTableView.bottomAnchor.constraint(equalTo: contentViewContainer.bottomAnchor, constant: -10)
        ]),
        
        NSLayoutConstraint.activate([
            // MARK: 底部工具栏布局
            bottomToolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 55),
            
            // 评论按钮 (右侧)
            commentButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor),
            commentButton.trailingAnchor.constraint(equalTo: bottomToolbar.trailingAnchor, constant: -30),
            commentButton.widthAnchor.constraint(equalToConstant: 60),
            commentButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 点赞按钮 (在评论按钮左侧)
            likeButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor),
            likeButton.trailingAnchor.constraint(equalTo: commentButton.leadingAnchor, constant: -20),
            likeButton.widthAnchor.constraint(equalToConstant: 60),
            likeButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}

// 辅助扩展：让 UIButton 支持图文上下排列
extension UIButton {
    func alignTextBelowImage(spacing: CGFloat = 6.0) {
        guard let image = self.imageView?.image, let titleLabel = self.titleLabel, let titleText = titleLabel.text else { return }

        let titleSize = titleText.size(withAttributes: [NSAttributedString.Key.font: titleLabel.font!])

        // 调整 imageEdgeInsets，让图片居中偏上
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(titleSize.height + spacing),
            left: 0.0,
            bottom: 0.0,
            right: -titleSize.width
        )

        // 调整 titleEdgeInsets，让文字居中偏下
        self.titleEdgeInsets = UIEdgeInsets(
            top: spacing,
            left: -image.size.width,
            bottom: -image.size.height,
            right: 0.0
        )
    }
}