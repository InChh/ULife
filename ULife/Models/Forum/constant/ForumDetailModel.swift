//
//  ForumDetailModel.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//


var comments: [Comment2] = []  // 评论数据源


// 已点赞的评论、回复 ID 集合（仅前端状态）
var likedCommentIDs: Set<String> = []
var likedReplyIDs: Set<String> = []
var isPostLiked: Bool  = false//是否点赞
var iscollected: Bool  = false//是否收藏
