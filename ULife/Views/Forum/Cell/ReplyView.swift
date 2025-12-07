//
//  ReplyView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//  回复视图(每一条评论的回复就是一个ReplyView)

import UIKit

class ReplyView: UIView {
    
    /// 外部设置的点击回调，用于“回复这条回复”
    var onTap: (() -> Void)?
    /// 点赞按钮点击回调
    var onLikeTap: (() -> Void)?
    
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
        btn.semanticContentAttribute = .forceRightToLeft
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.tintColor = .secondaryLabel
        btn.setTitleColor(.secondaryLabel, for: .normal)
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

        // 给 ReplyView 添加点击事件（用于“回复这条回复”）
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
        addGestureRecognizer(tap)

        // 点赞按钮点击事件
        likeButton.addTarget(
            self,
            action: #selector(handleLikeButtonTap),
            for: .touchUpInside
        )

        
        
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

    func configure(with reply: CommentReply, isLiked: Bool) {
        nameLabel.text = reply.authorName

        if let to = reply.repliedToUser {
            replyToLabel.text = "回复 \(to)"
        } else {
            replyToLabel.text = ""
        }

        contentLabel.text = reply.content

        // 根据点赞状态更新 UI
        let baseCount = reply.likeCount
        let displayCount = baseCount + (isLiked ? 1 : 0)
        // 点赞数为 0 时不显示数字，否则显示具体数量
        let title = displayCount == 0 ? "" : "\(displayCount)"
        likeButton.setTitle(title, for: .normal)

        let color: UIColor = isLiked ? .systemRed : .secondaryLabel
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = color
        likeButton.setTitleColor(color, for: .normal)
    }

    @objc private func handleTap() {
        onTap?()
    }

    @objc private func handleLikeButtonTap() {
        onLikeTap?()
    }
}

