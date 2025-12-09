//
//  ForumViewController.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//  论坛主页 UI

import UIKit

class ForumViewController: UIViewController {
    
    private let mainView = ForumMainView()

    // 原始帖子列表数据
    private var allPosts: [ForumPost] = []
    
    // 导航栏中的排序按钮 + 搜索框 + 搜索按钮
    private lazy var sortButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("最新", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        btn.tintColor = .label
        btn.backgroundColor = .clear
        btn.contentEdgeInsets = UIEdgeInsets(
            top: 4,
            left: 8,
            bottom: 4,
            right: 8
        )
        btn.semanticContentAttribute = .forceLeftToRight
        return btn
    }()
    private lazy var searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "搜索帖子"
        tf.font = .systemFont(ofSize: 15)
        tf.borderStyle = .none
        tf.backgroundColor = .systemGray5
        tf.layer.cornerRadius = 20
        tf.clipsToBounds = true
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .search
        // 左侧留一点内边距
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("| 搜索", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.tintColor = .systemBlue
        btn.backgroundColor = .systemGray5
        btn.layer.cornerRadius = 14
        // 内边距：左一点空隙，右边稍微大一点
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 10)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupBindings()

        loadMockData()
    }

    private func setupViews() {
        // 设置 tableView 代理
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self

        // 设置 CollectionView 代理
        mainView.CategoryCollectionView.delegate = self
        mainView.CategoryCollectionView.dataSource = self
        
        setupNavigationBar()
        view.addSubview(mainView)
    }

    // 设置导航栏上的排序 + 搜索 UI
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: sortButton)
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.rightView = searchButton
        searchTextField.rightViewMode = .always
        
        // 动态宽度
        let screenWidth = UIScreen.main.bounds.width
        let horizontalMargin: CGFloat = 16 //空隙
        let approximateSortButtonWidth: CGFloat = 60 //估算的排序按钮
        let maxWidth = max(
            0,
            screenWidth - approximateSortButtonWidth - horizontalMargin * 2
        )
        
        NSLayoutConstraint.activate([
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            searchTextField.widthAnchor.constraint(equalToConstant: maxWidth)
        ])

        navigationItem.titleView = searchTextField
    }

    //设置布局
    private func setupLayout() {
        mainView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // 装载原始数据
    private func loadMockData() {
        allPosts = MockForumPostData.posts
        applyFilterAndSort()
    }


    //绑定事件
    private func setupBindings() {
        //发帖按钮
        mainView.createPostButton.addAction(
            UIAction(handler: { _ in
                self.ComeTocreatePost()
            }),
            for: .touchUpInside
        )

        // 排序按钮
        sortButton.addTarget(
            self,
            action: #selector(handleSortButtonTap),
            for: .touchUpInside
        )

        // 搜索按钮
        searchButton.addTarget(
            self,
            action: #selector(handleSearchButtonTap),
            for: .touchUpInside
        )

        // 键盘回车也触发搜索
        searchTextField.addTarget(
            self,
            action: #selector(handleSearchReturn),
            for: .editingDidEndOnExit
        )
    }

    private func ComeTocreatePost() {
        let postCreationViewController = PostCreationViewController()
        navigationController?.pushViewController(
            postCreationViewController,
            animated: true
        )
    }
    
    @objc private func handleSortButtonTap() {
        let alert = UIAlertController(
            title: "选择排序方式",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(
            UIAlertAction(
                title: "最新",
                style: .default,
                handler: { [weak self] _ in
                    sortMode = .latest
                    self?.sortButton.setTitle("最新", for: .normal)
                    self?.applyFilterAndSort()
                }
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "热度",
                style: .default,
                handler: { [weak self] _ in
                    sortMode = .hot
                    self?.sortButton.setTitle("热度", for: .normal)
                    self?.applyFilterAndSort()
                }
            )
        )

        present(alert, animated: true)
    }
    
    
    @objc private func handleSearchButtonTap() {
        view.endEditing(true)
        applyFilterAndSort()
    }

    @objc private func handleSearchReturn() {
        applyFilterAndSort()
    }
    

    
    
    
    ///搜索 并更新 tableView
    // 根据当前排序方式 / 标签 / 搜索关键字更新列表
    func applyFilterAndSort() {
        var filtered = allPosts

        // 1. 标签筛选（除“全部”外，按 category 匹配）
        let selectedCategory = categorys[MainselectedCategoryIndex]
        if selectedCategory != "全部" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        var key = ""
        // 2. 搜索关键词筛选（标题 / 内容）
        if let keyword = searchTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !keyword.isEmpty
        {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(keyword)
                    || $0.content.localizedCaseInsensitiveContains(keyword)
            }
            key = keyword
        }

        // 3. 排序
        switch sortMode {
        case .latest:
            // 按发布时间从新到旧
            filtered.sort { $0.publishTime > $1.publishTime }
            sortButton.setTitle("最新", for: .normal)
        case .hot:
            // 按热度从高到低（这里简单用点赞数衡量）
            filtered.sort {
                if $0.likeCount == $1.likeCount {
                    return $0.publishTime > $1.publishTime
                }
                return $0.likeCount > $1.likeCount
            }
            sortButton.setTitle("热度", for: .normal)
        }
        
        print("\(selectedCategory) \(key)  \(sortMode)")

        posts = filtered
        mainView.tableView.reloadData()
    }
}
