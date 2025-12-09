//
//  ForumViewController.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import UIKit

class ForumViewController: UIViewController {
    private let mainView = ForumMainView()

    private var selectedCategoryIndex: Int = 0  // 默认选中"全部"

    // 原始帖子列表数据
    private var allPosts: [ForumPost] = []
    
    // 当前展示的帖子列表（排序 / 筛选 / 搜索之后）
    private var posts: [ForumPost] = []  //帖子列表数据

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
        // 稍微小一点的字号，整体更精致
        tf.font = .systemFont(ofSize: 15)
        // 使用自定义圆角和浅色背景
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

    // 搜索按钮：放在搜索框内部右侧
    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("| 搜索", for: .normal)
        // 字号略小一点，避免太挤
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        // 和排序按钮使用同一套主题色
        btn.tintColor = .systemBlue
        btn.backgroundColor = .systemGray5
        btn.layer.cornerRadius = 14
        // 内边距：左一点空隙，右边稍微大一点，点击面积也更舒适
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 10)
        return btn
    }()

    private enum SortMode {
        case latest  // 最新
        case hot  // 热度
    }

    private var sortMode: SortMode = .latest

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupBindings()
        setupNavigationBar()

        loadMockData()
    }

    private func setupViews() {

        // 设置 tableView 代理
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self

        // 设置 CollectionView 代理
        mainView.tagsCollectionView.delegate = self
        mainView.tagsCollectionView.dataSource = self
        view.addSubview(mainView)
    }

    // 设置导航栏上的排序 + 搜索 UI
    private func setupNavigationBar() {
        // 左上角：排序按钮
        let sortItem = UIBarButtonItem(customView: sortButton)
        navigationItem.leftBarButtonItem = sortItem
        

        // 中间：搜索框，占据剩余空间
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(searchTextField)
        
        // 搜索按钮放在搜索框内部右侧
        searchTextField.rightView = searchButton
        searchTextField.rightViewMode = .always


        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: container.topAnchor),
            searchTextField.bottomAnchor.constraint(
                equalTo: container.bottomAnchor
            ),
            searchTextField.leadingAnchor.constraint(
                equalTo: container.leadingAnchor
            ),
            searchTextField.trailingAnchor.constraint(
                equalTo: container.trailingAnchor
            ),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            container.heightAnchor.constraint(equalToConstant: 40)
        ])

        // 动态宽度
        let screenWidth = UIScreen.main.bounds.width
        let horizontalMargin: CGFloat = 16 //空隙
        let approximateSortButtonWidth: CGFloat = 60 //估算的排序按钮
        let maxWidth = max(
            0,
            screenWidth - approximateSortButtonWidth - horizontalMargin * 2
        )
        container.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true

        // 设置为导航栏的 titleView
        navigationItem.titleView = container
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

    //绑定事件
    private func setupBindings() {
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
        // 导航到详情页
        navigationController?.pushViewController(
            postCreationViewController,
            animated: true
        )
    }

    // 假数据
    private func loadMockData() {

        allPosts = MockForumPostData.posts
        applyFilterAndSort()
    }

    // 根据当前排序方式 / 标签 / 搜索关键字更新列表
    private func applyFilterAndSort() {
        var filtered = allPosts

        // 1. 标签筛选（除“全部”外，按 category 匹配）
        let selectedCategory = categorys[selectedCategoryIndex]
        if selectedCategory != "全部" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }

        // 2. 搜索关键词筛选（标题 / 内容）
        if let keyword = searchTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !keyword.isEmpty
        {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(keyword)
                    || $0.content.localizedCaseInsensitiveContains(keyword)
            }
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

        posts = filtered
        mainView.tableView.reloadData()
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
                    self?.sortMode = .latest
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
                    self?.sortMode = .hot
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
}

// 扩展实现 TableView 代理
extension ForumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ForumPostCell.identifier,
                for: indexPath
            ) as? ForumPostCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let forumDetailController = ForumDetailViewController(
            post: posts[indexPath.row]
        )

        // 导航到详情页
        navigationController?.pushViewController(
            forumDetailController,
            animated: true
        )
    }
}

// 扩展实现 CollectionView 代理和数据源
extension ForumViewController: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    // 每个分区有多少项目
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return categorys.count
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

        let isSelected = (indexPath.row == selectedCategoryIndex)  //是否选中
        cell.configure(with: categorys[indexPath.row], isSelected: isSelected)
        return cell
    }

    // 点击调用
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selectedCategoryIndex = indexPath.row
        collectionView.reloadData()  // 刷新 CollectionView 来更新选中状态

        // 重新应用标签 + 排序 + 搜索逻辑
        applyFilterAndSort()
    }

    // 根据每一个内容的长度设置每一个 cell 的宽度和高度
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // 1. 创建一个临时的 Label，计算文本实际需要的宽度
        let tempLabel = UILabel()
        tempLabel.font = .systemFont(ofSize: 14, weight: .medium)
        tempLabel.text = categorys[indexPath.row]
        tempLabel.sizeToFit()

        // 2. 宽度 = 文本宽度 + 左右各 16pt 的边距 (总共 32pt 额外填充)
        let width = tempLabel.frame.width + 8

        return CGSize(width: width, height: 32)
    }

}
