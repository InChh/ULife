//
//  ActivityDetailViewController.swift
//  ULife
//
//  Created on 2025/12/1.
//

import UIKit

/// 活动详情页面
final class ActivityDetailViewController: UIViewController {
    
    private let activityId: String
    private let detailView = ActivityDetailView()
    private let activityService = ActivityService.shared
    
    private var activity: Activity?
    
    init(activityId: String) {
        self.activityId = activityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadActivityDetail()
    }
    
    private func setupUI() {
        title = "活动详情"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(detailView)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        detailView.enrollButton.addTarget(self, action: #selector(enrollButtonTapped), for: .touchUpInside)
        detailView.collectButton.addTarget(self, action: #selector(collectButtonTapped), for: .touchUpInside)
    }
    
    private func loadActivityDetail() {
        Task {
            do {
                let activity = try await activityService.fetchActivityDetail(id: activityId)
                await MainActor.run {
                    self.activity = activity
                    self.detailView.configure(with: activity)
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
    }
    
    @objc private func enrollButtonTapped() {
        guard let activity = activity else { return }
        
        // 检查是否已报名
        if activity.isEnrolled == true {
            showCancelEnrollmentAlert()
        } else {
            showEnrollmentAlert()
        }
    }
    
    @objc private func collectButtonTapped() {
        guard let activity = activity else { return }
        
        Task {
            do {
                if activity.isCollected == true {
                    try await activityService.uncollectActivity(activityId: activityId)
                    await MainActor.run {
                        Toast.show("已取消收藏", style: .success)
                        loadActivityDetail()
                    }
                } else {
                    try await activityService.collectActivity(activityId: activityId)
                    await MainActor.run {
                        Toast.show("已收藏", style: .success)
                        loadActivityDetail()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
    }
    
    private func showEnrollmentAlert() {
        let alert = UIAlertController(title: "报名活动", message: "请确认您的报名信息", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "姓名"
            // 可以从用户信息中自动填充
        }
        
        alert.addTextField { textField in
            textField.placeholder = "学号"
            textField.keyboardType = .numberPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "专业"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "手机号（可选）"
            textField.keyboardType = .phonePad
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认报名", style: .default) { [weak self] _ in
            self?.handleEnrollment(alert: alert)
        })
        
        present(alert, animated: true)
    }
    
    private func handleEnrollment(alert: UIAlertController) {
        guard let nameField = alert.textFields?[0],
              let studentIdField = alert.textFields?[1],
              let majorField = alert.textFields?[2],
              let phoneField = alert.textFields?[3] else {
            return
        }
        
        let userName = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let studentId = studentIdField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let major = majorField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !userName.isEmpty, !studentId.isEmpty, !major.isEmpty else {
            Toast.show("请填写完整信息", style: .error)
            return
        }
        
        Task {
            do {
                try await activityService.enrollActivity(
                    activityId: activityId,
                    userName: userName,
                    studentId: studentId,
                    major: major,
                    phoneNumber: phone?.isEmpty == false ? phone : nil
                )
                await MainActor.run {
                    Toast.show("报名成功", style: .success)
                    loadActivityDetail()
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
    }
    
    private func showCancelEnrollmentAlert() {
        let alert = UIAlertController(
            title: "取消报名",
            message: "确定要取消报名吗？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
            self?.handleCancelEnrollment()
        })
        
        present(alert, animated: true)
    }
    
    private func handleCancelEnrollment() {
        Task {
            do {
                try await activityService.cancelEnrollment(activityId: activityId)
                await MainActor.run {
                    Toast.show("已取消报名", style: .success)
                    loadActivityDetail()
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        let message = error.localizedDescription
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

