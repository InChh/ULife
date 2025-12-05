//
//  ProfileHeaderView.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  个人中心头部视图

import UIKit

class ProfileHeaderView: UIView {
    
    // MARK: - UI Components
    
    // 头像视图
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.isUserInteractionEnabled = true
        
        // 添加默认头像
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        imageView.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        imageView.tintColor = .systemGray3
        
        return imageView
    }()
    
    // 编辑头像按钮 - 缩小尺寸
    lazy var editAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        
        // 使用更小的相机图标
        let config = UIImage.SymbolConfiguration(pointSize: 6, weight: .medium)
        button.setImage(UIImage(systemName: "camera.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10 // 缩小圆角半径
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBackground.cgColor
        
        // 添加轻微阴影
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 2
        
        return button
    }()
    
    // 用户姓名
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    // 学号
    lazy var studentIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    // 学院信息
    lazy var academicLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    // 个人简介
    lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 3  // 增加到3行，确保内容显示完整
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    // 统计信息容器
    private lazy var statsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 统计项数组
    private var statsViews: [UIView] = []
    
    // 编辑资料按钮
    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("编辑资料", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }()
    
    // 主容器视图 - 将所有内容放在一个容器中，方便管理
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // 使用容器视图
        addSubview(containerView)
        
        // 添加所有子视图到容器
        containerView.addSubview(avatarImageView)
        containerView.addSubview(editAvatarButton)
        containerView.addSubview(nameLabel)
        containerView.addSubview(studentIdLabel)
        containerView.addSubview(academicLabel)
        containerView.addSubview(bioLabel)
        containerView.addSubview(statsContainer)
        containerView.addSubview(editProfileButton)
        
        setupStatsViews()
    }
    
    private func setupStatsViews() {
        let stats = [
            ("本周课程", "24节"),
            ("论坛活跃", "12帖"),
            ("加入天数", "98天")
        ]
        
        statsViews = stats.map { createStatView(title: $0.0, value: $0.1) }
        
        let stackView = UIStackView(arrangedSubviews: statsViews)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        statsContainer.addSubview(stackView)
        
        // 统计容器内部约束
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func createStatView(title: String, value: String) -> UIView {
        let container = UIView()
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupConstraints() {
        // 确保所有视图都有自动布局约束
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        editAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        studentIdLabel.translatesAutoresizingMaskIntoConstraints = false
        academicLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // 容器视图约束
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 头像约束
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            avatarImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // 编辑头像按钮 - 缩小尺寸：20x20，位置微调
            editAvatarButton.widthAnchor.constraint(equalToConstant: 20),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 20),
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 0),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 0),
            
            // 姓名标签 - 确保有最小高度
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            // 学号标签
            studentIdLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            studentIdLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            studentIdLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            studentIdLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            // 学院信息标签
            academicLabel.topAnchor.constraint(equalTo: studentIdLabel.bottomAnchor, constant: 4),
            academicLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            academicLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            academicLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            // 个人简介标签 - 移除固定高度约束，使用动态高度
            bioLabel.topAnchor.constraint(equalTo: academicLabel.bottomAnchor, constant: 12),
            bioLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            bioLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            
            // 统计容器
            statsContainer.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 20),
            statsContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statsContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            statsContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // 编辑资料按钮
            editProfileButton.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 20),
            editProfileButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            editProfileButton.widthAnchor.constraint(equalToConstant: 120),
            editProfileButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 容器底部约束（重要！确保视图能正确计算高度）
            editProfileButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Layout Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 确保头像始终是圆形
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        
        // 确保编辑头像按钮是圆形
        editAvatarButton.layer.cornerRadius = editAvatarButton.bounds.width / 2
    }
    
    // MARK: - Public Methods
    
    func configure(with user: User) {
        nameLabel.text = user.displayName
        studentIdLabel.text = "学号: \(user.studentId)"
        academicLabel.text = user.academicInfo
        bioLabel.text = user.bio ?? "这个人很懒，还没有填写个人简介"
        
        // 如果有头像URL，可以加载头像（这里用模拟数据）
        if let avatar = user.avatar, !avatar.isEmpty {
            // 实际项目中这里应该加载网络图片
            avatarImageView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .thin)
            avatarImageView.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
            avatarImageView.tintColor = .systemBlue
        }
        
        // 强制布局更新
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - 计算合适的高度
    
    func calculateHeight() -> CGFloat {
        // 计算视图的总高度
        let avatarHeight: CGFloat = 100
        let avatarTopMargin: CGFloat = 30
        let nameTopMargin: CGFloat = 16
        let nameHeight: CGFloat = 30
        let studentIdHeight: CGFloat = 20
        let academicHeight: CGFloat = 20
        let spacing1: CGFloat = 4 // name 到 studentId
        let spacing2: CGFloat = 4 // studentId 到 academic
        let bioTopMargin: CGFloat = 12
        let statsTopMargin: CGFloat = 20
        let statsHeight: CGFloat = 80
        let buttonTopMargin: CGFloat = 20
        let buttonHeight: CGFloat = 40
        let bottomMargin: CGFloat = 20
        
        // 计算bioLabel的高度
        let bioWidth = UIScreen.main.bounds.width - 80 // 40 + 40
        let bioText = bioLabel.text ?? ""
        let bioHeight = bioText.height(withConstrainedWidth: bioWidth, font: bioLabel.font)
        let bioMaxHeight: CGFloat = bioLabel.font.lineHeight * 3 // 最多3行
        let bioActualHeight = min(bioHeight, bioMaxHeight)
        
        let totalHeight = avatarTopMargin + avatarHeight + nameTopMargin + nameHeight + spacing1 + studentIdHeight + spacing2 + academicHeight + bioTopMargin + bioActualHeight + statsTopMargin + statsHeight + buttonTopMargin + buttonHeight + bottomMargin
        
        return totalHeight
    }
}

// MARK: - 辅助扩展，用于计算文本高度
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                           options: .usesLineFragmentOrigin,
                                           attributes: [.font: font],
                                           context: nil)
        return ceil(boundingBox.height)
    }
}
