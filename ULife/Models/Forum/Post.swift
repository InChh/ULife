//
//  Post.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//

import Foundation

/// Post
// MARK: - Post
public struct Post: Equatable {
    public var author: UserLite
    /// 板块id
    public var boardid: String
    /// 板块名称
    public var boardName: String
    
    public var content: String
    /// 创建时间（iso08601)
    public var createdAt: String
    /// 唯一id
    public var id: String
    /// 最新回复时间（iso08601)，实现最新回复排序
    public var lastRepliedAt: String?
    /// 附件，无附件时，可省略或者传空数组
    public var media: [MediaItem]?
    /// 被举报次数，用户不可见，管理员可见，系统内部参数
    public var reportCount: Int
    /// 统计信息
    public var stats: Stats
    /// 状态，管理员/系统写
    public var status: Status
    public var tags: [String]
    public var title: String
    public var userInteraction: UserInteraction

    public init(author: UserLite, boardid: String, boardName: String, content: String, createdAt: String, id: String, lastRepliedAt: String, media: [MediaItem], reportCount: Int, stats: Stats, status: Status, tags: [String], title: String, userInteraction: UserInteraction) {
        self.author = author
        self.boardid = boardid
        self.boardName = boardName
        self.content = content
        self.createdAt = createdAt
        self.id = id
        self.lastRepliedAt = lastRepliedAt
        self.media = media
        self.reportCount = reportCount
        self.stats = stats
        self.status = status
        self.tags = tags
        self.title = title
        self.userInteraction = userInteraction
    }
}


/// PostLite
// MARK: - PostLite
public struct PostLite: Equatable {
    public var author: UserLite
    /// 所属板块ID
    public var boardid: String
    /// 所属板块名称
    public var boardName: String?
    /// 第一张图片URL（如果存在），用于列表预览
    public var coverImageurl: String?
    /// 发布时间
    public var createdAt: Date
    /// 帖子唯一ID
    public var id: String
    /// 统计数据
    public var stats: Stats
    /// 内容摘要（content字段的前N个字符）
    public var summary: String?
    /// 标签列表
    public var tags: [String]?
    /// 帖子标题
    public var title: String
    /// 当前用户互动状态
    public var userInteraction: UserInteraction

    public init(author: UserLite, boardid: String, boardName: String?, coverImageurl: String?, createdAt: Date, id: String, stats: Stats, summary: String?, tags: [String]?, title: String, userInteraction: UserInteraction) {
        self.author = author
        self.boardid = boardid
        self.boardName = boardName
        self.coverImageurl = coverImageurl
        self.createdAt = createdAt
        self.id = id
        self.stats = stats
        self.summary = summary
        self.tags = tags
        self.title = title
        self.userInteraction = userInteraction
    }
}

/// UserLite
// MARK: - UserLite
public struct UserLite: Equatable {
    /// 图像链接
    public var avatarurl: String
    /// 学院
    public var college: String
    public var id: String
    public var name: String
    public var studentid: String

    public init(avatarurl: String, college: String, id: String, name: String, studentid: String) {
        self.avatarurl = avatarurl
        self.college = college
        self.id = id
        self.name = name
        self.studentid = studentid
    }
}

/// MediaItem
// MARK: - MediaItem
public struct MediaItem: Equatable {
    public var meta: Meta
    public var thumbnailurl: String
    public var type: String
    public var url: String

    public init(meta: Meta, thumbnailurl: String, type: String, url: String) {
        self.meta = meta
        self.thumbnailurl = thumbnailurl
        self.type = type
        self.url = url
    }
}

// MARK: - Meta
public struct Meta: Equatable {
    public var filename: String
    /// 图片高度，如果图片提供
    public var height: String?
    public var size: String
    /// 图片宽度，如果图片提供
    public var width: String?

    public init(filename: String, height: String?, size: String, width: String?) {
        self.filename = filename
        self.height = height
        self.size = size
        self.width = width
    }
}

/// 统计信息
// MARK: - Stats
public struct Stats: Equatable {
    public var commentCount: Int
    public var likeCount: Int
    public var viewCount: Int

    public init(commentCount: Int, likeCount: Int, viewCount: Int) {
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.viewCount = viewCount
    }
}

/// 状态，管理员/系统写
public enum Status: String, Equatable {
    case approved
    case hidden
    case pending
    case rejected
}

// MARK: - UserInteraction
public struct UserInteraction: Equatable {
    public var isCollected: Bool
    public var isLiked: Bool

    public init(isCollected: Bool, isLiked: Bool) {
        self.isCollected = isCollected
        self.isLiked = isLiked
    }
}


