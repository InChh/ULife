//
//  Comment.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let comment = try Comment(json)

import Foundation

/// Comment
// MARK: - Comment
public struct Comment2: Equatable {
    public var author: UserLite
    /// 评论内容
    public var content: String
    /// 评论时间
    public var createdAt: Date
    /// 评论唯一ID
    public var id: String
    public var isLiked: String
    public var likeCount: String
    /// 父评论ID。如果为null，则为一级评论（直接回复帖子）。
    public var parentid: String?
    /// 所属帖子ID
    public var postid: String
    /// 被回复的评论的作者信息（UserLite），用于楼中楼展示，如果是回复帖子则为null。
    public var replyTo: [UserLite]

    public init(author: UserLite, content: String, createdAt: Date, id: String, isLiked: String, likeCount: String, parentid: String?, postid: String, replyTo: [UserLite]) {
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.id = id
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.parentid = parentid
        self.postid = postid
        self.replyTo = replyTo
    }
}
