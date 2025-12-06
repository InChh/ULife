//
//  ForumViewController.swift
//  ULife
//
//  Created by 刘宏伟 on 2025/12/1.
//

import UIKit

class ForumViewController: UIViewController {
    private let mainView = ForumMainView()

    // 模拟数据源
    private var posts: [ForumPost] = []

    // 标签数据源
    private let tags = ["全部", "社团活动", "学习交流", "二手市场", "求助", "校内通知"]

    private var selectedTagIndex: Int = 0  // 默认选中"全部"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupBindings()

        loadMockData()
    }

    private func setupViews() {
        title = "校园论坛"

        // 设置 tableView 代理
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self

        // 设置 CollectionView 代理
        mainView.tagsCollectionView.delegate = self
        mainView.tagsCollectionView.dataSource = self
        view.addSubview(mainView)
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

        posts = [
            ForumPost(
                id: UUID().uuidString,
                title: "关于校园音乐节的报名通知",
                authorName: "张三",
                authorAvatar: "",
                content: "今年的校园音乐节将在下个月举办，欢迎大家踊跃报名参与，详情请查看教务处通知。",
                tags: ["#社团", "#社团活动"],
                commentCount: 12,
                likeCount: 76,
                createTime: Date(timeIntervalSinceNow: -3600 * 5),  // 5 小时前
                updateTime: Date(timeIntervalSinceNow: -3600 * 3)
            ),

            ForumPost(
                id: UUID().uuidString,
                title: "求问图书馆自习室预约技巧",
                authorName: "李四",
                authorAvatar: "",
                content: "最近自习室太难约了，大家有没有什么一定成功的预约技巧？在线等，挺急的。",
                tags: ["#社团", "#讲座"],
                commentCount: 30,
                likeCount: 120,
                createTime: Date(timeIntervalSinceNow: -3600 * 26),  // 1 天 + 2 小时前
                updateTime: Date(timeIntervalSinceNow: -3600 * 25)
            ),

            ForumPost(
                id: UUID().uuidString,
                title: "篮球社招新啦！",
                authorName: "王五",
                authorAvatar: "",
                content: "篮球社正在招募新成员，无论水平如何，只要你热爱篮球，我们都欢迎！",
                tags: ["#社团", "#讲座"],
                commentCount: 5,
                likeCount: 45,
                createTime: Date(timeIntervalSinceNow: -3600 * 72),  // 3 天前
                updateTime: Date(timeIntervalSinceNow: -3600 * 70)
            ),

            ForumPost(
                id: UUID().uuidString,
                title: "分享一下最近的学习 App",
                authorName: "小明",
                authorAvatar: "https://example.com/avatar4.png",
                content: "入坑一个非常好用的学习 App，支持自动规划学习计划，推荐给大家。",
                tags: ["#社团", "#讲座"],
                commentCount: 8,
                likeCount: 33,
                createTime: Date(timeIntervalSinceNow: -60 * 15),  // 15 分钟前
                updateTime: Date(timeIntervalSinceNow: -60 * 10)
            ),
            ForumPost(
                id: UUID().uuidString,
                title: "分享一下最近的学习 App",
                authorName: "小明",
                authorAvatar: "https://example.com/avatar4.png",
                content: "入坑一个非常好用的学习 App，支持自动规划学习计划，推荐给大家。",
                tags: ["#社团", "#讲座"],
                commentCount: 8,
                likeCount: 33,
                createTime: Date(timeIntervalSinceNow: -60 * 15),  // 15 分钟前
                updateTime: Date(timeIntervalSinceNow: -60 * 10)
            ),
            ForumPost(
                id: UUID().uuidString,
                title: "分享一下最近的学习 App",
                authorName: "小明",
                authorAvatar: "https://example.com/avatar4.png",
                content: "入坑一个非常好用的学习 App，支持自动规划学习计划，推荐给大家。",
                tags: ["#社团", "#讲座"],
                commentCount: 8,
                likeCount: 33,
                createTime: Date(timeIntervalSinceNow: -60 * 15),  // 15 分钟前
                updateTime: Date(timeIntervalSinceNow: -60 * 10)
            ),
            ForumPost(
                id: UUID().uuidString,
                title: "分享一下最近的学习 App",
                authorName: "小明",
                authorAvatar: "https://example.com/avatar4.png",
                content: "入坑一个非常好用的学习 App，支持自动规划学习计划，推荐给大家。",
                tags: ["#社团", "#讲座"],
                commentCount: 8,
                likeCount: 33,
                createTime: Date(timeIntervalSinceNow: -60 * 15),  // 15 分钟前
                updateTime: Date(timeIntervalSinceNow: -60 * 10)
            ),
        ]
        mainView.tableView.reloadData()
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
        return tags.count
    }
    //从复用池取 cell
    //    尝试转换为你自定义的 ForumPostCell
    //    如果成功 → 得到强类型的 cell
    //    如果失败 → 返回一个空的默认 cell（避免崩溃）
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

        let isSelected = (indexPath.row == selectedTagIndex)  //是否选中
        cell.configure(with: tags[indexPath.row], isSelected: isSelected)
        return cell
    }

    // 点击调用
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        selectedTagIndex = indexPath.row
        collectionView.reloadData()  // 刷新 CollectionView 来更新选中状态

        let selectedTag = tags[indexPath.row]
        print("选中了标签: \(selectedTag)")

        // todo筛选逻辑

    }

    // 根据每一个标签内容的长度设置每一个 cell 的宽度和高度
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // 1. 创建一个临时的 Label，计算文本实际需要的宽度
        let tempLabel = UILabel()
        tempLabel.font = .systemFont(ofSize: 14, weight: .medium)
        tempLabel.text = tags[indexPath.row]
        tempLabel.sizeToFit()

        // 2. 宽度 = 文本宽度 + 左右各 16pt 的边距 (总共 32pt 额外填充)
        let width = tempLabel.frame.width + 32

        // 3. 高度固定为 CollectionView 的高度 (44pt)
        return CGSize(width: width, height: 44)
    }

}
