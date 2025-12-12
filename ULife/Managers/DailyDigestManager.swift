import Foundation
import UserNotifications

/// 负责从后端拉取“今日校园简报”，并以系统通知的形式展示给用户。
/// - 注意：当前实现为简单示例，需在 App 运行时显式调用 `checkAndNotifyTodayDigest`。
final class DailyDigestManager {
    static let shared = DailyDigestManager()
    private init() {}

    private let network = NetworkManager.shared
    private let lastShownKey = "daily_digest_last_shown_date"
    private var debugTimer: Timer?

    /// 在合适的时机调用（例如 App 启动、从后台回到前台时），检查是否有新的简报需要推送系统通知。
    /// - Parameter ignoreDateCheck: 测试模式下可传 true，每次都会尝试推送一条通知。
    func checkAndNotifyTodayDigest(ignoreDateCheck: Bool = false) {
        Task {
            do {
                struct DigestData: Decodable {
                    let date: String
                    let summary: String
                    let created_at: String
                }

                // 该请求会解析为后端统一响应中的 data 字段（参见 APIResponse<T>）
                let digest: DigestData = try await network.request(
                    endpoint: "/v1/ai/daily_digest",
                    method: .get,
                    parameters: nil,
                    body: nil as Encodable?
                )

                if !ignoreDateCheck {
                    let lastShownDate = UserDefaults.standard.string(forKey: lastShownKey)
                    // 仅在今天还没展示过的情况下推送一次通知
                    guard lastShownDate != digest.date else { return }
                    UserDefaults.standard.setValue(digest.date, forKey: lastShownKey)
                }

                scheduleNotification(date: digest.date, summary: digest.summary)
            } catch {
                print("获取每日简报失败: \(error)")
            }
        }
    }

    /// 测试用：每 5 秒检查一次并强制推送简报通知（忽略每天只推送一次的限制）。
    func startDebugNotificationLoop() {
        debugTimer?.invalidate()
        debugTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.checkAndNotifyTodayDigest(ignoreDateCheck: true)
        }
        if let timer = debugTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func scheduleNotification(date: String, summary: String) {
        let content = UNMutableNotificationContent()
        content.title = "今日校园简报"
        content.body = summary.isEmpty ? "今日暂无新的校园活动或论坛讨论简报。" : summary
        content.sound = .default

        // 立刻推送（如果 App 在前台，默认不会弹系统横幅；在后台时会表现为正常系统通知）
        let request = UNNotificationRequest(
            identifier: "daily_campus_digest_\(date)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("添加每日简报通知失败: \(error)")
            }
        }
    }
}

