//
//  Comment.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//

import Foundation

/// Comment - 后端返回格式（CommentDetail）
// MARK: - Comment
public struct Comment: Codable, Equatable {
    public var author: UserLite
    /// 评论内容
    public var content: String
    /// 评论时间（改为String）
    public var createdAt: String
    /// 评论唯一ID
    public var id: String
    /// 父评论ID。如果为null，则为一级评论（直接回复帖子）。
    public var parentid: String?
    /// 所属帖子ID
    public var postid: String
    /// 被回复的评论的作者信息（UserLite），用于楼中楼展示，如果是回复帖子则为null。
    public var replyTo: UserLite?
    /// 统计信息（嵌套对象）
    public var stats: CommentStatsNested
    /// 用户交互（嵌套对象）
    public var user_interaction: CommentUserInteractionNested
    
    // 便捷访问属性
    public var isLiked: Bool {
        get { user_interaction.is_liked }
        set { user_interaction.is_liked = newValue }
    }
    
    public var likeCount: Int {
        get { stats.like_count }
        set { stats.like_count = newValue }
    }

    public init(author: UserLite, content: String, createdAt: String, id: String, parentid: String?, postid: String, replyTo: UserLite?, stats: CommentStatsNested, user_interaction: CommentUserInteractionNested) {
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.id = id
        self.parentid = parentid
        self.postid = postid
        self.replyTo = replyTo
        self.stats = stats
        self.user_interaction = user_interaction
    }
    
    enum CodingKeys: String, CodingKey {
        case author
        case content
        case createdAt = "created_at"
        case id
        case parentid = "parent_id"
        case postid = "post_id"
        case replyTo = "reply_to"
        case stats
        case user_interaction
    }
}

// 评论统计信息（嵌套）
public struct CommentStatsNested: Codable, Equatable {
    public var like_count: Int
    
    public init(like_count: Int) {
        self.like_count = like_count
    }
}

// 评论用户交互（嵌套）
public struct CommentUserInteractionNested: Codable, Equatable {
    public var is_liked: Bool
    
    public init(is_liked: Bool) {
        self.is_liked = is_liked
    }
}
