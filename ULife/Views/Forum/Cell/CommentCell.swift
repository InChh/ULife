//
//  CommentCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//  评论单元格元素

// View/CommentCell.swift
import UIKit
import Kingfisher
import UlifeLib

class CommentCell: UITableViewCell {

    static let identifier = "CommentCell"
    
    //评论的回复数组
    private var replies: [Comment] = []

    // 对整条评论点击的回调
    var onCommentTap: (() -> Void)?

    // 点赞整条评论的回调
    var onCommentLikeTap: (() -> Void)?

    // 对某一条回复点击的回调
    var onReplyTap: ((Comment) -> Void)?

    // 点赞某一条回复的回调
    var onReplyLikeTap: ((Comment) -> Void)?
    
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

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        [
            avatarImageView, authorLabel, timeLabel, contentLabel, likeButton, repliesStackView
        ]
        .forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false }

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
            repliesStackView.leadingAnchor.constraint(
                equalTo: contentLabel.leadingAnchor
            ),
            repliesStackView.trailingAnchor.constraint(
                equalTo: contentLabel.trailingAnchor
            ),
            repliesStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -12
            ),
        ])
    }
    
    
    /// 绑定事件
    private func setupBindings() {
        // 给整个 cell 添加点击事件（用于“回复这条评论”）
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCommentTap)
        )
        contentView.addGestureRecognizer(tap)

        // 点赞按钮点击事件
        likeButton.addTarget(
            self,
            action: #selector(handleLikeButtonTap),
            for: .touchUpInside
        )
    }
    
    @objc private func handleCommentTap() {
        onCommentTap?()
    }

    @objc private func handleLikeButtonTap() {
        onCommentLikeTap?()
    }
    
    /// Cell 被复用队列取出并重新显示之前
    override func prepareForReuse() {
        super.prepareForReuse()
        // 取消当前 imageView 的下载任务（防止错图/残留）
        avatarImageView.kf.cancelDownloadTask()
        // 恢复占位图或清空
        avatarImageView.image = UIImage(named: "avatar_placeholder")
    }
    
    
    // 配置 cell
    func configure(
        with comment: Comment
    ) {
        let formatter = ISO8601DateFormatter()
        let createdAtDate = formatter.date(from: comment.createdAt) ?? Date()
        authorLabel.text = comment.author?.name
        timeLabel.text = createdAtDate.timeAgoString()
        contentLabel.text = comment.content
        
        
        // 加载图片
        // 加载提示器,加载完成前转圈动画
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: URL(string: comment.author?.avatarUrl ?? ""),
            placeholder: UIImage(named: "avatar_placeholder"),
            options: [
               
                .scaleFactor(UIScreen.main.scale), //告诉 Kingfisher 当前屏幕的缩放因子
                .transition(.fade(0.25)), // 渐变动画
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
        

        //根据是否点赞更新 button 图标
        let displayCount = comment.stats?.likeCount ?? 0
        // 重要：无论是否为 0，都要重置标题，避免 cell 复用时显示旧的数字
        let title = displayCount == 0 ? "" : "\(displayCount)"
        likeButton.setTitle(title, for: .normal)
        let color: UIColor = comment.userInteraction?.isLiked == true ? .systemRed : .secondaryLabel
        let imageName = comment.userInteraction?.isLiked == true ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = color
        likeButton.setTitleColor(color, for: .normal)

        // 更新回复列表 comments 中
        let newReplies = comments.filter { item in
            // 检查 parentid 是否存在 (非 nil)
            // 如果存在，检查其值是否等于目标 ID
            return item.parentId == comment.id
        }
        
        self.replies = newReplies
        updateRepliesStackView(with: newReplies)
    }

    // 更新回复 StackView
    private func updateRepliesStackView(
        with replies: [Comment]
    ) {
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

        // 有回复
        repliesStackView.isHidden = false
        // 为每个回复创建 ReplyView 并添加到 StackView
        for reply in replies {
            let replyView = ReplyView()
            
            replyView.configure(with: reply)

            // 为replyView绑定事件
            replyView.onTap = { [weak self] in
                self?.onReplyTap?(reply)
            }
            replyView.onLikeTap = { [weak self] in
                self?.onReplyLikeTap?(reply)
            }

            repliesStackView.addArrangedSubview(replyView)
        }

        // 强制更新布局（确保 StackView 正确计算高度）
        repliesStackView.setNeedsLayout()
        repliesStackView.layoutIfNeeded()
    }
}
