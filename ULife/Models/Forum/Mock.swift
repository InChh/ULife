//
//  Mock.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/9.
//
import Foundation
import UlifeLib

public extension Board {
    static var mockBoards: [Board] {
        return [
            Board(
                id: "B-001",
                name: "二手交易",
                icon: "💰",
                description: "发布和寻找各种闲置物品，支持同城交易。",
                type: BoardType.staticType.rawValue
            ),
            Board(
                id: "B-002",
                name: "学术交流",
                icon: "📚",
                description: "分享学习经验、笔记和考试资料。",
                type: BoardType.staticType.rawValue
            ),
            Board(
                id: "B-003",
                name: "校园生活",
                icon: "☕",
                description: "记录生活点滴、分享心情、吐槽日常。",
                type: BoardType.staticType.rawValue
            ),
            Board(
                id: "B-004",
                name: "兴趣交友",
                icon: "🤝",
                description: "寻找志同道合的小伙伴，组队游戏、运动或活动。",
                type: BoardType.staticType.rawValue
            ),
            Board(
                id: "B-005",
                name: "文娱热议",
                icon: "🎬",
                description: "近期热门影视、音乐、书籍的讨论区。",
                type: BoardType.staticType.rawValue
            ),
            // 以下模拟管理员临时创建的板块 (dynamic)
            Board(
                id: "B-006",
                name: "校园歌手大赛",
                icon: "🎤",
                description: "本周校园歌手大赛的报名及投票专区。",
                type: BoardType.dynamicType.rawValue
            ),
            Board(
                id: "B-007",
                name: "食堂改进建议",
                icon: "🍽️",
                description: "针对食堂菜品和服务的意见征集。",
                type: BoardType.dynamicType.rawValue
            ),
            Board(
                id: "B-008",
                name: "实习招聘季",
                icon: "💼",
                description: "毕业季招聘信息和面试经验分享。",
                type: BoardType.dynamicType.rawValue
            ),
            Board(
                id: "B-009",
                name: "临时公告栏",
                icon: "⚠️",
                description: "紧急通知：校内停电及检修信息发布。",
                type: BoardType.dynamicType.rawValue
            ),
            Board(
                id: "B-010",
                name: "代码人生",
                icon: "💻",
                description: "记录和讨论各种计算机技术和编程话题。",
                type: BoardType.staticType.rawValue
            )
        ]
    }
}


public extension UserLite {
    static var mockAuthor1: UserLite {
        return UserLite(
            id: "https://example.com/avatars/user_A.jpg",
            studentId: "信息工程学院",
            name: "U-A001",
            avatarUrl: "Allen",
            college: "20210001"
        )
    }
    static var mockAuthor2: UserLite {
        return UserLite(
            id: "https://example.com/avatars/user_B.jpg",
            studentId: "经济管理学院",
            name: "U-B002",
            avatarUrl: "Betty",
            college: "20210002"
        )
    }
}

public extension PostStats {
    static func mockStats(views: Int, likes: Int, comments: Int, collects: Int) -> PostStats {
        return PostStats(viewCount: Int32(views), likeCount: Int32(likes), commentCount: Int32(comments), collectCount: Int32(collects))
    }
}

public extension UserInteraction {
    static var collectedAndLiked: UserInteraction {
        return UserInteraction(isLiked: true, isCollected: true)
    }
    static var notInteracted: UserInteraction {
        return UserInteraction(isLiked: false, isCollected: false)
    }
}

// MARK: - PostLite Helper Function

