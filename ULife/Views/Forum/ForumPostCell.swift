//
//  ForumPostCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  帖子展示单元格 (Cell)

import UIKit

class ForumPostCell: UITableViewCell {

    // 标识符
    static let identifier = "ForumPostCell"


    // 卡片背景容器
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12 //设置圆角
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    // 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1  // 最多一行
        return label
    }()

    // 内容摘要
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2  // 最多两行
        return label
    }()

    // 作者头像
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5  // 占位色
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12  // 圆形头像 (宽高24)
        iv.clipsToBounds = true
        return iv
    }()

    // 作者名
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        return label
    }()

    // 标签容器(存多个标签 label)
    private lazy var tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal  // 水平排列
        stack.spacing = 6  // 标签之间的间距
        stack.alignment = .center  // 垂直居中
        stack.distribution = .fillProportionally
        return stack
    }()

    // 时间
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray2
        label.textAlignment = .right
        return label
    }()

    // - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func setupUI() {
        backgroundColor = .clear  // Cell 本身透明，显示 cardView
        selectionStyle = .gray  // 点击时要变灰

        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(contentLabel)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(authorLabel)
        cardView.addSubview(timeLabel)
        cardView.addSubview(tagsStackView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // CardView 布局 (留出边距)
            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8
            ),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            cardView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            ),

            // 标题布局
            titleLabel.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: 16
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -16
            ),

            // 内容摘要布局
            contentLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            contentLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            contentLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),

            // 头像布局 (左下角)
            avatarImageView.topAnchor.constraint(
                equalTo: contentLabel.bottomAnchor,
                constant: 12
            ),
            avatarImageView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: 16
            ),
            avatarImageView.widthAnchor.constraint(equalToConstant: 24),
            avatarImageView.heightAnchor.constraint(equalToConstant: 24),
            avatarImageView.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -16
            ),

            // 标签容器布局 (在作者名右边)
            tagsStackView.centerYAnchor.constraint(
                equalTo: authorLabel.centerYAnchor
            ),
            tagsStackView.leadingAnchor.constraint(
                equalTo: authorLabel.trailingAnchor,
                constant: 15
            ),
            // 标签右位置小于时间 label 的左位置
            tagsStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: timeLabel.leadingAnchor,
                constant: -8
            ),

            // 作者名布局
            authorLabel.centerYAnchor.constraint(
                equalTo: avatarImageView.centerYAnchor
            ),
            authorLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: 8
            ),

            // 时间布局 (右下角)
            timeLabel.centerYAnchor.constraint(
                equalTo: avatarImageView.centerYAnchor
            ),
            timeLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -16
            ),
        ])
    }

    // MARK: - Configure Data
    func configure(with post: ForumPost) {
        titleLabel.text = post.title
        contentLabel.text = post.content
        authorLabel.text = post.authorName
        timeLabel.text = post.createTime.timeAgoString()
        // todo 加载图片
        
        // 动态生成标签
        setupTags(post.tags)
    }

    // 生成标签
    private func setupTags(_ tags: [String]) {
        // 清空之前的视图 (因为 Cell 是复用的，不清空会重叠)
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        //添加新标签
        for tagText in tags {
            let label = createTagLabel(text: tagText)
            tagsStackView.addArrangedSubview(label)
        }
    }

    // 创建统一风格的标签 Label
    private func createTagLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = " \(text) "  // 前后加个空格，增加内边距的视觉效果
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue  // 文字蓝色
        label.backgroundColor = .systemBlue.withAlphaComponent(0.1)  // 背景淡蓝
        label.layer.cornerRadius = 4
        return label
    }
}
