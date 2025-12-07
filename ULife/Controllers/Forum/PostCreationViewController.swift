//
//  PostCreationViewController.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//

import UIKit

class PostCreationViewController: UIViewController {

    private let postCreationView = PostCreationView()
    // 发布按钮
    private var publishButton: UIBarButtonItem?

    var createPostRequest = CreatePostRequest()
    
    private var selectedCategoryIndex: Int = 0
    
    private var customTags: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
    }

    private func setupViews() {
        // 将 Controller 自身设置为 View 元素的代理
        postCreationView.titleTextField.delegate = self
        postCreationView.contentTextView.delegate = self
        
        // 设置 CollectionView 代理
        postCreationView.CategoryCollectionView.delegate = self
        postCreationView.CategoryCollectionView.dataSource = self

        // 标签输入框回车/按钮事件
        postCreationView.tagInputTextField.delegate = self
        postCreationView.tagAddButton.addTarget(
            self,
            action: #selector(handleAddTag),
            for: .touchUpInside
        )
        
        let publish = UIBarButtonItem(
            title: "发布",
            style: .done,
            target: self,
            action: #selector(handlePublish)
        )
        self.publishButton = publish
        self.navigationItem.rightBarButtonItem = publish
        navigationItem.title = "发帖"
        // 初始状态检查
        updatePublishButtonState()
        
        view.addSubview(postCreationView)
    }
    
    //设置布局
    private func setupLayout() {
        postCreationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            postCreationView.topAnchor.constraint(equalTo: view.topAnchor),
            postCreationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            postCreationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postCreationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    


    @objc private func handlePublish() {
        if !createPostRequest.isValid {
            Toast.show("标题和内容不能为空", style: .error)
            return
        }

        // 禁用按钮防止重复提交
        publishButton?.isEnabled = false
        
        createPostRequest.category = CreateCategorys[selectedCategoryIndex]
        createPostRequest.tags = customTags
        
        navigationController?.popViewController(animated: true)
        Toast.show("发布成功", style: .normal, duration: 1.0)
        
        print(createPostRequest)
    }

    // 根据 Model 的状态更新发布按钮的可用性
    private func updatePublishButtonState() {
        createPostRequest.title = postCreationView.titleTextField.text ?? ""
        createPostRequest.content = postCreationView.contentTextView.text ?? ""
        
        publishButton?.isEnabled = createPostRequest.isValid
    }

    // 添加自定义标签
    @objc private func handleAddTag() {
        guard
            let rawText = postCreationView.tagInputTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !rawText.isEmpty
        else { return }

        // 统一加上 # 前缀
        let tag = rawText.hasPrefix("#") ? rawText : "#\(rawText)"

        // 去重：避免重复标签
        if !customTags.contains(tag) {
            customTags.append(tag)
        }

        // 清空输入框
        postCreationView.tagInputTextField.text = ""

        // 更新标签展示
        updateTagListLabel()
    }

    // 根据 current customTags 更新底部“已添加标签”展示
    private func updateTagListLabel() {
        if customTags.isEmpty {
            postCreationView.tagListLabel.text = nil
            return
        }
        let joined = customTags.joined(separator: "  ")
        postCreationView.tagListLabel.text = "已添加标签：\(joined)"
    }
}

// MARK: - UITextFieldDelegate, UITextViewDelegate

extension PostCreationViewController: UITextFieldDelegate, UITextViewDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == postCreationView.titleTextField {
            updatePublishButtonState()
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        updatePublishButtonState()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == postCreationView.tagInputTextField {
            handleAddTag()
            textField.resignFirstResponder()
            return false
        }
        return true
    }
}



// 扩展实现 CollectionView 代理和数据源
extension PostCreationViewController: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // 每个分区有多少项目
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return CreateCategorys.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryCell.identifier,
                for: indexPath
            ) as? CategoryCell
        else {
            return UICollectionViewCell()
        }

        //let isSelected = (selectedCategoryIndex.contains(indexPath.row))  //是否选中
        let isSelected = indexPath.row == selectedCategoryIndex
        cell.configure(with: CreateCategorys[indexPath.row], isSelected: isSelected)
        return cell
    }

    // 点击调用
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
//        if selectedCategoryIndex.contains(indexPath.row){
//            let existingIndex = selectedCategoryIndex.firstIndex(of: indexPath.row)
//            selectedCategoryIndex.remove(at: existingIndex!)
//        }else{
//            selectedCategoryIndex.append(indexPath.row)
//        }
        selectedCategoryIndex = indexPath.row
        collectionView.reloadData()  // 刷新 CollectionView 来更新选中状态

        let selectedTag = CreateCategorys[indexPath.row]
    }

    // 根据每一个标签内容的长度设置每一个 cell 的宽度和高度
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // 创建一个临时的 Label，计算文本实际需要的宽度
        let tempLabel = UILabel()
        tempLabel.font = .systemFont(ofSize: 14, weight: .medium)
        tempLabel.text = CreateCategorys[indexPath.row]
        tempLabel.sizeToFit()

        // 宽度 
        let width = tempLabel.frame.width + 8

        
        return CGSize(width: width, height: 36)
    }
}
