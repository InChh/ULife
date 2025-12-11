//
//  CourseCell.swift
//  ULife
//
//  课程 Cell - 参考活动模块重写

import UIKit

class CourseCell: UITableViewCell {
    
    static let identifier = "CourseCell"

    // MARK: - UI Components
    private let cardView = UIView()
    private let courseNameLabel = UILabel()
    private let teacherLabel = UILabel()
    private let locationLabel = UILabel()
    private let timeLabel = UILabel()
    private let colorStripe = UIView()
    
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
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 2
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // 颜色条
        colorStripe.layer.cornerRadius = 3
        colorStripe.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(colorStripe)
        
        // 课程名
        courseNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        courseNameLabel.textColor = .label
        courseNameLabel.numberOfLines = 1
        courseNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(courseNameLabel)
        
        // 教师
        teacherLabel.font = .systemFont(ofSize: 14)
        teacherLabel.textColor = .secondaryLabel
        teacherLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(teacherLabel)
        
        // 地点
        locationLabel.font = .systemFont(ofSize: 13)
        locationLabel.textColor = .tertiaryLabel
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(locationLabel)
        
        // 时间
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .tertiaryLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(timeLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            colorStripe.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            colorStripe.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            colorStripe.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            colorStripe.widthAnchor.constraint(equalToConstant: 4),
            
            courseNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            courseNameLabel.leadingAnchor.constraint(equalTo: colorStripe.trailingAnchor, constant: 12),
            courseNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            teacherLabel.topAnchor.constraint(equalTo: courseNameLabel.bottomAnchor, constant: 6),
            teacherLabel.leadingAnchor.constraint(equalTo: courseNameLabel.leadingAnchor),
            teacherLabel.trailingAnchor.constraint(equalTo: courseNameLabel.trailingAnchor),

            locationLabel.topAnchor.constraint(equalTo: teacherLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: courseNameLabel.leadingAnchor),
            
            timeLabel.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: locationLabel.trailingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -12),
            timeLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configure
    func configure(with item: ScheduleItem, sectionSlots: [Int: (start: String, end: String)]) {
        courseNameLabel.text = item.courseName
        teacherLabel.text = "👨‍🏫 \(item.teacherName ?? "未知教师")"
        locationLabel.text = "📍 \(item.location ?? "未知地点")"
        
        let start = sectionSlots[item.startSection]?.start ?? "\(item.startSection)"
        let end = sectionSlots[item.endSection]?.end ?? "\(item.endSection)"
        timeLabel.text = "⏰ \(start)-\(end)"
        
        // 设置颜色条
        colorStripe.backgroundColor = UIColor(hex: item.colorHex) ?? .systemBlue
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
