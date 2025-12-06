//
//  ReplyView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//  回复视图（用于 UIStackView）

import UIKit

class ReplyView: UIView {
    
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .systemGray5
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 14  // 稍微大一点的头像
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        return lbl
    }()

    private let replyToLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = .secondaryLabel
        return lbl
    }()

    private let contentLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.numberOfLines = 0
        return lbl
    }()

    let likeButton: UIButton = {
        let btn = UIButton(type: .system)

        btn.setImage(
            UIImage(
                systemName: "heart",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 10,
                    weight: .regular
                )
            ),
            for: .normal
        )
        btn.setTitle("0", for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 4
        clipsToBounds = true

        [avatarImageView, nameLabel, replyToLabel, contentLabel, likeButton]
            .forEach {
                addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }

        NSLayoutConstraint.activate([
            // 头像
            avatarImageView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 6
            ),
            avatarImageView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
            ),
            avatarImageView.widthAnchor.constraint(equalToConstant: 28),
            avatarImageView.heightAnchor.constraint(equalToConstant: 28),

            // 用户名（跟在头像后面）
            nameLabel.topAnchor.constraint(
                equalTo: avatarImageView.topAnchor,
                constant: 2
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.trailingAnchor,
                constant: 8
            ),

            replyToLabel.centerYAnchor.constraint(
                equalTo: nameLabel.centerYAnchor
            ),
            replyToLabel.leadingAnchor.constraint(
                equalTo: nameLabel.trailingAnchor,
                constant: 6
            ),

            likeButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            likeButton.centerYAnchor.constraint(
                equalTo: nameLabel.centerYAnchor
            ),

            contentLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 4
            ),
            contentLabel.leadingAnchor.constraint(
                equalTo: nameLabel.leadingAnchor
            ),
            contentLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            contentLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -6
            ),
        ])
    }

    func configure(with reply: CommentReply) {
        nameLabel.text = reply.authorName

        if let to = reply.repliedToUser {
            replyToLabel.text = "回复 \(to)"
        } else {
            replyToLabel.text = ""
        }

        contentLabel.text = reply.content
    }
}

