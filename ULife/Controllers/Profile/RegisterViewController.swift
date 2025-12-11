//
//  RegisterViewController.swift
//  ULife
//
//  注册页 - 参考活动模块重写

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let studentIdTextField = UITextField()
    private let nameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let collegeTextField = UITextField()
    private let majorTextField = UITextField()
    private let gradeTextField = UITextField()
    private let classNameTextField = UITextField()
    private let emailTextField = UITextField()
    private let phoneTextField = UITextField()
    private let registerButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "注册"
        view.backgroundColor = .systemBackground
        setupUI()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 配置输入框
        setupTextField(studentIdTextField, placeholder: "学号", keyboardType: .numberPad)
        setupTextField(nameTextField, placeholder: "姓名")
        setupTextField(passwordTextField, placeholder: "密码", isSecure: true)
        setupTextField(confirmPasswordTextField, placeholder: "确认密码", isSecure: true)
        setupTextField(collegeTextField, placeholder: "学院")
        setupTextField(majorTextField, placeholder: "专业")
        setupTextField(gradeTextField, placeholder: "年级，例如：2021")
        setupTextField(classNameTextField, placeholder: "班级，例如：计科1班")
        setupTextField(emailTextField, placeholder: "邮箱", keyboardType: .emailAddress)
        setupTextField(phoneTextField, placeholder: "手机号", keyboardType: .phonePad)
        
        // 注册按钮
        registerButton.setTitle("注册", for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        registerButton.backgroundColor = .systemBlue
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 10
        registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        [spacer,
         studentIdTextField,
         nameTextField,
         passwordTextField,
         confirmPasswordTextField,
         collegeTextField,
         majorTextField,
         gradeTextField,
         classNameTextField,
         emailTextField,
         phoneTextField,
         registerButton].forEach {
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
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
    @objc private func handleRegister() {
        guard let studentId = studentIdTextField.text, !studentId.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              let college = collegeTextField.text, !college.isEmpty,
              let major = majorTextField.text, !major.isEmpty,
              let grade = gradeTextField.text, !grade.isEmpty,
              let className = classNameTextField.text, !className.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty else {
            showError(message: "请填写所有必填项")
            return
        }
        
        guard password == confirmPassword else {
            showError(message: "两次密码不一致")
            return
        }
        
        registerButton.isEnabled = false
        registerButton.setTitle("注册中...", for: .normal)
        
        let request = RegisterRequest(
            studentId: studentId,
            password: password,
            name: name,
            college: college,
            major: major,
            grade: grade,
            className: className,
            email: email,
            phone: phone
        )
        
        Task {
            do {
                _ = try await UserRequest().register(request: request)
                
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "注册成功",
                        message: "请使用学号和密码登录",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.registerButton.isEnabled = true
                    self.registerButton.setTitle("注册", for: .normal)
                    self.showError(message: "注册失败: \(error.localizedDescription)")
        }
    }
        }
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
