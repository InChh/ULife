//
//  PostCreationViewController.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//  发布帖子

import UIKit

class PostCreationViewController: UIViewController {

    let postCreationView = PostCreationView()
    
    // 导航栏右侧发帖按钮
    private var publishButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupLayout()
        setupBindings()
    }

    private func setupViews() {
        // 将 Controller 自身设置为 View 元素的代理
        postCreationView.titleTextField.delegate = self
        postCreationView.contentTextView.delegate = self
        
        // 设置 CollectionView 代理
        postCreationView.CategoryCollectionView.delegate = self
        postCreationView.CategoryCollectionView.dataSource = self

        // 导航栏右侧发帖按钮
        let publish = UIBarButtonItem(
            title: "发布",
            style: .done,
            target: self,
            action: #selector(handlePublish)
        )
        self.publishButton = publish
        self.navigationItem.rightBarButtonItem = publish
        navigationItem.title = "发帖"
        // 发帖按钮初始状态检查
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
    
    //绑定事件
    private func setupBindings() {
        // 添加标签按钮
        postCreationView.tagAddButton.addTarget(
            self,
            action: #selector(handleAddTag),
            for: .touchUpInside
        )
    }
    

    // 发帖
    @objc private func handlePublish() {
        // 禁用按钮防止重复提交
        publishButton?.isEnabled = false
        
        var createPostRequest = CreatePostRequest()
        createPostRequest.title = postCreationView.titleTextField.text!
        createPostRequest.content = postCreationView.contentTextView.text!
        createPostRequest.category = CreateCategorys[CreateselectedCategoryIndex]
        createPostRequest.tags = customTags
        
        navigationController?.popViewController(animated: true)
        Toast.show("发布成功", style: .normal, duration: 1.0)
        
        print(createPostRequest)
    }
    
    // 添加标签
    @objc private func handleAddTag() {
        guard
            let rawText = postCreationView.tagInputTextField.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),//移除文本开头和结尾的所有空格和换行符
            !rawText.isEmpty
        else { return }
    
        let tag = rawText.hasPrefix("#") ? rawText : "#\(rawText)"
        // 避免重复标签
        if !customTags.contains(tag) {
            customTags.append(tag)
        }
        // 清空输入框
        postCreationView.tagInputTextField.text = ""
        // 更新标签展示
        updateTagListLabel()
    }

    
    //更新发布按钮的可用性
    func updatePublishButtonState() {
        publishButton?.isEnabled = postCreationView.titleTextField.text != "" && postCreationView.contentTextView.text != ""
    }

    // 更新底部“已添加标签”展示
    private func updateTagListLabel() {
        if customTags.isEmpty {
            postCreationView.tagListLabel.text = nil
            return
        }
        let joined = customTags.joined(separator: "  ")
        postCreationView.tagListLabel.text = "已添加标签：\(joined)"
    }
}

