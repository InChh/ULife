//
//  CommentCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//  评论单元格元素

// View/CommentCell.swift
import UIKit

class CommentCell: UITableViewCell {
    static let identifier = "CommentCell"

    //评论的回复数组
    private var replies: [CommentReply] = []

    // MARK: - UI Components

    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16  // 稍微大一点的头像
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0  // 多行
        return label
    }()

    // 点赞按钮 (只显示图标和数量)
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(
            pointSize: 14,
            weight: .regular
        )
        button.setImage(
            UIImage(systemName: "heart", withConfiguration: config),
            for: .normal
        )
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.semanticContentAttribute = .forceRightToLeft  // 标题在图标右边
        return button
    }()

    //评论回复的 StackView
    private lazy var repliesStackView: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .systemBackground
        stack.axis = .vertical
        stack.spacing = 8  // 回复之间的间距
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init & Setup
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        

        [
            avatarImageView, authorLabel, timeLabel, contentLabel, likeButton, repliesStackView

        ]
        .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        

        contentView.addSubview(avatarImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(repliesStackView)

        NSLayoutConstraint.activate([
            // 头像
            avatarImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            avatarImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),

            // 作者
            authorLabel.topAnchor.constraint(
                equalTo: avatarImageView.topAnchor,
                constant: 2
            ),
            authorLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: 8
            ),

            // 时间
            timeLabel.centerYAnchor.constraint(
                equalTo: authorLabel.centerYAnchor
            ),
            timeLabel.leadingAnchor.constraint(
                equalTo: authorLabel.trailingAnchor,
                constant: 8
            ),

            // 点赞按钮 —— 放右上角
            likeButton.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            likeButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),

            // 内容
            contentLabel.topAnchor.constraint(
                equalTo: authorLabel.bottomAnchor,
                constant: 4
            ),
            contentLabel.leadingAnchor.constraint(
                equalTo: authorLabel.leadingAnchor
            ),
            contentLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            
            
            // 让回复列表紧跟内容之后
            repliesStackView.topAnchor.constraint(
                equalTo: contentLabel.bottomAnchor,
                constant: 8
            ),
            repliesStackView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            repliesStackView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            repliesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with comment: Comment) {
        authorLabel.text = comment.authorName
        timeLabel.text = comment.createTime.timeAgoString()
        contentLabel.text = comment.content
        likeButton.setTitle("\(comment.likeCount)", for: .normal)
        // 假设头像已加载

        // 更新回复列表
        let newReplies = comment.replies ?? []
        self.replies = newReplies
        updateRepliesStackView(with: newReplies)
    }
    
    // 更新回复 StackView
    private func updateRepliesStackView(with replies: [CommentReply]) {
        // 清除所有现有的回复视图
        repliesStackView.arrangedSubviews.forEach { view in
            repliesStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // 如果没有回复，隐藏 StackView（隐藏时高度自动为 0）
        if replies.isEmpty {
            repliesStackView.isHidden = true
            return
        }
        
        // 显示 StackView
        repliesStackView.isHidden = false
        
        // 为每个回复创建 ReplyView 并添加到 StackView
        for reply in replies {
            let replyView = ReplyView()
            replyView.configure(with: reply)
            repliesStackView.addArrangedSubview(replyView)
        }
        
        // 强制更新布局（确保 StackView 正确计算高度）
        repliesStackView.setNeedsLayout()
        repliesStackView.layoutIfNeeded()
    }
}
