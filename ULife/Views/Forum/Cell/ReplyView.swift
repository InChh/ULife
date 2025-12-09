//
//  ReplyView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//  回复视图(每一条评论的回复就是一个ReplyView)

import UIKit
import Kingfisher

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
        btn.semanticContentAttribute = .forceRightToLeft //靠右对齐,图片位于文本的右侧
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.tintColor = .secondaryLabel
        btn.setTitleColor(.secondaryLabel, for: .normal)
        return btn
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupUI() {
        backgroundColor = .systemBackground

        [avatarImageView, nameLabel, replyToLabel, contentLabel, likeButton]
            .forEach { item in
                addSubview(item)
                item.translatesAutoresizingMaskIntoConstraints = false
            }
        
        NSLayoutConstraint.activate([
            // 头像
            avatarImageView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: 6
            ),
            avatarImageView.leadingAnchor.constraint(
                equalTo: leadingAnchor
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
    

    /// 绑定事件
    private func setupBindings() {
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
    }
    
    @objc private func handleTap() {
        onTap?()
    }

    @objc private func handleLikeButtonTap() {
        onLikeTap?()
    }

    func configure(with reply: Comment) {
        nameLabel.text = reply.author.name
        
        if let to = reply.replyTo {
            replyToLabel.text = "回复 \(to.name)"
        } else {
            replyToLabel.text = ""
        }
        
        
        contentLabel.text = reply.content
        
        //加载图片
        // 加载提示器,加载完成前转圈动画
        avatarImageView.kf.indicatorType = .activity

//        // 处理器,下采样 (处理器原图可能很大,直接加载到 ios 内存中可能导致内存暴涨,该处理器可以先缩小图片尺寸再加载到内存中)
//        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        
        avatarImageView.kf.setImage(
            with: URL(string: reply.author.avatarurl),
            placeholder: UIImage(named: "avatar_placeholder"),
            options: [
                //.processor(processor),
                .scaleFactor(UIScreen.main.scale), //告诉 Kingfisher 当前屏幕的缩放因子
                .transition(.fade(0.25)), // 渐变动画
                //.cacheOriginalImage, //默认情况下，Kingfisher 只会缓存“处理后”（小图+圆角）的图片。加上这个选项后，Kingfisher 会同时缓存服务器下载的原始大图。
            ],
            progressBlock: nil
        ) { result in
            switch result {
            case .success(let value):
                print("Loaded: \(value.source.url?.absoluteString ?? "")")
                break
            case .failure(let error):
                // 可根据需要重试或者记录日志
                print("KF load failed: \(error.localizedDescription)")
            }
        }

        
        // 根据点赞状态更新 UI
        let baseCount = reply.likeCount
        let displayCount = baseCount + (reply.isLiked ? 1 : 0)
        // 点赞数为 0 时不显示数字，否则显示具体数量
        let title = displayCount == 0 ? "" : "\(displayCount)"
        likeButton.setTitle(title, for: .normal)
        let color: UIColor = reply.isLiked ? .systemRed : .secondaryLabel
        let imageName = reply.isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = color
        likeButton.setTitleColor(color, for: .normal)
    }
}

