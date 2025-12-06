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
    
    // 标签数据源
    private let tags = ["社团活动", "学习交流", "二手市场", "求助", "校内通知"]
    
    private var selectedTagIndex:[Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        

        setupViews()
        setupLayout()
        
        setupNavigationBar()
    }
    
    
    private func setupViews() {
        // 将 Controller 自身设置为 View 元素的代理
        postCreationView.titleTextField.delegate = self
        postCreationView.contentTextView.delegate = self
        
        // 设置 CollectionView 代理
        postCreationView.tagsCollectionView.delegate = self
        postCreationView.tagsCollectionView.dataSource = self
        
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
    
    

    private func setupNavigationBar() {
        navigationItem.title = "发帖"

        // 右上角发布按钮
        let publish = UIBarButtonItem(
            title: "发布",
            style: .done,
            target: self,
            action: #selector(handlePublish)
        )
        navigationItem.rightBarButtonItem = publish
        self.publishButton = publish

        // 初始状态检查
        updatePublishButtonState()
    }

    @objc private func handlePublish() {
        if !createPostRequest.isValid {
            Toast.show("标题和内容不能为空", style: .error)
            return
        }

        // 禁用按钮防止重复提交
        publishButton?.isEnabled = false
        
        createPostRequest.tags = selectedTagIndex.compactMap { index in
            tags.indices.contains(index) ? tags[index] : nil
        }
        
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



// 扩展实现 CollectionView 代理和数据源
extension PostCreationViewController: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // 每个分区有多少项目
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return tags.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagCell.identifier,
                for: indexPath
            ) as? TagCell
        else {
            return UICollectionViewCell()
        }

        let isSelected = (selectedTagIndex.contains(indexPath.row))  //是否选中
        cell.configure(with: tags[indexPath.row], isSelected: isSelected)
        return cell
    }

    // 点击调用
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        if selectedTagIndex.contains(indexPath.row){
            let existingIndex = selectedTagIndex.firstIndex(of: indexPath.row)
            selectedTagIndex.remove(at: existingIndex!)
        }else{
            selectedTagIndex.append(indexPath.row)
        }

        collectionView.reloadData()  // 刷新 CollectionView 来更新选中状态

        let selectedTag = tags[indexPath.row]
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
        tempLabel.text = tags[indexPath.row]
        tempLabel.sizeToFit()

        // 宽度 = 文本宽度 + 左右各 16pt 的边距 (总共 32pt 额外填充)
        let width = tempLabel.frame.width + 32

        
        return CGSize(width: width, height: 36)
    }
}
