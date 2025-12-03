//
//  CourseCell.swift
//  ULife_Local
//
//  Created by 高煜尧 on 2025-12-03.
//

import UIKit

final class CourseCell: UITableViewCell {
    static let identifier = "CourseCell"
    
    // 背景容器
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    // 时间
    private let timeLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 1
        return label
    }()
    
    // 课程名称
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
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
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with course: Course){
        containerView.backgroundColor = .white
        timeLabel.text = course.timeRange
        nameLabel.text = course.name
        locationLabel.text = course.location
        teacherLabel.text = course.teacher
    }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        [timeLabel, nameLabel, locationLabel, teacherLabel].forEach {
            containerView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            nameLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),

            locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            teacherLabel.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor),
            teacherLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            teacherLabel.leadingAnchor.constraint(greaterThanOrEqualTo: locationLabel.trailingAnchor, constant: 8)
        ])
    }
}
