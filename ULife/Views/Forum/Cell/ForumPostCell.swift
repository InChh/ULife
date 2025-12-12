//
//  ForumPostCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  帖子简介展示单元格 (Cell)

import Kingfisher
import UIKit
import UlifeLib

class ForumPostCell: UITableViewCell {

    // 标识符
    static let identifier = "ForumPostCell"

    // 卡片背景容器
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12

        // 设置阴影
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

    // 板块标签
    private lazy var CategoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemPurple.withAlphaComponent(0.7)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()

    //访问人数标签
    private lazy var ViewCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray2
        label.textAlignment = .right
        return label
    }()

    // 创建时间
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray2
        label.textAlignment = .right
        return label
    }()

    /// - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///UI
    private func setupUI() {
        backgroundColor = .clear  // Cell 本身透明，显示 cardView

        contentView.addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(contentLabel)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(authorLabel)
        cardView.addSubview(timeLabel)
        cardView.addSubview(CategoryLabel)
        cardView.addSubview(ViewCountLabel)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        CategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        ViewCountLabel.translatesAutoresizingMaskIntoConstraints = false

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

            CategoryLabel.centerYAnchor.constraint(
                equalTo: avatarImageView.centerYAnchor
            ),
            CategoryLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: ViewCountLabel.leadingAnchor,
                constant: -6
            ),

            ViewCountLabel.centerYAnchor.constraint(
                equalTo: avatarImageView.centerYAnchor
            ),
            ViewCountLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: timeLabel.leadingAnchor,
                constant: -6
            ),

        ])
    }
    
    /// Cell 被复用队列取出并重新显示之前
    override func prepareForReuse() {
        super.prepareForReuse()
        // 取消当前 imageView 的下载任务（防止错图/残留）
        avatarImageView.kf.cancelDownloadTask()
        // 恢复占位图或清空
        avatarImageView.image = UIImage(named: "avatar_placeholder")
    }

    /// Configure Data
    func configure(with post: PostLite) {
        let createdAtDate = ISO8601DateFormatter().date(from: post.createdAt) ?? Date()
        
        titleLabel.text = post.title
        contentLabel.text = post.summary
        authorLabel.text = post.author?.name
        timeLabel.text = createdAtDate.timeAgoString()

        // 加载提示器,加载完成前转圈动画
        avatarImageView.kf.indicatorType = .activity

//        // 处理器,下采样 (处理器原图可能很大,直接加载到 ios 内存中可能导致内存暴涨,该处理器可以先缩小图片尺寸再加载到内存中)
//        let processor = DownsamplingImageProcessor(size: avatarImageView.bounds.size)
        
        avatarImageView.kf.setImage(
            with: URL(string: post.author?.avatarUrl ?? ""),
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

        CategoryLabel.text = " \(post.boardName) "
        ViewCountLabel.text = " \(post.stats?.viewCount ?? 0)人围观 "
    }
}
