//
//  Comment.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//
import Foundation

struct Comment2 {
    var id: String
    var authorName: String
    var authorAvatar: String
    var content: String
    var createTime: Date
    /// 顶层评论点赞数
    var likeCount: Int
    /// 该评论下的回复列表
    var replies: [CommentReply]?
}

struct CommentReply : Equatable{
    var id: String
    var authorName: String
    /// 回复给谁 (例如：回复 @张三)
    var repliedToUser: String?
    var content: String
    var createTime: Date
    /// 回复点赞数
    var likeCount: Int
}