/// 快速生成一个带有索引的 PostLite 实例
public func mockPostLite(index: Int) -> PostLite {
    let isOdd = index % 2 != 0
    let author: UserLite? = isOdd ? UserLite.mockAuthor1 : UserLite.mockAuthor2
    let stats = PostStats.mockStats(views: 300 + index * 10, likes: 50 + index * 2, comments: 10 + index, collects: 20 + index)
    let summaryContent = "这是关于帖子主题 \(index) 的摘要内容。内容越长越好，但为了演示需要截断..."

    // use ISO8601 string for createdAt to match generated type
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let createdAtString = isoFormatter.string(from: Calendar.current.date(byAdding: .hour, value: -index, to: Date()) ?? Date())

    // generated PostLite expects non-optional coverImageUrl/summary -> provide empty string when absent
    let cover = index % 3 == 0 ? "https://example.com/images/post_\(index).jpg" : ""

    return PostLite(
        id: "P-\(String(format: "%03d", index))",
        title: "这是一个模拟帖子标题 \(index)",
        author: author,
        boardId: isOdd ? "B-001" : "B-002",
        boardName: isOdd ? "二手交易" : "学术交流",
        createdAt: createdAtString,
        tags: ["热门", isOdd ? "交易" : "学习"],
        coverImageUrl: cover,
        summary: String(summaryContent.prefix(50)) + "...",
        stats: stats,
        userInteraction: index < 5 ? UserInteraction.collectedAndLiked : UserInteraction.notInteracted
    )
}


// MARK: - Post Detail Mock

public extension PostDetail {
    
    /// 根据帖子 ID 返回一个模拟的帖子详情 `Post`
    /// - Parameter id: 帖子唯一 ID（例如："P-001"）
    /// - Returns: 对应的 `Post` 详情（若未找到则返回第一条帖子为基础的详情）
    static func mockDetail(for id: String) -> PostDetail {
        // 先在已有的列表数据中查找 PostLite
        let baseLite = PostLite.mockPosts.first { $0.id == id } ?? PostLite.mockPosts.first!

        // 统一使用 ISO8601 字符串作为 createdAt / lastRepliedAt
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let createAtDate = formatter.date(from: baseLite.createdAt) ?? Date()

        let createdAtString = formatter.string(from: createAtDate)
        // 模拟「最后回复时间」比创建时间稍晚一些
        let lastRepliedDate = Calendar.current.date(byAdding: .minute, value: 5, to: createAtDate) ?? createAtDate
        let lastRepliedAtString = formatter.string(from: lastRepliedDate)

        // 模拟附件：如果列表里有封面图，就用它构造一条图片媒体
        let mediaItems: [MediaItem]
        if let cover = baseLite.coverImageUrl {
            let meta = MediaMeta(
                size: "204800",
                width: "1920",
                height: "1080",
                filename: "post_\(baseLite.id)_image.jpg"
            )
            mediaItems = [
                MediaItem(
                    type: "image",
                    url: cover,
                    thumbnailUrl: cover,
                    meta: meta
                )
            ]
        } else {
            mediaItems = []
        }

        // 模拟较长的正文内容
        let content = """
        这是帖子 \(id) 的完整正文内容，用于模拟详情接口返回的数据。
        在真实环境中，这里会包含用户发布的详细文字、说明、步骤、思考等信息。

        为了展示滚动效果，这里特意加长了一些内容：
        - 支持多段文本
        - 支持换行
        - 可以用于调试富文本/Label 自动布局等场景

        感谢你使用 ULife 的论坛功能，这只是 Mock 数据，并不会真正发布到服务器上。
        """

        return PostDetail(
            id: id,
            title: baseLite.title,
            content: content,
            boardId: baseLite.boardId,
            boardName: baseLite.boardName,
            author: baseLite.author,
            tags: baseLite.tags,
            media: mediaItems,
            stats: baseLite.stats,
            userInteraction: baseLite.userInteraction,
            status: "approved",
            reportCount: 0,
            createdAt: createdAtString,
            lastRepliedAt: lastRepliedAtString
        )
    }
}



// MARK: - Post List Paginator Mock


public extension PostLite {
    
    /// 总共 35 个帖子的数据源
    static var mockPosts: [PostLite] {
        return (1...35).map { mockPostLite(index: $0) }
    }
    
