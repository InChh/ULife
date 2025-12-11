//
//  PostCreationViewController.swift
//  ULife
//
//  发帖页 - 参考活动模块重写

import UIKit

class PostCreationViewController: UIViewController {
    
    // MARK: - Properties
    var boards: [Board] = []
    var onPostCreated: (() -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let boardPicker = UIPickerView()
    private let boardTextField = UITextField()
    private let titleTextField = UITextField()
    private let contentTextView = UITextView()
    private let tagsTextField = UITextField()
    
    private var selectedBoardIndex = 0
    private var tags: [String] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发布帖子"
        view.backgroundColor = .systemBackground
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "取消",
            style: .plain,
            target: self,
            action: #selector(handleCancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "发布",
            style: .done,
            target: self,
            action: #selector(handlePublish)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 板块选择
        let boardLabel = createLabel(text: "选择板块")
        boardTextField.placeholder = "请选择板块"
        boardTextField.borderStyle = .roundedRect
        boardTextField.inputView = boardPicker
        boardTextField.delegate = self
        boardPicker.delegate = self
        boardPicker.dataSource = self
        
        let boardToolbar = UIToolbar()
        boardToolbar.sizeToFit()
        boardToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(boardPickerDone))
        ]
        boardTextField.inputAccessoryView = boardToolbar
        
        // 标题
        let titleLabel = createLabel(text: "标题")
        titleTextField.placeholder = "输入帖子标题"
        titleTextField.borderStyle = .roundedRect
        titleTextField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        // 内容
        let contentLabel = createLabel(text: "内容")
        contentTextView.font = .systemFont(ofSize: 15)
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 8
        contentTextView.delegate = self
        contentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        
        // 标签
        let tagsLabel = createLabel(text: "标签（用空格分隔）")
        tagsTextField.placeholder = "例如: 学习 求助"
        tagsTextField.borderStyle = .roundedRect
        
        // 添加到栈
        [boardLabel, boardTextField, titleLabel, titleTextField, contentLabel, contentTextView, tagsLabel, tagsTextField].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }
    
    private func updatePublishButton() {
        let hasTitle = !(titleTextField.text?.isEmpty ?? true)
        let hasContent = !contentTextView.text.isEmpty
        let hasBoard = !boardTextField.text!.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = hasTitle && hasContent && hasBoard
    }
    
    // MARK: - Actions
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handlePublish() {
        guard let boardId = boards[safe: selectedBoardIndex]?.id,
              let title = titleTextField.text,
              let content = contentTextView.text else {
            return
        }
        
        // 解析标签
        let tagsText = tagsTextField.text ?? ""
        tags = tagsText.components(separatedBy: " ").filter { !$0.isEmpty }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let request = CreatePostRequest(
            boardId: boardId,
            content: content,
            media: nil,
            tags: tags,
            title: title
        )
        
        Task {
            do {
                _ = try await ForumRequest().CreatePost(request: request)
                
                await MainActor.run {
                    self.dismiss(animated: true) {
                        self.onPostCreated?()
                    }
                }
            } catch {
                await MainActor.run {
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    let alert = UIAlertController(title: "发布失败", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func boardPickerDone() {
        boardTextField.resignFirstResponder()
        if boards.count > selectedBoardIndex {
            boardTextField.text = boards[selectedBoardIndex].name
            updatePublishButton()
        }
    }
    
    @objc private func textChanged() {
        updatePublishButton()
    }
}

// MARK: - TextField Delegate
extension PostCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            contentTextView.becomeFirstResponder()
        } else if textField == tagsTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - TextView Delegate
extension PostCreationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePublishButton()
    }
}

// MARK: - PickerView
extension PostCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return boards.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return boards[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedBoardIndex = row
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
