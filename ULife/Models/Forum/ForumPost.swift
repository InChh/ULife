//
//  ForumPost.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  论坛帖子类

import Foundation

struct ForumPost {
    let id: String
    let title: String        //标题
    let authorName: String
    let authorAvatar: String // 头像url
    let content: String      // 内容
    let tags: [String]       // 标签（#社团 #讲座）
    
    let commentCount: Int    //评论数
    let likeCount: Int       //点赞数
    //let isLiked: Bool      //是否点赞
    
    let createTime: Date
    let updateTime: Date
}
