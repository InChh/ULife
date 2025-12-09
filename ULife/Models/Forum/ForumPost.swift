//
//  ForumPost.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  论坛帖子类

import Foundation

struct ForumPost {
    var id: Int
    var title: String
    var content: String
    var category: String //板块
    var tags: [String]   //标签
    var imageUrls: [String]
    var authorId: Int
    var authorName: String
    var authorAvatar: String
    var authorRole: String
    var publishTime: Date
    var viewCount: Int  //观看人数
    var likeCount: Int  //点赞数
    var replyCount: Int //踩数
    var isLiked: Bool
    var isreplyed: Bool
    var isPinned: Bool  //是否置顶
}

struct CreatePostRequest {
    var title: String = ""
    var content: String = ""
    var category: String = ""
    var tags: [String] = []

    // 检查发帖数据是否有效（业务校验）
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

}
