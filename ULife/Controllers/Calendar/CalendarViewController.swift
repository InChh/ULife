//
//  CalendarViewController.swift
//  ULife
//
//  课表主页 - 参考活动模块重写

import UIKit

class CalendarViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private var scheduleItems: [ScheduleItem] = []
    private var semesters: [Semester] = []
    private var currentSemesterId = 1
    
    // 节次时间表
    private let sectionSlots: [Int: (start: String, end: String)] = [
        1: ("08:00", "08:45"),
        2: ("08:55", "09:40"),
        3: ("10:00", "10:45"),
        4: ("10:55", "11:40"),
        5: ("14:00", "14:45"),
        6: ("14:55", "15:40"),
        7: ("16:00", "16:45"),
        8: ("16:55", "17:40")
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "课表"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        loadSemestersAndSchedule()
    }

    // MARK: - Setup UI
    private func setupUI() {
        // 表格
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CourseCell.self, forCellReuseIdentifier: CourseCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadSemestersAndSchedule() {
        Task {
            do {
                let semestersResponse = try await CalendarRequest().getSemesters()
                await MainActor.run {
                    self.semesters = semestersResponse
                    if let currentSemester = semestersResponse.first(where: { $0.is_current }) {
                        self.currentSemesterId = currentSemester.id
                    } else if let first = semestersResponse.first {
                        self.currentSemesterId = first.id
                    }
                }
                await MainActor.run {
                    self.loadSchedule()
                }
            } catch {
                print("加载学期失败: \(error)")
                // 即便学期加载失败，也尝试使用默认学期ID
                await MainActor.run {
                    self.loadSchedule()
                }
            }
        }
    }
    
    private func loadSchedule() {
        Task {
            do {
                scheduleItems = try await CalendarRequest().getUserSchedule(semesterId: currentSemesterId)
                
                await MainActor.run {
                    self.tableView.reloadData()
                }
            } catch {
                print("加载课表失败: \(error)")
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
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
}

// MARK: - TableView DataSource & Delegate
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    
        func numberOfSections(in tableView: UITableView) -> Int {
        return 7 // 周一到周日
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dayOfWeek = section + 1
        return scheduleItems.filter { $0.dayOfWeek == dayOfWeek }.count
            }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        let dayOfWeek = section + 1
        let coursesForDay = scheduleItems.filter { $0.dayOfWeek == dayOfWeek }
        return coursesForDay.isEmpty ? nil : weekdays[section]
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.identifier, for: indexPath) as? CourseCell else {
                return UITableViewCell()
            }
        
        let dayOfWeek = indexPath.section + 1
        let coursesForDay = scheduleItems.filter { $0.dayOfWeek == dayOfWeek }
        
        if coursesForDay.count > indexPath.row {
            let item = coursesForDay[indexPath.row]
            cell.configure(with: item, sectionSlots: sectionSlots)
        }
        
        return cell
    }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        let dayOfWeek = indexPath.section + 1
        let coursesForDay = scheduleItems.filter { $0.dayOfWeek == dayOfWeek }
        
        if coursesForDay.count > indexPath.row {
            let item = coursesForDay[indexPath.row]
            showCourseDetail(item)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dayOfWeek = indexPath.section + 1
        let coursesForDay = scheduleItems.filter { $0.dayOfWeek == dayOfWeek }
        
        guard coursesForDay.count > indexPath.row else { return nil }
        let item = coursesForDay[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] _, _, completion in
            self?.deleteCourse(item)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func showCourseDetail(_ item: ScheduleItem) {
        let alert = UIAlertController(
            title: item.courseName,
            message: """
            教师: \(item.teacherName ?? "未知")
            地点: \(item.location ?? "未知")
            时间: \(formatTime(item))
            学分: \(item.credits ?? 0)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func deleteCourse(_ item: ScheduleItem) {
        Task {
            do {
                try await CalendarRequest().deleteScheduleItem(itemId: item.id)
                await MainActor.run {
                    self.loadSchedule()
                }
            } catch {
                await MainActor.run {
                    self.showError(error)
                }
            }
        }
    }
    
    private func formatTime(_ item: ScheduleItem) -> String {
        let start = sectionSlots[item.startSection]?.start ?? "\(item.startSection)"
        let end = sectionSlots[item.endSection]?.end ?? "\(item.endSection)"
        return "\(start) - \(end)"
    }
}
