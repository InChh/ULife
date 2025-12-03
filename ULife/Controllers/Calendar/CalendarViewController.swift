//
//  CalendarViewController.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//  Edited by 高煜尧
//

import UIKit

struct Course{
    let name: String
    let timeRange: String
    let location: String
    let teacher: String
    let color: UIColor
}

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var selectedSegementIndex = 0
    private var courses : [Course] = []
    
    //顶部两个模式切换：课程显示/视图显示 （目前仅课程显示）
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["课程显示", "视图显示"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
    }()
    
    //课程列表
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
        loadMockData()
    }
    
    private func setupLayout(){
        //依次添加控件
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl){
        selectedSegementIndex = sender.selectedSegmentIndex
        //视图显示模式可在此扩展
    }
    
    //mock data：后续接真实数据源
    private func loadMockData(){
        courses = [
            Course(name: "计算机网络",
                   timeRange: "8:30 - 9:50",
                   location: "教二-201",
                   teacher: "王教授",
                   color: .white
                  ),
            Course(name: "数据结构",
                   timeRange: "8:30 - 9:50",
                   location: "教一-101",
                   teacher: "李教授",
                   color: .white
                  ),
            Course(name: "人工智能",
                   timeRange: "14:30 - 15:50",
                   location: "教三-301",
                   teacher: "刘教授",
                   color: .white
                  )
        ]
        tableView.reloadData()
    }
    
    //UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.identifier, for: indexPath) as? CourseCell else {
            return UITableViewCell()
        }
        cell.configure(with: courses[indexPath.row])
        return cell
    }
    
    //UITableViewDelegate
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 进入课程详情
        let detailVC = CourseDetailViewController(course: courses[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// 课程详情页面
final class CourseDetailViewController: UIViewController {
    
    private let course: Course
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
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
    
    private let teacherLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    init(course: Course) {
        self.course = course
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        title = "课程详情"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        configure()
    }
    
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [nameLabel, timeLabel, locationLabel, teacherLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        
        let card = UIView()
        card.backgroundColor = .white
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
        timeLabel.text = "时间：\(course.timeRange)"
        locationLabel.text = "地点：\(course.location)"
        teacherLabel.text = "老师：\(course.teacher)"
    }
}
