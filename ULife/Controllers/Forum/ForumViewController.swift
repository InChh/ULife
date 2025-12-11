//
//  ForumViewController.swift
//  ULife
//
//  论坛主页 - 参考活动模块重写

import UIKit

class ForumViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let categorySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["全部", "热议", "学习", "生活", "求助"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private var posts: [PostLite] = []
    private var boards: [Board] = []
    private var currentPage = 1
    private var isLoading = false
    private var hasMore = true
    private var currentSort: Sort = .latest
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "论坛"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        loadBoards()
        loadPosts()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // 排序按钮
        let sortButton = UIBarButtonItem(title: "最新", style: .plain, target: self, action: #selector(handleSortTap))
        navigationItem.rightBarButtonItem = sortButton
        
        // 搜索
        searchController.searchBar.placeholder = "搜索帖子"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // 分类
        categorySegmentedControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        categorySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categorySegmentedControl)
        
        // 表格
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ForumPostCell.self, forCellReuseIdentifier: ForumPostCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // 发帖按钮
        let createButton = UIButton(type: .system)
        createButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.tintColor = .white
        createButton.layer.cornerRadius = 28
        createButton.layer.shadowColor = UIColor.black.cgColor
        createButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        createButton.layer.shadowOpacity = 0.3
        createButton.layer.shadowRadius = 4
        createButton.addTarget(self, action: #selector(handleCreatePost), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            categorySegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 56),
            createButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    // MARK: - Data Loading
    private func loadBoards() {
        Task {
            do {
                boards = try await ForumRequestProto().getBoard()
            } catch {
                print("加载板块失败: \(error)")
            }
        }
    }
    
    private func loadPosts(refresh: Bool = true) {
        guard !isLoading else { return }
        isLoading = true
        
        if refresh {
            currentPage = 1
            hasMore = true
        }
        
        let keyword = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let boardId = selectedBoardId()
        
        let request = GetPostListRequest(
            boardId: boardId,
            filter: .all,
            keyword: keyword?.isEmpty == false ? keyword : nil,
            page: currentPage,
            pageSize: 20,
            sort: currentSort
        )
        
        Task {
            do {
                let response = try await ForumRequestProto().GetPostList(request: request)
                
                await MainActor.run {
                    if refresh {
                        self.posts = response.list
                    } else {
                        self.posts.append(contentsOf: response.list)
                    }
                    
                    self.hasMore = response.list.count >= 20
                    if !refresh {
                        self.currentPage += 1
                    }
                    self.isLoading = false
                    self.tableView.reloadData()
                }
            } catch {
                print("加载帖子失败: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.showError(error)
                }
            }
        }
    }
    
    private func selectedBoardId() -> String? {
        let index = categorySegmentedControl.selectedSegmentIndex
        guard index > 0, boards.count >= index else { return nil }
        return boards[index - 1].id
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "加载失败",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func categoryChanged() {
        loadPosts(refresh: true)
    }
    
    @objc private func handleSortTap() {
        let alert = UIAlertController(title: "排序方式", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "最新回复", style: .default) { [weak self] _ in
            self?.currentSort = .latest
            self?.navigationItem.rightBarButtonItem?.title = "最新"
            self?.loadPosts(refresh: true)
        })
        
        alert.addAction(UIAlertAction(title: "最新发布", style: .default) { [weak self] _ in
            self?.currentSort = .new
            self?.navigationItem.rightBarButtonItem?.title = "最新"
            self?.loadPosts(refresh: true)
        })
        
        alert.addAction(UIAlertAction(title: "最热", style: .default) { [weak self] _ in
            self?.currentSort = .hot
            self?.navigationItem.rightBarButtonItem?.title = "最热"
            self?.loadPosts(refresh: true)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func handleCreatePost() {
        let createVC = PostCreationViewController()
        createVC.boards = boards
        createVC.onPostCreated = { [weak self] in
            self?.loadPosts(refresh: true)
        }
        let nav = UINavigationController(rootViewController: createVC)
        present(nav, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension ForumViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForumPostCell.identifier, for: indexPath) as? ForumPostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = posts[indexPath.row]

        Task {
            do {
                let detail = try await ForumRequest().GetPostDetail(id: post.id)
                await MainActor.run {
                    let vc = ForumDetailViewController(post: detail)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "加载失败", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == posts.count - 1 && hasMore && !isLoading {
            loadPosts(refresh: false)
        }
    }
}

// MARK: - SearchBar Delegate
extension ForumViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        loadPosts(refresh: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        loadPosts(refresh: true)
    }
}
