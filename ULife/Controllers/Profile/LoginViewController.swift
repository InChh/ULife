//
//  LoginViewController.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let loginView = LoginView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        // 设置导航栏
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginView.clearInputs()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(loginView)
        
        loginView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalTo: view.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 设置输入框代理
        loginView.studentIdTextField.delegate = self
        loginView.passwordTextField.delegate = self
    }
    
    private func setupBindings() {
        // 登录按钮点击
        loginView.loginButton.addAction(UIAction(handler: { [weak self] _ in
            self?.handleLogin()
        }), for: .touchUpInside)
        
        // 注册按钮点击
        loginView.registerButton.addAction(UIAction(handler: { [weak self] _ in
            self?.navigateToRegister()
        }), for: .touchUpInside)
        
        // 忘记密码按钮点击
        loginView.forgotPasswordButton.addAction(UIAction(handler: { [weak self] _ in
            self?.handleForgotPassword()
        }), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    private func handleLogin() {
        // 获取输入凭据
        guard let credentials = loginView.getLoginCredentials() else {
            showAlert(title: "提示", message: "请输入学号和密码")
            return
        }
        
        // 模拟登录验证
        if MockUserData.validateLogin(studentId: credentials.studentId, password: credentials.password) {
            // 登录成功
            print("登录成功，学号: \(credentials.studentId)")
            
            // 保存登录状态
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(credentials.studentId, forKey: "currentStudentId")
            
            // 切换到主界面
            navigateToMainApp()
        } else {
            // 登录失败
            showAlert(title: "登录失败", message: "学号或密码错误")
        }
    }
    
    private func navigateToRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    private func handleForgotPassword() {
        showAlert(title: "忘记密码", message: "请联系管理员或使用邮箱找回密码功能")
    }
    
    private func navigateToMainApp() {
        // 切换到主TabBarController
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.window?.rootViewController = UIHelper.createTabViewController()
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginView.studentIdTextField {
            loginView.passwordTextField.becomeFirstResponder()
        } else if textField == loginView.passwordTextField {
            textField.resignFirstResponder()
            handleLogin()
        }
        return true
    }
}
