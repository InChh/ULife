//
//  CourseCell.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-03.
//

import UIKit

final class CourseCell: UITableViewCell {
    static let identifier = "CourseCell"


    // 白色卡片背景
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()


    // 课程ID与星期
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()


    // 课程名
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()


    // 时间
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()


    // 教室
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()


    // 任课老师
    private let teacherLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        label.textAlignment = .right
        return label
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupLayout()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(with course: Course) {
        if course.color == .white {
            containerView.backgroundColor = course.color
        }else{
            containerView.backgroundColor = course.color.withAlphaComponent(0.15)
        }
        idLabel.text = "课程ID：\(course.courseId)"
        nameLabel.text = course.name
        timeLabel.text = "\(weekdayText(course.dayOfWeek)): \(course.timeRange)"
        locationLabel.text = course.location
        teacherLabel.text = course.teacher
    }


    private func setupLayout() {
        contentView.addSubview(containerView)
        [idLabel, nameLabel, timeLabel, locationLabel, teacherLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false


        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),


            idLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            idLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            idLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),


            nameLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),


            timeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),


            locationLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),


            teacherLabel.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor),
            teacherLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            teacherLabel.leadingAnchor.constraint(greaterThanOrEqualTo: locationLabel.trailingAnchor, constant: 8)
        ])
    }


    private func weekdayText(_ day: Int) -> String {
        let names = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        let idx = day - 1
        if idx >= 0 && idx < names.count {
            return names[idx]
        }
        return "周\(day)"
    }
}





