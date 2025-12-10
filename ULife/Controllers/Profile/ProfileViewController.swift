//
//  ProfileViewController.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//

import UIKit

// MARK: - Supporting Types
struct SettingItem {
    let title: String
    let subtitle: String?
    let icon: String
    let type: SettingType
    
    init(title: String, subtitle: String? = nil, icon: String, type: SettingType) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.type = type
    }
}

enum SettingType {
    case navigation
    case toggle
    case destructive
}

enum PhotoSourceType {
    case camera
    case photoLibrary
}

class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // 使用懒加载方式创建头部视图，不设置固定高度
    private lazy var headerView: ProfileHeaderView = {
        let view = ProfileHeaderView()
        return view
    }()
    
    private var user: User?
    private var settings: UserSettings = UserSettings.default
    
    private let settingSections: [(title: String, items: [SettingItem])] = [
        (
            title: "账号设置",
            items: [
                SettingItem(title: "修改密码", icon: "lock.fill", type: .navigation),
                SettingItem(title: "绑定邮箱", subtitle: "zhangsan@example.com", icon: "envelope.fill", type: .navigation),
                SettingItem(title: "绑定手机", subtitle: "138****8000", icon: "phone.fill", type: .navigation)
            ]
        ),
        (
            title: "通知设置",
            items: [
                SettingItem(title: "课前提醒", icon: "bell.fill", type: .toggle),
                SettingItem(title: "论坛回复通知", icon: "message.fill", type: .toggle),
                SettingItem(title: "系统通知", icon: "gear", type: .toggle)
            ]
        ),
        (
            title: "隐私设置",
            items: [
                SettingItem(title: "课表可见范围", subtitle: "同班同学", icon: "eye.fill", type: .navigation),
                SettingItem(title: "允许私信", icon: "bubble.left.fill", type: .toggle),
                SettingItem(title: "显示手机号", icon: "phone.circle.fill", type: .toggle)
            ]
        ),
        (
            title: "个性化",
            items: [
                SettingItem(title: "主题设置", subtitle: "跟随系统", icon: "paintpalette.fill", type: .navigation),
                SettingItem(title: "字体大小", subtitle: "中", icon: "textformat.size", type: .navigation)
            ]
        ),
        (
            title: "关于",
            items: [
                SettingItem(title: "帮助与反馈", icon: "questionmark.circle.fill", type: .navigation),
                SettingItem(title: "隐私政策", icon: "doc.text.fill", type: .navigation),
                SettingItem(title: "关于我们", icon: "info.circle.fill", type: .navigation)
            ]
        ),
        (
            title: "",
            items: [
                SettingItem(title: "退出登录", icon: "rectangle.portrait.and.arrow.right", type: .destructive)
            ]
        )
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 视图显示后更新头部视图高度
        updateHeaderViewHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 布局更新后重新计算头部视图高度
        updateHeaderViewHeight()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "个人中心"
        view.backgroundColor = .systemGroupedBackground
        
        // 设置导航栏
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        // 设置表格视图
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProfileSettingCell.self, forCellReuseIdentifier: "ProfileSettingCell")
        
        // 先设置一个临时frame，稍后更新
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 350)
        tableView.tableHeaderView = headerView
        
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 设置头部视图交互
        setupHeaderViewActions()
    }
    
    private func setupHeaderViewActions() {
        // 编辑头像
        headerView.editAvatarButton.addAction(UIAction(handler: { [weak self] _ in
            self?.handleEditAvatar()
        }), for: .touchUpInside)
        
        // 编辑资料
        headerView.editProfileButton.addAction(UIAction(handler: { [weak self] _ in
            self?.handleEditProfile()
        }), for: .touchUpInside)
    }
    
    private func loadUserData() {
        // 加载模拟用户数据
        user = MockUserData.currentUser
        settings = MockUserData.userSettings
        
        if let user = user {
            headerView.configure(with: user)
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateHeaderViewHeight() {
        // 计算头部视图所需的高度
        let width = view.frame.width
        let height = headerView.calculateHeight()
        
        // 重新设置头部视图的frame
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // 重新设置tableView的tableHeaderView
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - Actions
    
    private func handleEditAvatar() {
        // 创建选择菜单
        let alertController = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        
        // 拍照选项
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
                self.openCamera()
            }))
        }
        
        // 从相册选择选项
        alertController.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        // 取消选项
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func handleEditProfile() {
        showAlert(title: "编辑资料", message: "个人资料编辑功能开发中")
    }
    
    private func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func handleLogout() {
        showConfirmationAlert(title: "退出登录", message: "确定要退出登录吗？") { [weak self] in
            self?.performLogout()
        }
    }
    
    private func performLogout() {
        // 清除登录状态
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentStudentId")
        
        // 返回到登录界面
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.window?.rootViewController = navController
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    // MARK: - Alert Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func showConfirmationAlert(title: String, message: String, confirmed: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            confirmed()
        }))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSettingCell", for: indexPath) as? ProfileSettingCell else {
            return UITableViewCell()
        }
        
        let item = settingSections[indexPath.section].items[indexPath.row]
        
        switch item.type {
        case .navigation:
            cell.configure(
                title: item.title,
                subtitle: item.subtitle,
                iconName: item.icon,
                showSwitch: false,
                showAccessory: true
            )
        case .toggle:
            let isOn = getToggleValue(for: item.title)
            cell.configure(
                title: item.title,
                subtitle: item.subtitle,
                iconName: item.icon,
                showSwitch: true,
                isOn: isOn,
                showAccessory: false
            )
        case .destructive:
            cell.configure(
                title: item.title,
                subtitle: item.subtitle,
                iconName: item.icon,
                showSwitch: false,
                showAccessory: false
            )
            cell.titleLabel.textColor = .systemRed
            cell.iconImageView.tintColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingSections[section].title
    }
    
    private func getToggleValue(for settingTitle: String) -> Bool {
        switch settingTitle {
        case "课前提醒":
            return settings.classReminder
        case "论坛回复通知":
            return settings.forumReplyNotification
        case "系统通知":
            return settings.systemNotification
        case "允许私信":
            return settings.allowPrivateMessages
        case "显示手机号":
            return settings.showPhoneNumber
        default:
            return false
        }
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingSections[indexPath.section].items[indexPath.row]
        
        switch item.type {
        case .navigation:
            handleNavigationSelection(item: item)
        case .toggle:
            break // 开关已经在cell中处理
        case .destructive:
            if item.title == "退出登录" {
                handleLogout()
            }
        }
    }
    
    private func handleNavigationSelection(item: SettingItem) {
        switch item.title {
        case "修改密码":
            showAlert(title: "修改密码", message: "密码修改功能开发中")
        case "绑定邮箱", "绑定手机":
            showAlert(title: item.title, message: "绑定功能开发中")
        case "课表可见范围":
            showVisibilityOptions()
        case "主题设置":
            showThemeOptions()
        case "字体大小":
            showFontSizeOptions()
        case "帮助与反馈":
            showAlert(title: "帮助与反馈", message: "如有问题，请联系客服邮箱：support@ulife.com")
        case "隐私政策":
            showAlert(title: "隐私政策", message: "我们非常重视您的隐私保护")
        case "关于我们":
            showAlert(title: "关于我们", message: "校园助手 v1.0.0\n© 2025 ULife Team")
        default:
            break
        }
    }
    
    private func showVisibilityOptions() {
        let alert = UIAlertController(title: "课表可见范围", message: nil, preferredStyle: .actionSheet)
        
        for option in UserSettings.ScheduleVisibility.allCases {
            alert.addAction(UIAlertAction(title: option.rawValue, style: .default, handler: { _ in
                print("选择了: \(option.rawValue)")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showThemeOptions() {
        let alert = UIAlertController(title: "主题设置", message: nil, preferredStyle: .actionSheet)
        
        for theme in UserSettings.AppTheme.allCases {
            alert.addAction(UIAlertAction(title: theme.rawValue, style: .default, handler: { _ in
                print("选择了主题: \(theme.rawValue)")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showFontSizeOptions() {
        let alert = UIAlertController(title: "字体大小", message: nil, preferredStyle: .actionSheet)
        
        for fontSize in UserSettings.FontSize.allCases {
            alert.addAction(UIAlertAction(title: fontSize.rawValue, style: .default, handler: { _ in
                print("选择了字体大小: \(fontSize.rawValue)")
            }))
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            headerView.avatarImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            headerView.avatarImageView.image = originalImage
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
