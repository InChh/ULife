import UIKit

/// 管理 AI 助手悬浮球与聊天入口
final class AIAssistantManager {
    static let shared = AIAssistantManager()
    private init() {}

    private weak var floatingButton: UIButton?

    /// 根据设置同步显示/隐藏
    func updateVisibility(enabled: Bool) {
        DispatchQueue.main.async {
            enabled ? self.showFloatingButton() : self.hideFloatingButton()
        }
    }

    private func showFloatingButton() {
        guard floatingButton == nil, let window = keyWindow else { return }

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "sparkles"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 6
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.addTarget(self, action: #selector(openChat), for: .touchUpInside)
        button.accessibilityLabel = "AI助手悬浮球"

        window.addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56),
            button.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])

        floatingButton = button
    }

    private func hideFloatingButton() {
        floatingButton?.removeFromSuperview()
        floatingButton = nil
    }

    @objc private func openChat() {
        guard let topVC = topViewController else { return }
        let chatVC = AIChatViewController()
        let nav = UINavigationController(rootViewController: chatVC)
        nav.modalPresentationStyle = .pageSheet
        topVC.present(nav, animated: true)
    }

    private var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    private var topViewController: UIViewController? {
        func top(from base: UIViewController?) -> UIViewController? {
            if let nav = base as? UINavigationController {
                return top(from: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                return top(from: tab.selectedViewController)
            }
            if let presented = base?.presentedViewController {
                return top(from: presented)
            }
            return base
        }
        return top(from: keyWindow?.rootViewController)
    }
}
