//
//  ActivityCell.swift
//  ULife
//
//  Created on 2025/12/1.
//

import UIKit

/// 活动列表Cell
final class ActivityCell: UITableViewCell {
    static let identifier = "ActivityCell"
    
    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let enrollmentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemBlue
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(enrollmentLabel)
        
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        enrollmentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            coverImageView.widthAnchor.constraint(equalToConstant: 120),
            coverImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            timeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 4),
            
            enrollmentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            enrollmentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            enrollmentLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            enrollmentLabel.bottomAnchor.constraint(lessThanOrEqualTo: coverImageView.bottomAnchor)
        ])
    }
    
    func configure(with activity: ActivityListItem) {
        titleLabel.text = activity.title
        locationLabel.text = "📍 \(activity.location)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        timeLabel.text = "🕐 \(formatter.string(from: activity.startTime))"
        
        enrollmentLabel.text = "👥 \(activity.currentEnrollments)/\(activity.quota)"
        
        // 加载封面图
        if let url = URL(string: activity.coverUrl) {
            loadImage(from: url)
        } else {
            coverImageView.image = UIImage(systemName: "photo")
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
}

