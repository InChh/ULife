//
//  CommentCell.swift
//  ULife
//
//  评论 Cell - 参考活动模块重写

import UIKit
import Kingfisher

class CommentCell: UITableViewCell {

    static let identifier = "CommentCell"
    
    // MARK: - UI Components
    private let avatarImageView = UIImageView()
    private let authorLabel = UILabel()
    private let timeLabel = UILabel()
    private let contentLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 头像
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarImageView)
        
        // 作者
        authorLabel.font = .systemFont(ofSize: 14, weight: .medium)
        authorLabel.textColor = .label
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(authorLabel)
        
        // 时间
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .tertiaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        // 内容
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentLabel)
        
        // 点赞按钮
        likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        likeButton.titleLabel?.font = .systemFont(ofSize: 12)
        likeButton.tintColor = .secondaryLabel
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likeButton)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 36),
            avatarImageView.heightAnchor.constraint(equalToConstant: 36),

            authorLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),

            timeLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: authorLabel.trailingAnchor, constant: 8),

            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            likeButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            likeButton.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configure
    func configure(with comment: Comment) {
        authorLabel.text = comment.author.name
        timeLabel.text = comment.createdAt.timeAgoString()
        contentLabel.text = comment.content
        likeButton.setTitle("\(comment.likeCount)", for: .normal)
        
        let isLiked = comment.isLiked
        likeButton.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .secondaryLabel
        
        // 加载头像
        if let url = URL(string: comment.author.avatarurl), !comment.author.avatarurl.isEmpty {
        avatarImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle.fill")
            )
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = .systemGray3
        }
    }
}
