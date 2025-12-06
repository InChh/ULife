//
//  Comment.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/3.
//
import Foundation

struct Comment {
    let id: String
    let authorName: String
    let authorAvatar: String
    let content: String
    let createTime: Date
    let likeCount: Int
    
    let replies: [CommentReply]?
}

struct CommentReply {
    let id: String
    let authorName: String
    let repliedToUser: String?  // 回复给谁 (例如：回复 @张三)
    let content: String
    let createTime: Date
}
