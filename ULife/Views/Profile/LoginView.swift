//
//  LoginView.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  登录界面视图

import UIKit

class LoginView: UIView {
    
    // MARK: - UI Components
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "graduationcap.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "校园助手"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "一站式校园生活平台"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    // 学号输入框
    lazy var studentIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入学号"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 16)
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = .systemGray
        imageView.frame = CGRect(x: 12, y: 12, width: 20, height: 20)
        leftView.addSubview(imageView)
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    // 密码输入框
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入密码"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.font = .systemFont(ofSize: 16)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        let imageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        imageView.tintColor = .systemGray
        imageView.frame = CGRect(x: 12, y: 12, width: 20, height: 20)
        leftView.addSubview(imageView)
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        // 显示/隐藏密码按钮
        let rightView = UIButton(type: .system)
        rightView.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        rightView.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        rightView.tintColor = .systemGray
        rightView.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        textField.rightView = rightView
        textField.rightViewMode = .always
        
        return textField
    }()
    
    // 登录按钮
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 6
        return button
    }()
    
    // 注册按钮
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("还没有账号？立即注册", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // 忘记密码按钮
    lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("忘记密码？", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(.systemGray, for: .normal)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // 添加子视图
        addSubview(logoImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(studentIdTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(registerButton)
        addSubview(forgotPasswordButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        studentIdTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Logo
            logoImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // 标题
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // 副标题
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // 学号输入框
            studentIdTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            studentIdTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            studentIdTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            studentIdTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // 密码输入框
            passwordTextField.topAnchor.constraint(equalTo: studentIdTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: studentIdTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: studentIdTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // 登录按钮
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: studentIdTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: studentIdTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 注册按钮
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // 忘记密码按钮
            forgotPasswordButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 10),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        if let button = passwordTextField.rightView as? UIButton {
            let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    // MARK: - Public Methods
    
    func clearInputs() {
        studentIdTextField.text = ""
        passwordTextField.text = ""
        studentIdTextField.becomeFirstResponder()
    }
    
    func getLoginCredentials() -> (studentId: String, password: String)? {
        guard let studentId = studentIdTextField.text?.trimmingCharacters(in: .whitespaces),
              let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces),
              !studentId.isEmpty, !password.isEmpty else {
            return nil
        }
        return (studentId, password)
    }
}
