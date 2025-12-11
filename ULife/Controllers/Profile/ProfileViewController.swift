//
//  ProfileViewController.swift
//  ULife
//
//  个人中心 - 参考活动模块重写

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerView = ProfileHeaderView()
    private var userSettings = UserManager.shared.getUserSettings()
    
    private var currentUser: User?
    private let avatarCacheKey = "profile.avatar.image"
    private let languageKey = "app.language.selection"
    
    private var settingSections: [[SettingItem]] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的"
        view.backgroundColor = .systemGroupedBackground
        buildSettingSections()
        setupUI()
        loadUserData()
        AIAssistantManager.shared.updateVisibility(enabled: userSettings.aiAssistantEnabled)
    }

    private func buildSettingSections() {
        settingSections = [
        [
            SettingItem(icon: "person.circle", title: "编辑资料", type: .navigation),
            SettingItem(icon: "lock", title: "修改密码", type: .navigation)
        ],
        [
            SettingItem(icon: "bell", title: "通知设置", type: .navigation),
            SettingItem(icon: "eye", title: "隐私设置", type: .navigation)
        ],
        [
            SettingItem(icon: "paintbrush", title: "主题设置", type: .navigation),
            SettingItem(icon: "globe", title: "语言设置", type: .navigation)
        ],
            [
                SettingItem(icon: "sparkles", title: "AI 助手", type: .toggle)
            ],
        [
            SettingItem(icon: "info.circle", title: "关于我们", type: .navigation),
            SettingItem(icon: "arrow.right.square", title: "退出登录", type: .action)
        ]
    ]
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Header
        headerView.editAvatarButton.addTarget(self, action: #selector(handleEditAvatar), for: .touchUpInside)
        headerView.editProfileButton.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
        tableView.tableHeaderView = headerView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 设置 header 高度
        let headerHeight = headerView.calculateHeight()
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight)
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        Task {
            do {
                currentUser = try await UserRequest().getCurrentUserInfo()
                
                await MainActor.run {
                    if let user = self.currentUser {
                        let cachedAvatar = self.loadCachedAvatar()
                        self.headerView.configure(with: user, avatar: cachedAvatar)
                    }
                }
            } catch {
                print("加载用户信息失败: \(error)")
                // 如果登录信息失效，跳转到登录页
                await MainActor.run {
                    self.showLoginScreen()
                }
            }
        }
    }
    
    private func showLoginScreen() {
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "错误",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func handleEditAvatar() {
        let alert = UIAlertController(title: "更换头像", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
            self?.pickImage(from: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "从相册选择", style: .default) { [weak self] _ in
            self?.pickImage(from: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func handleEditProfile() {
        let alert = UIAlertController(title: "编辑资料", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "姓名"; $0.text = self.currentUser?.name }
        alert.addTextField { $0.placeholder = "专业"; $0.text = self.currentUser?.major }
        alert.addTextField { $0.placeholder = "电话"; $0.keyboardType = .phonePad; $0.text = self.currentUser?.phone }
        alert.addTextField { $0.placeholder = "个性签名"; $0.text = self.currentUser?.bio }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { [weak self] _ in
            guard let self, var user = self.currentUser else { return }
            let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let major = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let phone = alert.textFields?[2].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let bio = alert.textFields?[3].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            user = User(
                id: user.id,
                studentId: user.studentId,
                username: user.username,
                password: user.password,
                name: name?.isEmpty == false ? name! : user.name,
                avatar: user.avatar,
                college: user.college,
                major: major?.isEmpty == false ? major! : user.major,
                grade: user.grade,
                className: user.className,
                email: user.email,
                phone: phone?.isEmpty == false ? phone! : user.phone,
                qq: user.qq,
                wechat: user.wechat,
                bio: bio?.isEmpty == false ? bio! : user.bio,
                joinDate: user.joinDate,
                lastLogin: Date()
            )
            self.currentUser = user
            UserManager.shared.saveUser(user)
            self.headerView.configure(with: user, avatar: self.loadCachedAvatar())
        })
        present(alert, animated: true)
    }
    
    private func pickImage(from sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func handleLogout() {
        let alert = UIAlertController(
            title: "退出登录",
            message: "确定要退出吗？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        Task {
            do {
                try await UserRequest().logout()
                
                await MainActor.run {
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    UserDefaults.standard.removeObject(forKey: "authToken")
                    self.showLoginScreen()
                }
            } catch {
                print("退出失败: \(error)")
            }
        }
    }

    // MARK: - Helpers
    private func cacheAvatar(_ image: UIImage) {
        if let data = image.pngData() {
            UserDefaults.standard.set(data, forKey: avatarCacheKey)
        }
    }
    
    private func loadCachedAvatar() -> UIImage? {
        if let data = UserDefaults.standard.data(forKey: avatarCacheKey) {
            return UIImage(data: data)
        }
        return nil
    }
    
    private func showChangePassword() {
        let alert = UIAlertController(title: "修改密码", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "旧密码"; $0.isSecureTextEntry = true }
        alert.addTextField { $0.placeholder = "新密码"; $0.isSecureTextEntry = true }
        alert.addTextField { $0.placeholder = "确认新密码"; $0.isSecureTextEntry = true }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { _ in
            let old = alert.textFields?[0].text ?? ""
            let new = alert.textFields?[1].text ?? ""
            let confirm = alert.textFields?[2].text ?? ""
            guard !old.isEmpty, !new.isEmpty, new == confirm else { return }
            Task {
                do {
                    try await UserRequest().changePassword(oldPassword: old, newPassword: new)
                    await MainActor.run {
                        let ok = UIAlertAction(title: "确定", style: .default)
                        let done = UIAlertController(title: "成功", message: "密码已修改", preferredStyle: .alert)
                        done.addAction(ok)
                        self.present(done, animated: true)
                    }
                } catch {
                    await MainActor.run {
                        let fail = UIAlertController(title: "失败", message: error.localizedDescription, preferredStyle: .alert)
                        fail.addAction(UIAlertAction(title: "确定", style: .default))
                        self.present(fail, animated: true)
                    }
                }
            }
        })
        present(alert, animated: true)
    }
    
    private func showNotificationSettings() {
        var settings = UserManager.shared.getUserSettings()
        let vc = SimpleToggleListController(
            title: "通知设置",
            items: [
                ToggleItem(title: "上课提醒", keyPath: \.classReminder),
                ToggleItem(title: "论坛回复通知", keyPath: \.forumReplyNotification),
                ToggleItem(title: "系统通知", keyPath: \.systemNotification)
            ],
            settings: settings
        ) { updated in
            settings = updated
            UserManager.shared.saveUserSettings(updated)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showPrivacySettings() {
        var settings = UserManager.shared.getUserSettings()
        let vc = PrivacySettingsController(settings: settings) { updated in
            settings = updated
            UserManager.shared.saveUserSettings(updated)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showThemeSettings() {
        var settings = UserManager.shared.getUserSettings()
        let alert = UIAlertController(title: "主题设置", message: nil, preferredStyle: .actionSheet)
        UserSettings.AppTheme.allCases.forEach { theme in
            alert.addAction(UIAlertAction(title: theme.rawValue, style: .default) { _ in
                settings.theme = theme
                UserManager.shared.saveUserSettings(settings)
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showLanguageSettings() {
        let alert = UIAlertController(title: "语言设置", message: nil, preferredStyle: .actionSheet)
        let languages = [("简体中文", "zh-Hans"), ("English", "en")]
        languages.forEach { pair in
            alert.addAction(UIAlertAction(title: pair.0, style: .default) { [weak self] _ in
                guard let self else { return }
                UserDefaults.standard.set(pair.1, forKey: self.languageKey)
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAbout() {
        let vc = UIViewController()
        vc.title = "关于我们"
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "ULife 校园助手\n版本 1.0\n感谢使用！"
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -24)
        ])
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        let item = settingSections[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.imageView?.tintColor = .systemBlue
        
        switch item.type {
        case .navigation:
            cell.accessoryType = .disclosureIndicator
        case .toggle:
            let toggle = UISwitch()
            toggle.isOn = userSettings.aiAssistantEnabled
            toggle.addTarget(self, action: #selector(handleAiToggle(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            cell.selectionStyle = .none
        case .action:
            cell.textLabel?.textColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = settingSections[indexPath.section][indexPath.row]
        
        switch item.title {
        case "编辑资料":
            handleEditProfile()
        case "修改密码":
            showChangePassword()
        case "通知设置":
            showNotificationSettings()
        case "隐私设置":
            showPrivacySettings()
        case "主题设置":
            showThemeSettings()
        case "语言设置":
            showLanguageSettings()
        case "关于我们":
            showAbout()
        case "退出登录":
            handleLogout()
        default:
            break
        }
    }
}

// MARK: - Toggle Actions
extension ProfileViewController {
    @objc private func handleAiToggle(_ sender: UISwitch) {
        userSettings.aiAssistantEnabled = sender.isOn
        UserManager.shared.saveUserSettings(userSettings)
        AIAssistantManager.shared.updateVisibility(enabled: sender.isOn)
    }
}

// MARK: - ImagePicker Delegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            headerView.avatarImageView.image = image
            cacheAvatar(image)
        }
    }
}

// MARK: - Supporting Types
struct SettingItem {
    let icon: String
    let title: String
    let type: SettingType
    
    enum SettingType {
        case navigation
        case toggle
        case action
    }
}

// MARK: - Simple Toggle List
private struct ToggleItem {
    let title: String
    let keyPath: WritableKeyPath<UserSettings, Bool>
}

private final class SimpleToggleListController: UITableViewController {
    private var items: [ToggleItem]
    private var settings: UserSettings
    private let onSave: (UserSettings) -> Void
    
    init(title: String, items: [ToggleItem], settings: UserSettings, onSave: @escaping (UserSettings) -> Void) {
        self.items = items
        self.settings = settings
        self.onSave = onSave
        super.init(style: .insetGrouped)
        self.title = title
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        let toggle = UISwitch()
        toggle.isOn = settings[keyPath: item.keyPath]
        toggle.addTarget(self, action: #selector(handleSwitch(_:)), for: .valueChanged)
        toggle.tag = indexPath.row
        cell.accessoryView = toggle
        return cell
    }
    
    @objc private func handleSwitch(_ sender: UISwitch) {
        let item = items[sender.tag]
        settings[keyPath: item.keyPath] = sender.isOn
        onSave(settings)
    }
}

// MARK: - Privacy Settings
private final class PrivacySettingsController: UITableViewController {
    private var settings: UserSettings
    private let onSave: (UserSettings) -> Void
    
    private enum Row {
        case visibility
        case showPhone
    }
    private let rows: [Row] = [.visibility, .showPhone]
    
    init(settings: UserSettings, onSave: @escaping (UserSettings) -> Void) {
        self.settings = settings
        self.onSave = onSave
        super.init(style: .insetGrouped)
        self.title = "隐私设置"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        switch row {
        case .visibility:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "课表可见范围"
            cell.detailTextLabel?.text = settings.scheduleVisibility.rawValue
            cell.accessoryType = .disclosureIndicator
            return cell
        case .showPhone:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "显示手机号"
            let toggle = UISwitch()
            toggle.isOn = settings.showPhoneNumber
            toggle.addTarget(self, action: #selector(togglePhone(_:)), for: .valueChanged)
            cell.accessoryView = toggle
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        if case .visibility = row {
            let alert = UIAlertController(title: "课表可见范围", message: nil, preferredStyle: .actionSheet)
            UserSettings.ScheduleVisibility.allCases.forEach { visibility in
                alert.addAction(UIAlertAction(title: visibility.rawValue, style: .default) { [weak self] _ in
                    guard let self else { return }
                    self.settings.scheduleVisibility = visibility
                    self.onSave(self.settings)
                    self.tableView.reloadData()
                })
            }
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    @objc private func togglePhone(_ sender: UISwitch) {
        settings.showPhoneNumber = sender.isOn
        onSave(settings)
    }
}
