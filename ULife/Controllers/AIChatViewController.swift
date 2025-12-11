import UIKit
import SwiftProtobuf

/// 简单的 AI 聊天界面（仅 mock，不触发后端）
final class AIChatViewController: UIViewController {
    private enum Role {
        case user
        case assistant
    }

    private struct ChatItem {
        let role: Role
        let content: String
        let time: Date
    }

    private var messages: [ChatItem] = []
    private var conversationId: Int64? {
        didSet { saveConversationId(conversationId) }
    }
    private var isSending = false

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputContainer = UIView()
    private let messageField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var bottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AI 助手"
        view.backgroundColor = .systemBackground
        conversationId = loadConversationId()
        setupNavigation()
        setupTableView()
        setupInputBar()
        registerKeyboardNotifications()
        loadHistoryIfNeeded()
        Task { await warmUpChat() } // 打开即建立会话并拉起大模型
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(close)
        )
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupInputBar() {
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = UIColor.secondarySystemBackground
        view.addSubview(inputContainer)

        messageField.translatesAutoresizingMaskIntoConstraints = false
        messageField.placeholder = "输入你的问题…"
        messageField.borderStyle = .roundedRect
        inputContainer.addSubview(messageField)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("发送", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputContainer.addSubview(sendButton)

        bottomConstraint = inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint!,

            messageField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8),
            messageField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            messageField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -8),

            sendButton.leadingAnchor.constraint(equalTo: messageField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: messageField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 52)
        ])

        tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor).isActive = true
    }

    // MARK: - Actions
    @objc private func close() {
        dismiss(animated: true)
    }

    @objc private func sendMessage() {
        guard let text = messageField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return
        }
        guard !isSending else { return }
        appendMessage(role: .user, content: text)
        messageField.text = nil
        Task { await sendToServer(text: text) }
    }

    private func sendToServer(text: String, hasRetriedAfter404: Bool = false) async {
        isSending = true
        defer { isSending = false }
        do {
            var req = Campus_Ai_ChatRequest()
            if let cid = conversationId { req.conversationID = cid }
            var msg = Campus_Ai_ChatMessage()
            msg.role = "user"
            msg.content = text
            req.messages = [msg]

            let resp: Campus_Ai_ChatResponse = try await AIAssistantService.shared.chat(request: req)
            conversationId = resp.conversationID
            let reply = resp.reply
            appendMessage(role: .assistant, content: reply.content.isEmpty ? "（无内容）" : reply.content)
        } catch {
            // 如果是 404，清空会话重试一次，避免因过期会话导致的 NotFound
            if case NetworkError.serverError(404, _) = error, !hasRetriedAfter404 {
                conversationId = nil
                await sendToServer(text: text, hasRetriedAfter404: true)
                return
            }
            
            await MainActor.run {
                let alert = UIAlertController(title: "发送失败", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    /// 打开页面即与大模型建立连接，获取欢迎语
    private func warmUpChat() async {
        guard messages.isEmpty else { return } // 已有消息就不再重复
        guard !isSending else { return }
        isSending = true
        defer { isSending = false }
        
        do {
            var req = Campus_Ai_ChatRequest()
            var msg = Campus_Ai_ChatMessage()
            msg.role = "user"
            msg.content = "你好" // 轻量打点，创建会话并获取首次回复
            req.messages = [msg]
            
            let resp: Campus_Ai_ChatResponse = try await AIAssistantService.shared.chat(request: req)
            conversationId = resp.conversationID
            let replyText = resp.reply.content.isEmpty ? "你好，我是你的 AI 助手，随时问我问题～" : resp.reply.content
            appendMessage(role: .assistant, content: replyText)
        } catch {
            print("AI助手初始化失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Persistence
    private let conversationIdKey = "ai_last_conversation_id"
    
    private func saveConversationId(_ id: Int64?) {
        let defaults = UserDefaults.standard
        if let id {
            defaults.set(id, forKey: conversationIdKey)
        } else {
            defaults.removeObject(forKey: conversationIdKey)
        }
        defaults.synchronize()
    }
    
    private func loadConversationId() -> Int64? {
        let defaults = UserDefaults.standard
        let value = defaults.object(forKey: conversationIdKey)
        if let number = value as? NSNumber {
            return number.int64Value
        }
        return nil
    }

    private func appendMessage(role: Role, content: String) {
        messages.append(ChatItem(role: role, content: content, time: Date()))
        tableView.reloadData()
        scrollToBottom()
    }

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    private func loadHistoryIfNeeded() {
        guard let cid = conversationId else { return }
        Task {
            do {
                let history = try await AIAssistantService.shared.history(conversationId: cid)
                let items = history.messages.map { proto in
                    ChatItem(role: proto.role.lowercased() == "user" ? .user : .assistant,
                             content: proto.content,
                             time: Date())
                }
                messages = items
                await MainActor.run {
                    tableView.reloadData()
                    scrollToBottom()
                }
            } catch {
                print("加载历史失败: \(error)")
            }
        }
    }

    // MARK: - Keyboard
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardFrame = frameValue.cgRectValue
        let keyboardVisible = keyboardFrame.minY < UIScreen.main.bounds.height
        let offset = keyboardVisible ? -keyboardFrame.height + view.safeAreaInsets.bottom : 0

        bottomConstraint?.constant = offset
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        if keyboardVisible {
            scrollToBottom()
        }
    }
}

// MARK: - TableView
extension AIChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = messages[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = item.content
        config.secondaryText = formatted(date: item.time)
        let isUser = item.role == .user
        config.textProperties.alignment = .natural
        config.secondaryTextProperties.alignment = .natural
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        cell.contentView.semanticContentAttribute = isUser ? .forceRightToLeft : .forceLeftToRight
        return cell
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
