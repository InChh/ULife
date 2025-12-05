//
//  RegisterViewController.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  注册控制器

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    
    private let registerView = RegisterView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupKeyboardObservers()
        
        // 设置导航栏
        navigationItem.title = "注册"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(registerView)
        
        registerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            registerView.topAnchor.constraint(equalTo: view.topAnchor),
            registerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            registerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            registerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 设置输入框代理
        for (textField, _) in registerView.textFields {
            textField.delegate = self
        }
    }
    
    private func setupBindings() {
        // 注册按钮点击
        registerView.registerButton.addAction(UIAction(handler: { [weak self] _ in
            self?.handleRegister()
        }), for: .touchUpInside)
        
        // 返回登录按钮点击
        registerView.backToLoginButton.addAction(UIAction(handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        UIView.animate(withDuration: duration) {
            self.registerView.scrollView.contentInset = contentInset
            self.registerView.scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.registerView.scrollView.contentInset = .zero
            self.registerView.scrollView.scrollIndicatorInsets = .zero
        }
    }
    
    private func handleRegister() {
        guard let registerData = registerView.getRegisterData() else {
            showAlert(title: "提示", message: "请填写所有必填字段，并确保密码一致")
            return
        }
        
        // 模拟注册
        if MockUserData.register(registerData) {
            showAlert(title: "注册成功", message: "请使用学号和密码登录") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            showAlert(title: "注册失败", message: "注册过程中出现错误，请稍后重试")
        }
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 找到当前输入框的下一个输入框
        for (index, (field, _)) in registerView.textFields.enumerated() {
            if field == textField && index < registerView.textFields.count - 1 {
                registerView.textFields[index + 1].field.becomeFirstResponder()
                return true
            }
        }
        
        // 如果是最后一个输入框，点击注册
        if textField == registerView.textFields.last?.field {
            textField.resignFirstResponder()
            handleRegister()
        }
        
        return true
    }
}
