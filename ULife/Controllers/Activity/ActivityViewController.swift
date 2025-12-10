//
//  ActivityViewController.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import UIKit

final class ActivityViewController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .singleLine
        tv.backgroundColor = .systemGroupedBackground
        tv.register(ActivityCell.self, forCellReuseIdentifier: ActivityCell.identifier)
        return tv
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "搜索活动"
        sb.searchBarStyle = .minimal
        return sb
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["全部", "讲座", "社团", "竞赛"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private var activities: [ActivityListItem] = []
    private var currentPage = 1
    private var hasMore = true
    private var isLoading = false
    
    private let activityService = ActivityService.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadActivities()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "活动"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupBindings() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        searchBar.delegate = self
        
        // 添加下拉刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshActivities), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Actions
    
    @objc private func segmentChanged() {
        currentPage = 1
        hasMore = true
        isLoading = false
        activities.removeAll()
        tableView.reloadData() // 立即刷新，避免显示旧数据
        loadActivities()
    }
    
    @objc private func refreshActivities() {
        currentPage = 1
        hasMore = true
        isLoading = false
        activities.removeAll()
        tableView.reloadData() // 立即刷新，避免显示旧数据
        loadActivities()
    }
    
    // MARK: - Data Loading
    
    private func loadActivities() {
        guard !isLoading else { return }
        guard hasMore else { return }
        
        isLoading = true
        
        let activityType: ActivityType? = {
            let index = segmentedControl.selectedSegmentIndex
            if index == 0 { return nil }
            return ActivityType(rawValue: index)
        }()
        
        Task {
            do {
                let keyword = searchBar.text?.isEmpty == false ? searchBar.text : nil
                let result = try await activityService.fetchActivities(
                    keyword: keyword,
                    activityType: activityType,
                    page: currentPage
                )
                
                await MainActor.run {
                    self.activities.append(contentsOf: result.activities)
                    self.hasMore = result.pagination.page < result.pagination.pages
                    self.currentPage += 1
                    self.isLoading = false
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.tableView.refreshControl?.endRefreshing()
                    self.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        let message = error.localizedDescription
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ActivityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ActivityCell.identifier,
            for: indexPath
        ) as? ActivityCell else {
            return UITableViewCell()
        }
        
        // 添加边界检查，防止数组越界
        guard indexPath.row < activities.count else {
            return cell
        }
        
        cell.configure(with: activities[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ActivityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 添加边界检查，防止数组越界
        guard indexPath.row < activities.count else {
            return
        }
        
        let activity = activities[indexPath.row]
        let detailVC = ActivityDetailViewController(activityId: activity.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 加载更多
        if indexPath.row == activities.count - 1 && hasMore && !isLoading {
            loadActivities()
        }
    }
}

// MARK: - UISearchBarDelegate

extension ActivityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        currentPage = 1
        activities.removeAll()
        tableView.reloadData() // 立即刷新，避免显示旧数据
        loadActivities()
    }
}
