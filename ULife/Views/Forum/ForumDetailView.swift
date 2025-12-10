//
//  ForumDetailView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//  帖子详情页

// View/ForumDetailView.swift
import UIKit

class ForumDetailView: UIView {

    // 页面的滚动页
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .systemBackground
        return sv
    }()
    // 滚动页中用来装所有容器的 view (添加内部 view 后就能自动推导出UIScrollView的高度)
    private lazy var contentViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    /// --- 帖子信息区 ---
    //标题
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    //作者信息View(头像,名字,创建时间)
    lazy var authorInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal  // (水平,元素从左到右)
        stack.spacing = 8
        stack.alignment = .center  // 因为是.horizontal 所以子视图会沿着 UIStackView 的垂直中心线居中对齐。
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
    //帖子内容
    lazy var contentBodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0  // 不限制行数
        return label
    }()

    /// 帖子标签展示（位于正文下方）
    lazy var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = nil
        return label
    }()

    /// --- 评论区 ---
    lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray5
        return line
    }()

    lazy var commentHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "评论 (0)"
        return label
    }()

    // TableView 用于评论列表
    lazy var commentTableView: UITableView = {
        let tv = UITableView()
        tv.isScrollEnabled = false  // TableView不滑动 让外层 UIScrollView 负责滚动
        tv.separatorStyle = .singleLine  //设置表格视图中单元格（Cell）之间的分隔线样式为单行细线
        tv.register(
            CommentCell.self,
            forCellReuseIdentifier: CommentCell.identifier
        )
        return tv
    }()

    /// --- 底部工具栏 ---
    lazy var bottomToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground

        // 工具栏顶部加一根细线
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

    // 工具栏点赞按钮
    lazy var likeButton: UIButton = {
        // 使用 plain 样式配置 朴素风格
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "hand.thumbsup")
        config.imagePlacement = .top
        config.imagePadding = 4

        // 使用 AttributedString 来设置较小的字体, 普通设置 title 无法设置字体大小
        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config.attributedTitle = AttributedString(
            "点赞",
            attributes: titleContainer
        )

        let btn = UIButton(configuration: config)
        btn.tintColor = .label  // 图标颜色
        return btn
    }()

    // 收藏按钮：在点赞按钮右侧
    lazy var CollectButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "star")
        config.imagePlacement = .top
        config.imagePadding = 4

        var titleContainer = AttributeContainer()
        titleContainer.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        config.attributedTitle = AttributedString(
            "收藏",
            attributes: titleContainer
        )

        let btn = UIButton(configuration: config)
        btn.tintColor = .label
        return btn
    }()

    // 右侧 举报按钮
    lazy var reportButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "exclamationmark.triangle")
        config.imagePlacement = .top
        config.imagePadding = 4

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
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true

        btn.setTitle(" 友善评论，传递温暖", for: .normal)
        btn.setTitleColor(.systemGray2, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.contentHorizontalAlignment = .left  // 文字靠左

        // 设置左边距
        btn.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 0
        )

        // 加个小铅笔图标在文字前面(按钮默认图片在左,字体在右)
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

    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 设置 UI
    private func setupUI() {
        backgroundColor = .systemBackground

        // 滑动窗口(包含内视图,帮助自动计算滑动窗口的高度)
        addSubview(scrollView)
        scrollView.addSubview(contentViewContainer)

        authorInfoStack.addArrangedSubview(authorAvatar)
        authorInfoStack.addArrangedSubview(authorNameLabel)
        authorInfoStack.addArrangedSubview(createTimeLabel)

        [
            titleLabel, authorInfoStack, contentBodyLabel, tagsLabel,
            commentHeaderLabel, commentTableView, line,
        ].forEach { item in
            contentViewContainer.addSubview(item)
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentViewContainer.translatesAutoresizingMaskIntoConstraints = false

        // 设置底部工具栏
        addSubview(bottomToolbar)
        bottomToolbar.addSubview(likeButton)
        bottomToolbar.addSubview(CollectButton)
        bottomToolbar.addSubview(commentButton)
        bottomToolbar.addSubview(reportButton)

        [bottomToolbar, likeButton, CollectButton, commentButton, reportButton]
            .forEach { item in
                item.translatesAutoresizingMaskIntoConstraints = false
            }

        
        // 设置布局
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

            // contentViewContainer 约束 (滑动的内容容器的标准设置)
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
            // 宽度必须等于 ScrollView 的宽度
            contentViewContainer.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor
            ),

            
            
            // 容器中内容布局 要从上到下连贯
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
            // 标签
            tagsLabel.topAnchor.constraint(
                equalTo: contentBodyLabel.bottomAnchor,
                constant: 12
            ),
            tagsLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            tagsLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),

            line.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor
            ),
            line.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor
            ),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.bottomAnchor.constraint(
                equalTo: commentHeaderLabel.topAnchor,
                constant: -5
            ),

            // 评论区标题
            commentHeaderLabel.topAnchor.constraint(
                equalTo: tagsLabel.bottomAnchor,
                constant: 24
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
            // 底部必须连接到 contentViewContainer 的底部 从上到下连贯
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
            ),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 56),

            // 左侧点赞按钮
            likeButton.leadingAnchor.constraint(
                equalTo: bottomToolbar.leadingAnchor,
                constant: 12
            ),
            likeButton.centerYAnchor.constraint(
                equalTo: bottomToolbar.centerYAnchor
            ),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),

            // 收藏按钮，在点赞按钮右侧
            CollectButton.leadingAnchor.constraint(
                equalTo: likeButton.trailingAnchor,
                constant: 8
            ),
            CollectButton.centerYAnchor.constraint(
                equalTo: bottomToolbar.centerYAnchor
            ),
            CollectButton.widthAnchor.constraint(equalToConstant: 44),
            CollectButton.heightAnchor.constraint(equalToConstant: 44),

            // 右侧举报按钮
            reportButton.trailingAnchor.constraint(
                equalTo: bottomToolbar.trailingAnchor,
                constant: -12
            ),
            reportButton.centerYAnchor.constraint(
                equalTo: bottomToolbar.centerYAnchor
            ),
            reportButton.widthAnchor.constraint(equalToConstant: 44),
            reportButton.heightAnchor.constraint(equalToConstant: 44),

            // 中间评论按钮 (撑满中间空间)
            commentButton.leadingAnchor.constraint(
                equalTo: CollectButton.trailingAnchor,
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
