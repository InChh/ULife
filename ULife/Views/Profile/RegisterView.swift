//
//  RegisterView.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  注册界面视图

import UIKit

class RegisterView: UIView {
    
    // MARK: - UI Components
    
    // 修改：去掉 private，使用 lazy var
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "注册账号"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    // 输入框数组
    lazy var textFields: [(field: UITextField, placeholder: String)] = [
        (createTextField(placeholder: "学号", icon: "person.fill", keyboardType: .numberPad), "学号"),
        (createTextField(placeholder: "密码", icon: "lock.fill", isSecure: true), "密码"),
        (createTextField(placeholder: "确认密码", icon: "lock.fill", isSecure: true), "确认密码"),
        (createTextField(placeholder: "真实姓名", icon: "person.crop.circle"), "真实姓名"),
        (createTextField(placeholder: "学院", icon: "building.columns"), "学院"),
        (createTextField(placeholder: "专业", icon: "book.fill"), "专业"),
        (createTextField(placeholder: "年级", icon: "graduationcap.fill"), "年级"),
        (createTextField(placeholder: "班级", icon: "person.3.fill"), "班级"),
        (createTextField(placeholder: "邮箱", icon: "envelope.fill", keyboardType: .emailAddress), "邮箱"),
        (createTextField(placeholder: "手机号", icon: "phone.fill", keyboardType: .phonePad), "手机号")
    ]
    
    // 注册按钮
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("注册", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // 返回登录按钮
    lazy var backToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("已有账号？返回登录", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
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
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        
        // 添加所有输入框
        for (textField, _) in textFields {
            contentView.addSubview(textField)
        }
        
        contentView.addSubview(registerButton)
        contentView.addSubview(backToLoginButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // ScrollView 约束
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // ContentView 约束
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 标题
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        // 动态添加输入框约束
        var previousField: UIView = titleLabel
        let horizontalPadding: CGFloat = 40
        let fieldHeight: CGFloat = 50
        let fieldSpacing: CGFloat = 16
        
        for (index, (textField, _)) in textFields.enumerated() {
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: previousField.bottomAnchor, constant: index == 0 ? 40 : fieldSpacing),
                textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
                textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
                textField.heightAnchor.constraint(equalToConstant: fieldHeight)
            ])
            
            previousField = textField
        }
        
        // 注册按钮
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: previousField.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 返回登录按钮
        backToLoginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backToLoginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            backToLoginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backToLoginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func createTextField(placeholder: String, icon: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 16)
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        let imageView = UIImageView(image: UIImage(systemName: icon))
        imageView.tintColor = .systemGray
        imageView.frame = CGRect(x: 12, y: 12, width: 20, height: 20)
        leftView.addSubview(imageView)
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }
    
    // MARK: - Public Methods
    
    func clearInputs() {
        for (textField, _) in textFields {
            textField.text = ""
        }
    }
    
    func getRegisterData() -> RegisterRequest? {
        let values = textFields.map { $0.field.text?.trimmingCharacters(in: .whitespaces) ?? "" }
        
        // 验证必填字段
        for (index, value) in values.enumerated() {
            if value.isEmpty {
                return nil
            }
        }
        
        // 验证密码是否一致
        if values[1] != values[2] {
            return nil
        }
        
        return RegisterRequest(
            studentId: values[0],
            password: values[1],
            name: values[3],
            college: values[4],
            major: values[5],
            grade: values[6],
            className: values[7],
            email: values[8],
            phone: values[9]
        )
    }
}