    /**
     *  模拟 API 请求，根据页码返回帖子列表和分页信息。
     *  默认每页 10 个帖子。
     */
    static func getMockPostList(page: Int, pageSize: Int = 10) -> ListPostsData {
        let allPosts = PostLite.mockPosts
        let total = allPosts.count
        let totalPages = (total + pageSize - 1) / pageSize

        let safePage = max(1, min(page, totalPages)) // 确保页码在有效范围内

        let startIndex = (safePage - 1) * pageSize
        let endIndex = min(startIndex + pageSize, total)

        // 提取当前页的帖子数据
        let currentPosts: [PostLite]
        if startIndex < total {
            currentPosts = Array(allPosts[startIndex..<endIndex])
        } else {
            currentPosts = []
        }

        // 生成分页模型 (generator expects total first)
        let pagination = Pagination(
            total: Int64(total),
            page: Int32(safePage),
            pageSize: Int32(pageSize),
            pages: Int32(totalPages)
        )

        return ListPostsData(list: currentPosts, pagination: pagination)
    }
}



// MARK: - Comment Mock Data

/// 根据帖子 ID 生成一组包含层级关系的模拟评论数据
public func mockComments(for postID: String) -> [Comment] {
    let userA = UserLite.mockAuthor1
    let userB = UserLite.mockAuthor2

    // 基础时间点（最新评论）
    let now = Date()
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    func iso(_ date: Date) -> String { formatter.string(from: date) }

    // c1: 帖子 P-001 的一级评论
    let comment1 = Comment(
        id: "\(postID)-C01",
        postId: postID,
        author: userA,
        content: "这个帖子很有启发性！尤其是关于\(postID)的部分。",
        parentId: "",
        replyTo: nil,
        stats: nil,
        userInteraction: nil,
        createdAt: iso(Calendar.current.date(byAdding: .minute, value: -5, to: now) ?? now)
    )

    // c2: 帖子 P-001 的一级评论
    let comment2 = Comment(
        id: "\(postID)-C02",
        postId: postID,
        author: userB,
        content: "我试过楼主提到的方法，确实有效，赞一个！",
        parentId: "",
        replyTo: nil,
        stats: nil,
        userInteraction: nil,
        createdAt: iso(Calendar.current.date(byAdding: .minute, value: -8, to: now) ?? now)
    )

    // c3: 楼中楼回复 (回复 c1)
    let comment3 = Comment(
        id: "\(postID)-C03",
        postId: postID,
        author: userB,
        content: "同意楼上，\(userA.name) 的观点总是很独到。",
        parentId: comment1.id,
        replyTo: userA,
        stats: nil,
        userInteraction: nil,
        createdAt: iso(Calendar.current.date(byAdding: .minute, value: -2, to: now) ?? now)
    )

    // c4: 楼中楼回复 (回复 c3，即回复 userB)
    let comment4 = Comment(
        id: "\(postID)-C04",
        postId: postID,
        author: userA,
        content: "谢谢 \(userB.name)，我们互相学习！",
        parentId: comment1.id,
        replyTo: userB,
        stats: nil,
        userInteraction: nil,
        createdAt: iso(Calendar.current.date(byAdding: .minute, value: -1, to: now) ?? now)
    )

    // c5: 另一条一级评论
    let comment5 = Comment(
        id: "\(postID)-C05",
        postId: postID,
        author: userA,
        content: "有一个小问题，如果遇到边缘情况该如何处理？",
        parentId: "",
        replyTo: nil,
        stats: nil,
        userInteraction: nil,
        createdAt: iso(Calendar.current.date(byAdding: .minute, value: -10, to: now) ?? now)
    )

    // 按照时间降序排列 (最新的在最前)
    return [comment1, comment2, comment3, comment4, comment5].sorted { $0.createdAt > $1.createdAt }
}
