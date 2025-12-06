//
//  Toast.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//


import UIKit

class Toast {
    
    // MARK: - 配置项
    
    enum Style {
        case normal  // 普通提示 (白色图标)
        case success // 成功 (绿色图标)
        case error   // 错误 (红色图标)
    }
    
    // 单例，用于管理当前的弹窗，防止同时弹出多个重叠
    static let shared = Toast()
    
    private var currentToastView: UIView?
    private var hideTimer: Timer?
    
    private init() {} // 私有化初始化方法
    
    // MARK: - 公开调用方法
    
    /// 显示 Toast 提示
    /// - Parameters:
    ///   - message: 提示文字
    ///   - style: 样式 (.normal, .success, .error)
    ///   - duration: 持续时间 (默认 2.0 秒)
    static func show(_ message: String, style: Style = .normal, duration: TimeInterval = 2.0) {
        // 确保在主线程执行 UI 操作
        DispatchQueue.main.async {
            shared.showToast(message: message, style: style, duration: duration)
        }
    }
    
    // MARK: - 内部实现逻辑
    
    private func showToast(message: String, style: Style, duration: TimeInterval) {
        // 1. 如果当前已有 Toast，先移除
        removeCurrentToast()
        
        // 2. 获取当前窗口 (兼容 iOS 13+ SceneDelegate)
        guard let window = getKeyWindow() else { return }
        
        // 3. 创建 Toast 视图
        let toastView = createToastView(message: message, style: style)
        toastView.alpha = 0
        toastView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // 初始缩小，用于弹出动画
        
        window.addSubview(toastView)
        currentToastView = toastView
        
        // 4. 设置约束 (居中显示)
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toastView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            // 限制最大宽度，防止文字太长贴边
            toastView.widthAnchor.constraint(lessThanOrEqualToConstant: window.bounds.width - 60)
        ])
        
        // 5. 弹出动画
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            toastView.alpha = 1
            toastView.transform = .identity // 恢复原大
        }
        
        // 6. 开启定时器自动消失
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.hideToast()
        }
    }
    
    private func hideToast() {
        guard let view = currentToastView else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) // 消失时稍微缩小
        }) { _ in
            view.removeFromSuperview()
        }
        
        currentToastView = nil
        hideTimer?.invalidate()
        hideTimer = nil
    }
    
    private func removeCurrentToast() {
        hideTimer?.invalidate()
        currentToastView?.removeFromSuperview()
        currentToastView = nil
    }
    
    // MARK: - UI 构建助手
    
    private func createToastView(message: String, style: Style) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0, alpha: 0.85) // 深色半透明背景
        container.layer.cornerRadius = 10
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 图标
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white // 默认白色
        
        // 根据样式设置图标和颜色
        var iconName = "info.circle.fill"
        switch style {
        case .normal:
            iconName = "info.circle.fill"
            iconImageView.tintColor = .white
        case .success:
            iconName = "checkmark.circle.fill"
            iconImageView.tintColor = .systemGreen // 绿色
        case .error:
            iconName = "xmark.circle.fill"
            iconImageView.tintColor = .systemRed // 红色
        }
        iconImageView.image = UIImage(systemName: iconName)
        
        // 文字
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0 // 支持多行
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 使用 StackView 布局图标和文字
        let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stackView)
        
        // 内部间距约束 (Padding)
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -15),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])
        
        return container
    }
    
    // 辅助方法：获取当前的 KeyWindow
    private func getKeyWindow() -> UIWindow? {
        // iOS 13+ 查找活跃的 WindowScene
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: { $0.isKeyWindow }) 
            ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
}