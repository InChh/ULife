//
//  ActivityDetailView.swift
//  ULife
//
//  Created on 2025/12/1.
//

import UIKit

/// 活动详情视图
final class ActivityDetailView: UIView {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        return stack
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let actionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    let enrollButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("立即报名", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    let collectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("收藏", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = .systemGray5
        btn.setTitleColor(.label, for: .normal)
        btn.layer.cornerRadius = 8
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
        backgroundColor = .systemGroupedBackground
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(actionStackView)
        
        actionStackView.addArrangedSubview(collectButton)
        actionStackView.addArrangedSubview(enrollButton)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            infoStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            contentLabel.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 20),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            actionStackView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 24),
            actionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            actionStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configure(with activity: Activity) {
        titleLabel.text = activity.title
        contentLabel.text = activity.content
        
        // 加载封面图
        if let url = URL(string: activity.coverUrl) {
            loadImage(from: url)
        } else {
            coverImageView.image = UIImage(systemName: "photo")
        }
        
        // 清空旧信息
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 添加信息项
        addInfoItem(icon: "mappin.circle.fill", text: activity.location)
        addInfoItem(icon: "person.fill", text: activity.organizer)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        dateFormatter.locale = Locale(identifier: "zh_CN")
        addInfoItem(icon: "calendar", text: "\(dateFormatter.string(from: activity.startTime)) - \(dateFormatter.string(from: activity.endTime))")
        
        addInfoItem(icon: "tag.fill", text: activity.activityType.displayName)
        addInfoItem(icon: "person.3.fill", text: "\(activity.currentEnrollments)/\(activity.quota) 人")
        
        if activity.needSignIn {
            addInfoItem(icon: "checkmark.circle.fill", text: "需要签到")
        }
        
        // 更新按钮状态
        if let isEnrolled = activity.isEnrolled, isEnrolled {
            enrollButton.setTitle("已报名", for: .normal)
            enrollButton.backgroundColor = .systemGray4
            enrollButton.isEnabled = false
        } else {
            enrollButton.setTitle("立即报名", for: .normal)
            enrollButton.backgroundColor = .systemBlue
            enrollButton.isEnabled = true
        }
        
        if let isCollected = activity.isCollected, isCollected {
            collectButton.setTitle("已收藏", for: .normal)
            collectButton.backgroundColor = .systemBlue
            collectButton.setTitleColor(.white, for: .normal)
        } else {
            collectButton.setTitle("收藏", for: .normal)
            collectButton.backgroundColor = .systemGray5
            collectButton.setTitleColor(.label, for: .normal)
        }
    }
    
    private func loadImage(from url: URL) {
        coverImageView.image = UIImage(systemName: "photo")
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.coverImageView.image = image
                    }
                }
            } catch {
                // 加载失败，保持占位图
            }
        }
    }
    
    private func addInfoItem(icon: String, text: String) {
        let container = UIView()
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = 0
        
        container.addSubview(iconView)
        container.addSubview(label)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        infoStackView.addArrangedSubview(container)
    }
}

