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

// 标签数据源
let categorys = [
    "全部",
    // --- 核心分区 (高频内容) ---
    "🔥 广场热点",         // 热门内容集中地
    "📚 学术交流",         // 课程、考试、资料、专业讨论
    "💼 实习就业",         // 招聘信息、求职经验、内推
    "🎉 校园活动",         // 讲座、社团、比赛、大型集会
    "🏀 运动健身",         // 体育约伴、健身打卡、运动技巧
    
    // --- 生活服务 ---
    "🍚 吃喝玩乐",         // 美食探店、娱乐休闲、生活分享
    "🏡 房屋租住",         // 校内住宿、校外租房、室友招募
    "♻️ 二手闲置",         // 交易、转让、求购
    "💻 技术交流",         // 编程、设计、数码产品、技术求助
    
    // --- 社区与情感 ---
    "🤝 情感树洞",         // 个人情绪、恋爱交友、匿名倾诉
    "📢 新人报道",         // 新生提问、自我介绍、快速融入
    "💬 自由讨论",         // 任何非正式、杂项话题
    
    // --- 论坛管理 ---
    "✨ 站务公告",         // 官方通知、规则更新
    "🛠️ 意见反馈",         // App使用体验、Bug汇报
]

// 标签数据源
let CreateCategorys = [
    // --- 核心分区 (高频内容) ---
    "🔥 广场热点",         // 热门内容集中地
    "📚 学术交流",         // 课程、考试、资料、专业讨论
    "💼 实习就业",         // 招聘信息、求职经验、内推
    "🎉 校园活动",         // 讲座、社团、比赛、大型集会
    "🏀 运动健身",         // 体育约伴、健身打卡、运动技巧
    
    // --- 生活服务 ---
    "🍚 吃喝玩乐",         // 美食探店、娱乐休闲、生活分享
    "🏡 房屋租住",         // 校内住宿、校外租房、室友招募
    "♻️ 二手闲置",         // 交易、转让、求购
    "💻 技术交流",         // 编程、设计、数码产品、技术求助
    
    // --- 社区与情感 ---
    "🤝 情感树洞",         // 个人情绪、恋爱交友、匿名倾诉
    "📢 新人报道",         // 新生提问、自我介绍、快速融入
    "💬 自由讨论",         // 任何非正式、杂项话题
    
    // --- 论坛管理 ---
    "✨ 站务公告",         // 官方通知、规则更新
    "🛠️ 意见反馈",         // App使用体验、Bug汇报
]
