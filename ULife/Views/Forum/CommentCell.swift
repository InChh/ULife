//
//  CommentCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//


// View/CommentCell.swift
import UIKit

class CommentCell: UITableViewCell {
    static let identifier = "CommentCell"
    
    // MARK: - UI Components
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16 // 稍微大一点的头像
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
        label.numberOfLines = 0 // 多行
        return label
    }()
    
    // 点赞按钮 (只显示图标和数量)
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.semanticContentAttribute = .forceRightToLeft // 标题在图标右边
        return button
    }()
    
    // MARK: - Init & Setup
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [avatarImageView, authorLabel, timeLabel, contentLabel, likeButton])
        // ... (省略 StackView 布局代码，使用常规 Anchor 布局更清晰)
        
        [avatarImageView, authorLabel, timeLabel, contentLabel, likeButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        contentView.addSubview(avatarImageView)
        contentView.addSubview(authorLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            // 头像
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // 作者
            authorLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            
            // 时间
            timeLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: authorLabel.trailingAnchor, constant: 8),
            
            // 内容
            contentLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // 点赞按钮 (右下角)
            likeButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with comment: Comment) {
        authorLabel.text = comment.authorName
        timeLabel.text = comment.timeAgo
        contentLabel.text = comment.content
        likeButton.setTitle("\(comment.likeCount)", for: .normal)
        // 假设头像已加载
    }
}