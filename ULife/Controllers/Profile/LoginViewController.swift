//
//  LoginViewController.swift
//  ULife
//
//  登录页 - 参考活动模块重写

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let studentIdTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.alignment = .fill
        
        // Logo
        logoImageView.image = UIImage(systemName: "graduationcap.circle.fill")
        logoImageView.tintColor = .systemBlue
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Title
        titleLabel.text = "ULife 校园生活"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        // 学号输入
        studentIdTextField.placeholder = "请输入学号"
        studentIdTextField.borderStyle = .roundedRect
        studentIdTextField.keyboardType = .numberPad
        studentIdTextField.autocapitalizationType = .none
        studentIdTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // 密码输入
        passwordTextField.placeholder = "请输入密码"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // 登录按钮
        loginButton.setTitle("登录", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        // 注册按钮
        registerButton.setTitle("还没有账号？立即注册", for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 15)
        registerButton.setTitleColor(.systemBlue, for: .normal)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        // 添加间距
        let spacer1 = UIView()
        spacer1.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let spacer2 = UIView()
        spacer2.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        [spacer1, logoImageView, titleLabel, spacer2, studentIdTextField, passwordTextField, loginButton, registerButton].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60)
        ])
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    @objc private func handleLogin() {
        guard let studentId = studentIdTextField.text, !studentId.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError(message: "请输入学号和密码")
            return
        }
        
        loginButton.isEnabled = false
        loginButton.setTitle("登录中...", for: .normal)
        
        Task {
            do {
                let (token, user) = try await UserRequest().login(studentId: studentId, password: password)
                
                await MainActor.run {
            // 保存登录状态
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(token, forKey: "authToken")
            
                    // 跳转到主页
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.showMainInterface()
                    }
                }
            } catch {
                await MainActor.run {
                    self.loginButton.isEnabled = true
                    self.loginButton.setTitle("登录", for: .normal)
                    self.showError(message: "登录失败: \(error.localizedDescription)")
        }
    }
        }
    }
    
    @objc private func handleRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
