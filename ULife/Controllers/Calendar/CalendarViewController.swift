//
//  CalendarViewController.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//  Edited by 高煜尧
//

import UIKit

/// UI 层课程模型 （由后端映射用于展示）
struct Course {
    let courseId: Int
    let name: String
    let timeRange: String
    let startSection: Int
    let endSection: Int
    let location: String
    let teacher: String
    let dayOfWeek: Int
    let typeDisplay: String
    let credits: Int
    let descriptionText: String
    let color: UIColor
}

final class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // 切换选择默认值 0：展示全部课程；1: 按天分组视图
    private var selectedSegementIndex = 0
    // 原始课程列表
    private var courses: [Course] = []
    // 按周几分足后的课程
    private var groupedCourses: [[Course]] = []
    
    // 硬编码定义节次时间表
    private let sectionSlots: [Int: SectionSlot] = [
        1: SectionSlot(start: "08:00", end: "08:45"),
        2: SectionSlot(start: "08:55", end: "09:40"),
        3: SectionSlot(start: "10:00", end: "10:45"),
        4: SectionSlot(start: "10:55", end: "11:40"),
        5: SectionSlot(start: "14:00", end: "14:45"),
        6: SectionSlot(start: "14:55", end: "15:40")
    ]

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["课程显示", "视图显示"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .systemGroupedBackground
        tv.register(CourseCell.self, forCellReuseIdentifier: CourseCell.identifier)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "课程"
        view.backgroundColor = .systemGroupedBackground

        setupLayout()
        loadData()
        runNotificationTest()
    }

    private func setupLayout() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedSegementIndex = sender.selectedSegmentIndex
        // 视图显示模式可在此扩展
        regroupWeekly()
        tableView.reloadData()
    }
    
    /// 拉取学期 -> 推算当前周次 -> 用学期和周次拉取课表
    private func loadData(){
        // 先拿学期列表，取当前学期和当前周，再拉课表（此处用 mock，可切换 useMock = false 对接真实接口）
        CalendarDataManager.shared.fetchSemesters(useMock: true) { [weak self] semesters in
            guard let self = self else { return }
            let current = semesters.first(where: { $0.isCurrent }) ?? semesters.first
            let week = current?.currentWeek() ?? 1
            let semesterId = Int(current?.id ?? 0)

            CalendarDataManager.shared.fetchSchedule(useMock: true,
                                                     semesterId: semesterId,
                                                     week: week) { [weak self] items in
                guard let self = self else { return }
                self.courses = items.map { $0.toUICourse(sectionSlots: self.sectionSlots) }
                self.regroupWeekly()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    
    // MARK: 临时测试代码
        func runNotificationTest() {
            print("开始测试推送...")
            
            // 获取当前时间 + 2分钟
            let now = Date()
            let calendar = Calendar.current
            guard let targetDate = calendar.date(byAdding: .minute, value: 2, to: now) else { return }
            
            // 转换星期
            let iosWeekday = calendar.component(.weekday, from: now)
            let myModelDay = (iosWeekday == 1) ? 7 : (iosWeekday - 1)
            
            // 构造时间字符串 "HH:mm"
            let hour = calendar.component(.hour, from: targetDate)
            let minute = calendar.component(.minute, from: targetDate)
            let timeString = String(format: "%02d:%02d", hour, minute)
            
            // 造一个假的时间表 (Mock Slots)
            // 假设这是一个第 999 节课
            let testSectionId = 999
            let testSlots: [Int: SectionSlot] = [
                testSectionId: SectionSlot(start: timeString, end: "23:59")
            ]
            
            // 造一个假课程
            let testCourse = Course(
                courseId: 8888,
                name: "测试课",
                timeRange: "测试时间",
                startSection: testSectionId, // 关联上面的时间表
                endSection: testSectionId,
                location: "测试地点",
                teacher: "调试老师",
                dayOfWeek: myModelDay,      // 必须是今天
                typeDisplay: "测试",
                credits: 0,
                descriptionText: "1分钟后响铃",
                color: .red
            )
            
            // 调用Manager
            print("正在设置闹钟：课程时间 \(timeString)，提前 1 分钟...")
            
            CourseReminderManager.shared.requestAuthorization { granted in
                guard granted else {
                    print("没有通知权限")
                    return
                }
                
                // 你的 Manager 逻辑是：课程时间 - leadMinutes = 响铃时间
                // 所以：(当前+2分钟) - 1分钟 = 当前+1分钟
                CourseReminderManager.shared.enableReminder(
                    for: testCourse,
                    sectionSlots: testSlots, // 传入刚才造的假时间表
                    leadMinutes: 1
                )
                print("设置成功！请等待 1 分钟，留意顶部弹窗。")
            }
        }
    
    
    
    private func regroupWeekly(){
        let weekdayOrder = [1, 2, 3, 4, 5, 6, 7]
        groupedCourses = weekdayOrder.map { day in
                    courses
                        .filter { $0.dayOfWeek == day }
                        .sorted { $0.startSection < $1.startSection } // 同一天按照节次生序排列
                }
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedSegementIndex == 1 {
            return groupedCourses.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegementIndex == 1 {
            return groupedCourses[section].count
        }
        return courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.identifier, for: indexPath) as? CourseCell else {
            return UITableViewCell()
        }
        if selectedSegementIndex == 1 {
            cell.configure(with: groupedCourses[indexPath.section][indexPath.row])
        } else {
            cell.configure(with: courses[indexPath.row])
        }
        return cell
    }

    // section 头部标题
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard selectedSegementIndex == 1 else { return nil }
        let header = UIView()
        header.backgroundColor = .systemGroupedBackground
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.text = weekdayText(section + 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return selectedSegementIndex == 1 ? 30 : 0
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let course: Course
        if selectedSegementIndex == 1 {
            course = groupedCourses[indexPath.section][indexPath.row]
        } else {
            course = courses[indexPath.row]
        }
        let detailVC = CourseDetailViewController(course: course, sectionSlots: sectionSlots)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
    
private func weekdayText(_ day: Int) -> String {        let names = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    let idx = day - 1
    if idx >= 0 && idx < names.count { return names[idx] }
    return "周\(day)"
}





/// 二级菜单：课程详情页
final class CourseDetailViewController: UIViewController {


    private let course: Course
    private let sectionSlots: [Int: SectionSlot]
    private let reminderSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .systemBlue
        return sw
    }()
    private let leadOptions = [10, 30, 60]
    private lazy var leadSegment: UISegmentedControl = {
        let control = UISegmentedControl(items: ["提前10分钟", "提前30分钟", "提前60分钟"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()


    private let courseIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let teacherLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let creditsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    init(course: Course, sectionSlots: [Int: SectionSlot]) {
        self.course = course
        self.sectionSlots = sectionSlots
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "课程详情"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        configure()
        setupReminder()
    }

    private func setupUI() {
        
        let reminderRow = UIStackView(arrangedSubviews: [
            {
                let lbl = UILabel()
                lbl.text = "课前提醒"
                lbl.font = .systemFont(ofSize: 16, weight: .regular)
                lbl.textColor = .label
                return lbl
            }(),
            reminderSwitch
        ])
        reminderRow.axis = .horizontal
        reminderRow.spacing = 8
        reminderRow.alignment = .center
        
        let leadRow = UIStackView(arrangedSubviews: [
            leadSegment
        ])
        leadRow.axis = .vertical
        leadRow.spacing = 6
        leadRow.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [
            nameLabel,
            courseIdLabel,
            teacherLabel,
            timeLabel,
            locationLabel,
            typeLabel,
            creditsLabel,
            descriptionLabel,
            reminderRow,
            leadRow
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading

        let card = UIView()
        card.backgroundColor = course.color.withAlphaComponent(0.15)
        card.layer.cornerRadius = 12
        card.layer.masksToBounds = true


        card.addSubview(stack)
        view.addSubview(card)


        card.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false


        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),


            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }


    private func configure() {
        nameLabel.text = course.name
        courseIdLabel.text = "课程ID：\(course.courseId)"
        teacherLabel.text = "老师：\(course.teacher)"
        timeLabel.text = "时间：\(weekdayText(course.dayOfWeek))\(course.timeRange)"
        locationLabel.text = "地点：\(course.location)"
        typeLabel.text = "课程类型：\(course.typeDisplay)"
        creditsLabel.text = "学分：\(course.credits)"
        descriptionLabel.text = "课程描述：\(course.descriptionText)"
    }

    private func setupReminder() {
        reminderSwitch.isOn = CourseReminderManager.shared.isReminderEnabled(for: course)
        reminderSwitch.addTarget(self, action: #selector(reminderSwitchChanged(_:)), for: .valueChanged)
        let savedLead = CourseReminderManager.shared.leadMinutes(for: course)
        if let idx = leadOptions.firstIndex(of: savedLead) {
            leadSegment.selectedSegmentIndex = idx
        } else {
            leadSegment.selectedSegmentIndex = 0
        }
        leadSegment.addTarget(self, action: #selector(leadSegmentChanged(_:)), for: .valueChanged)
    }

    @objc private func reminderSwitchChanged(_ sender: UISwitch) {
        CourseReminderManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if !granted {
                    sender.isOn = false
                    return
                }
                if sender.isOn {
                    CourseReminderManager.shared.enableReminder(for: self.course, sectionSlots: self.sectionSlots)
                } else {
                    CourseReminderManager.shared.disableReminder(for: self.course)
                }
            }
        }
    }

    @objc private func leadSegmentChanged(_ sender: UISegmentedControl) {
            guard reminderSwitch.isOn else { return }
            CourseReminderManager.shared.enableReminder(for: course, sectionSlots: sectionSlots, leadMinutes: currentLeadMinutes())
    }


    private func currentLeadMinutes() -> Int {
        let idx = leadSegment.selectedSegmentIndex
        if idx >= 0 && idx < leadOptions.count {
            return leadOptions[idx]
        }
        return leadOptions.first ?? 10
    }

    private func weekdayText(_ day: Int) -> String {
        let names = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
        let idx = day - 1
        if idx >= 0 && idx < names.count { return names[idx] }
        return "周\(day)"
    }
}




