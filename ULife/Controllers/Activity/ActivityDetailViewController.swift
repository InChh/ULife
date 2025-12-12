//
//  ActivityDetailViewController.swift
//  ULife
//
//  Mock detail page for Activity module
//

import UIKit
import UlifeLib

final class ActivityDetailViewController: UIViewController {
    
    private var activity: Activity
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let locationLabel = UILabel()
    private let organizerLabel = UILabel()
    private let contentLabel = UILabel()
    
    private let enrollButton = UIButton(type: .system)
    private let collectButton = UIButton(type: .system)
    
    init(activity: Activity) {
        self.activity = activity
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "活动详情"
        view.backgroundColor = .systemBackground
        setupUI()
        render()
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.numberOfLines = 0
        
        metaLabel.font = .systemFont(ofSize: 14, weight: .medium)
        metaLabel.textColor = .secondaryLabel
        metaLabel.numberOfLines = 0
        
        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.textColor = .secondaryLabel
        
        organizerLabel.font = .systemFont(ofSize: 14)
        organizerLabel.textColor = .secondaryLabel
        
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        
        enrollButton.layer.cornerRadius = 10
        enrollButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        enrollButton.backgroundColor = .systemBlue
        enrollButton.setTitleColor(.white, for: .normal)
        enrollButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        enrollButton.addTarget(self, action: #selector(handleEnroll), for: .touchUpInside)
        
        collectButton.layer.cornerRadius = 10
        collectButton.layer.borderColor = UIColor.systemBlue.cgColor
        collectButton.layer.borderWidth = 1
        collectButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        collectButton.setTitleColor(.systemBlue, for: .normal)
        collectButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        collectButton.addTarget(self, action: #selector(handleCollect), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [enrollButton, collectButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        
        [titleLabel, metaLabel, locationLabel, organizerLabel, contentLabel, buttonStack].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func render() {
        titleLabel.text = activity.title
        
        let isoFormatter = ISO8601DateFormatter()
        let startTimeDate = isoFormatter.date(from: activity.startTime) ?? Date()
        let endTimeDate = isoFormatter.date(from: activity.endTime) ?? Date()

        let df = DateFormatter()
        df.dateFormat = "M月d日 HH:mm"
        let timeText = "\(df.string(from: startTimeDate)) - \(df.string(from: endTimeDate))"
        
        metaLabel.text = "\(ActivityType(rawValue: activity.activityType)?.displayName ?? "未知") · \(timeText)"
        locationLabel.text = "地点：\(activity.location)"
        organizerLabel.text = "主办方：\(activity.organizer)"
        contentLabel.text = activity.content
        
        updateButtons()
    }
    
    private func updateButtons() {
        if activity.isEnrolled ?? false {
            enrollButton.setTitle("取消报名", for: .normal)
            enrollButton.backgroundColor = .systemGray
        } else {
            enrollButton.setTitle("报名参加", for: .normal)
            enrollButton.backgroundColor = .systemBlue
        }
        
        let collectTitle = activity.isCollected == true ? "取消收藏" : "收藏"
        collectButton.setTitle(collectTitle, for: .normal)
    }
    
    @objc private func handleEnroll() {
        Task {
            if activity.isEnrolled ?? false {
                do {
                    try await NetworkManager.client.unrollActivity(activityId: activity.id)
                    activity.isEnrolled = false
                    showToast("已取消报名")
                } catch {
                    showToast("取消失败")
                }
            } else {
                do {

                    let input = EnrollActivityRequest(activityId: activity.id,
                                                     userName: "测试用户",
                                                        studentId: "2025123456",
                                                        major: "软件工程",
                                                      phoneNumber: "13800000000")
                        
                    try await NetworkManager.client.enrollActivity(input: input)
                    activity.isEnrolled = true
                    showToast("报名成功")
                } catch Error.LogicError(message: let msg) {
                    showToast(msg)
                } catch {
                    showToast("报名失败")
                }
            }
            updateButtons()
        }
    }
    
    @objc private func handleCollect() {
        Task {
            if activity.isCollected ?? false {
                do {
                    try await NetworkManager.client.uncollectActivity(activityId: activity.id)
                    activity.isCollected = false
                    showToast("已取消收藏")
                } catch {
                    showToast("操作失败")
                }
            } else {
                do {
                    try await NetworkManager.client.collectActivity(activityId: activity.id)
                    activity.isCollected = true
                    showToast("已收藏")
                } catch {
                    showToast("操作失败")
                }
            }
            updateButtons()
        }
    }
    
    private func showToast(_ text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true)
        }
    }
}

