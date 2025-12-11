//
//  ForumPostCell.swift
//  ULife
//
//  论坛帖子 Cell - 参考活动模块重写

import UIKit
import Kingfisher

class ForumPostCell: UITableViewCell {

    static let identifier = "ForumPostCell"

    // MARK: - UI Components
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let authorLabel = UILabel()
    private let boardLabel = UILabel()
    private let timeLabel = UILabel()
    private let statsLabel = UILabel()
    private let avatarImageView = UIImageView()

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
        
        // Card 容器
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 3
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // 头像
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = .systemGray5
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(avatarImageView)

        // 标题
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        // 摘要
        summaryLabel.font = .systemFont(ofSize: 14)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 2
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(summaryLabel)
        
        // 作者
        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .secondaryLabel
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(authorLabel)
        
        // 板块
        boardLabel.font = .systemFont(ofSize: 12)
        boardLabel.textColor = .systemBlue
        boardLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(boardLabel)
        
        // 时间
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .tertiaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(timeLabel)
        
        // 统计
        statsLabel.font = .systemFont(ofSize: 12)
        statsLabel.textColor = .tertiaryLabel
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(statsLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            authorLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            boardLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            boardLabel.leadingAnchor.constraint(equalTo: authorLabel.trailingAnchor, constant: 12),

            timeLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: boardLabel.trailingAnchor, constant: 12),

            statsLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            statsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statsLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configure
    func configure(with post: PostLite) {
        titleLabel.text = post.title
        summaryLabel.text = post.summary ?? "无内容"
        authorLabel.text = post.author.name
        boardLabel.text = "[\(post.boardName ?? "未知板块")]"
        timeLabel.text = post.createdAt.timeAgoString()

        let stats = "👁 \(post.stats.viewCount)  👍 \(post.stats.likeCount)  💬 \(post.stats.commentCount)"
        statsLabel.text = stats
        
        // 加载头像
        if let url = URL(string: post.author.avatarurl), !post.author.avatarurl.isEmpty {
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
