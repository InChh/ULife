//
//  ForumDetailView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//  帖子详情页

// View/ForumDetailView.swift
import UIKit

class ForumDetailView: UIView {

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
        label.numberOfLines = 0  // 显示全部内容
        return label
    }()

    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray5
        return line
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
        tv.isScrollEnabled = false  // 关键：让外层 UIScrollView 负责滚动
        tv.separatorStyle = .singleLine
        tv.register(
            CommentCell.self,
            forCellReuseIdentifier: CommentCell.identifier
        )
        return tv
    }()

    // --- 底部工具栏 ---
    lazy var bottomToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        // 顶部加一根细线
        let line = UIView()
        line.backgroundColor = .systemGray5
        view.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: view.topAnchor),
            line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        return view
    }()

    // 左侧：点赞按钮 (修改后：垂直布局)
    lazy var likeButton: UIButton = {
        // 使用 plain 样式配置
        var config = UIButton.Configuration.plain()

        // 图片设置
        config.image = UIImage(systemName: "hand.thumbsup")
        // 关键设置：图片放置在顶部
        config.imagePlacement = .top
        // 图片和文字之间的间距
        config.imagePadding = 4

        // 初始文字 (模拟数据)
        // 使用 AttributedString 来设置较小的字体，避免底部栏太拥挤
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config.attributedTitle = AttributedString(
            "点赞",
            attributes: titleContainer
        )

        // 创建按钮
        let btn = UIButton(configuration: config)
        btn.tintColor = .label  // 图标颜色
        return btn
    }()

    // 2. 右侧：举报按钮 (修改后：垂直布局)
    lazy var reportButton: UIButton = {
        var config = UIButton.Configuration.plain()

        config.image = UIImage(systemName: "exclamationmark.triangle")
        config.imagePlacement = .top  // 图片在上
        config.imagePadding = 4  // 间距

        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config.attributedTitle = AttributedString(
            "举报",
            attributes: titleContainer
        )

        let btn = UIButton(configuration: config)
        btn.tintColor = .systemGray
        return btn
    }()

    // 中间：评论按钮 (伪装成输入框的样子)
    lazy var commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemGray6  // 浅灰背景
        btn.layer.cornerRadius = 18  // 圆角 (高度36的一半)
        btn.clipsToBounds = true

        // 设置文字
        btn.setTitle(" 友善评论，传递温暖", for: .normal)
        btn.setTitleColor(.systemGray2, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.contentHorizontalAlignment = .left  // 文字靠左
        btn.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 0
        )  // 左边距

        // 加个小铅笔图标在文字前面
        let config = UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .regular
        )
        btn.setImage(
            UIImage(systemName: "square.and.pencil", withConfiguration: config),
            for: .normal
        )
        btn.tintColor = .systemGray2

        return btn
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

        [
            titleLabel, authorInfoStack, contentBodyLabel, commentHeaderLabel,
            commentTableView, line
        ].forEach { item in
            contentViewContainer.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }

        // 3. 设置底部工具栏
        addSubview(bottomToolbar)
        bottomToolbar.addSubview(likeButton)
        bottomToolbar.addSubview(commentButton)
        bottomToolbar.addSubview(reportButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentViewContainer.translatesAutoresizingMaskIntoConstraints = false

        [bottomToolbar, likeButton, commentButton, reportButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // ScrollView 填充屏幕，但避开底部工具栏
            scrollView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: bottomToolbar.topAnchor
            ),

            // contentViewContainer 约束 (内容容器)
            contentViewContainer.topAnchor.constraint(
                equalTo: scrollView.topAnchor
            ),
            contentViewContainer.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor
            ),
            contentViewContainer.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor
            ),
            contentViewContainer.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor
            ),
            // 关键：宽度必须等于 ScrollView 的宽度
            contentViewContainer.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor
            ),

            // MARK: 内容布局

            // 标题
            titleLabel.topAnchor.constraint(
                equalTo: contentViewContainer.topAnchor,
                constant: 20
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentViewContainer.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentViewContainer.trailingAnchor,
                constant: -16
            ),

            // 作者信息 Stack
            authorInfoStack.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 16
            ),
            authorInfoStack.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            authorAvatar.widthAnchor.constraint(equalToConstant: 36),
            authorAvatar.heightAnchor.constraint(equalToConstant: 36),

            // 内容正文
            contentBodyLabel.topAnchor.constraint(
                equalTo: authorInfoStack.bottomAnchor,
                constant: 20
            ),
            contentBodyLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            contentBodyLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),
            
            
            
            line.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.bottomAnchor.constraint(equalTo: commentHeaderLabel.topAnchor,constant: -5),

            // 评论区标题
            commentHeaderLabel.topAnchor.constraint(
                equalTo: contentBodyLabel.bottomAnchor,
                constant: 30
            ),
            commentHeaderLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            commentHeaderLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),

            // 评论 TableView
            commentTableView.topAnchor.constraint(
                equalTo: commentHeaderLabel.bottomAnchor,
                constant: 12
            ),
            commentTableView.leadingAnchor.constraint(
                equalTo: contentViewContainer.leadingAnchor
            ),
            commentTableView.trailingAnchor.constraint(
                equalTo: contentViewContainer.trailingAnchor
            ),
            // 关键：底部必须连接到 contentViewContainer 的底部
            commentTableView.bottomAnchor.constraint(
                equalTo: contentViewContainer.bottomAnchor,
                constant: -10
            ),
        ])

        NSLayoutConstraint.activate([
            // 工具栏固定在底部
            bottomToolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor
            ),  // 适配 iPhone X 底部
            bottomToolbar.heightAnchor.constraint(equalToConstant: 56),  // 高度

            // 1. 左侧点赞按钮
            likeButton.leadingAnchor.constraint(
                equalTo: bottomToolbar.leadingAnchor,
                constant: 12
            ),
            likeButton.centerYAnchor.constraint(
                equalTo: bottomToolbar.centerYAnchor
            ),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),

            // 2. 右侧举报按钮
            reportButton.trailingAnchor.constraint(
                equalTo: bottomToolbar.trailingAnchor,
                constant: -12
            ),
            reportButton.centerYAnchor.constraint(
                equalTo: bottomToolbar.centerYAnchor
            ),
            reportButton.widthAnchor.constraint(equalToConstant: 44),
            reportButton.heightAnchor.constraint(equalToConstant: 44),

            // 3. 中间评论按钮 (撑满中间空间)
            commentButton.leadingAnchor.constraint(
                equalTo: likeButton.trailingAnchor,
                constant: 8
            ),
            commentButton.trailingAnchor.constraint(
                equalTo: reportButton.leadingAnchor,
                constant: -8
            ),
            commentButton.centerYAnchor.constraint(
                equalTo: bottomToolbar.centerYAnchor
            ),
            commentButton.heightAnchor.constraint(equalToConstant: 36),  // 胶囊高度
        ])
    }
}
