import UIKit

class PostCreationViewController: UIViewController {

    // 状态和数据
    private var postModel = PostModel()
    
    // View 引用
    private var postCreationView: PostCreationView {
        return view as! PostCreationView
    }
    
    // 发布按钮
    private var publishButton: UIBarButtonItem?

    // MARK: - 生命周期
    
    override func loadView() {
        // 将自定义的 View 赋值给 self.view
        view = PostCreationView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        // 将 Controller 自身设置为 View 元素的代理
        postCreationView.titleTextField.delegate = self
        postCreationView.contentTextView.delegate = self
    }
    
    // MARK: - 导航栏设置
    
    private func setupNavigationBar() {
        navigationItem.title = "发帖" 
        
        // 左上角取消按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(handleCancel))
        
        // 右上角发布按钮
        let publish = UIBarButtonItem(title: "发布", style: .done, target: self, action: #selector(handlePublish))
        navigationItem.rightBarButtonItem = publish
        self.publishButton = publish
        
        // 初始状态检查
        updatePublishButtonState()
    }
    
    // MARK: - 动作处理
    
    @objc private func handleCancel() {
        // 如果内容不为空，弹出确认框
        if postModel.isValid {
            let alert = UIAlertController(title: "放弃发帖？", message: "您确定要放弃本次编辑吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "继续编辑", style: .cancel))
            alert.addAction(UIAlertAction(title: "放弃", style: .destructive, handler: { _ in
                self.dismiss(animated: true)
            }))
            present(alert, animated: true)
        } else {
            // 内容为空则直接关闭
            dismiss(animated: true)
        }
    }
    
    @objc private func handlePublish() {
        // 确保 Model 数据是最新的
        updateModelFromView()
        
        guard postModel.isValid else {
            Toast.show("标题和内容不能为空", style: .error)
            return
        }
        
        // 禁用按钮防止重复提交
        publishButton?.isEnabled = false
        Toast.show("发布中...", style: .normal, duration: 1.0)
        
        // 调用 Model 层的提交逻辑
        postModel.submit { [weak self] result in
            DispatchQueue.main.async {
                self?.publishButton?.isEnabled = true // 重新启用按钮
                switch result {
                case .success(let message):
                    Toast.show(message, style: .success)
                    // 延迟关闭，让用户看到成功的提示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    Toast.show("发布失败: \(error.localizedDescription)", style: .error)
                }
            }
        }
    }
    
    // MARK: - 状态更新
    
    /// 将 View 中的数据同步到 Model 中
    private func updateModelFromView() {
        postModel.title = postCreationView.titleTextField.text ?? ""
        postModel.content = postCreationView.contentTextView.text ?? ""
        // 标签选择逻辑在此处更新 postModel.selectedTags
    }
    
    /// 根据 Model 的状态更新发布按钮的可用性
    private func updatePublishButtonState() {
        updateModelFromView() // 确保 Model 数据最新
        publishButton?.isEnabled = postModel.isValid
    }
}

// MARK: - UITextFieldDelegate, UITextViewDelegate

extension PostCreationViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updatePublishButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePublishButtonState()
    }
}