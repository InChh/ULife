//
//  ActivityViewController.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import UIKit

class ActivityViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    private let typeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["全部", "讲座", "社团", "竞赛"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private var listItems: [ActivityListItem] = []
    private var pagination: ActivityPagination?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "活动"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        loadData()
    }

    private func setupUI() {
        // 搜索
        searchController.searchBar.placeholder = "搜索活动标题/地点"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // 顶部筛选
        typeSegmentedControl.addTarget(self, action: #selector(typeChanged(_:)), for: .valueChanged)
        typeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(typeSegmentedControl)

        // 表格
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ActivityCell.self, forCellReuseIdentifier: ActivityCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            typeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            typeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: typeSegmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        let keyword = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let type = selectedType()
        let result = ActivityDataManager.shared.fetchActivities(keyword: keyword, activityType: type, page: 1, pageSize: 20)
        listItems = result.list
        pagination = result.pagination
        tableView.reloadData()
    }

    private func selectedType() -> ActivityType? {
        switch typeSegmentedControl.selectedSegmentIndex {
        case 1: return .lecture
        case 2: return .club
        case 3: return .competition
        default: return nil
        }
    }

    @objc private func typeChanged(_ sender: UISegmentedControl) {
        loadData()
    }
}

// MARK: - TableView
extension ActivityViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCell.reuseId, for: indexPath) as? ActivityCell else {
            return UITableViewCell()
        }
        let item = listItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = listItems[indexPath.row]
        guard let detail = ActivityDataManager.shared.getActivityDetail(activityId: item.id) else { return }
        let detailVC = ActivityDetailViewController(activity: detail)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Search
extension ActivityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadData()
    }
}

// MARK: - Cell
final class ActivityCell: UITableViewCell {
    static let reuseId = "ActivityCell"

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let metaLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1

        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .tertiaryLabel

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, metaLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with item: ActivityListItem) {
        titleLabel.text = item.title
        subtitleLabel.text = "\(item.location)"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日 HH:mm"
        let timeText = dateFormatter.string(from: item.startTime)
        metaLabel.text = "\(timeText) · \(item.currentEnrollments)/\(item.quota) 人"
    }
}
