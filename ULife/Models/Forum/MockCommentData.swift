//
//  MockCommentData.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/6.
//
import Foundation

struct MockCommentData{
    static var comments: [Comment2] = [
        Comment2(
            id: "c1",
            authorName: "评论者A",
            authorAvatar: "",
            content: "楼主写得太好了，内容很有启发性！我已经在别处分享了你的帖子。",
            createTime: Date(timeIntervalSinceNow: -60 * 20),
            likeCount: 5,
            replies: replies1  // 包含 4 条回复
        ),

        // 2. 没有回复的评论
        Comment2(
            id: "c2",
            authorName: "评论者B",
            authorAvatar: "",
            content: "我也有同样的问题，希望能找到解决方案。不过帖子本身描述得很清晰。",
            createTime: Date(timeIntervalSinceNow: -60 * 15),
            likeCount: 2,
            replies: []  // 明确没有回复
        ),

        // 3. 只有一条回复的评论
        Comment2(
            id: "c3",
            authorName: "好奇宝宝",
            authorAvatar: "",
            content: "请问一下，帖子中提到的那个工具叫什么名字？",
            createTime: Date(timeIntervalSinceNow: -60 * 10),
            likeCount: 8,
            replies: [
                CommentReply(
                    id: "r5",
                    authorName: "楼主本人",
                    repliedToUser: "好奇宝宝",
                    content: "那个工具是 SwiftLint，非常好用。",
                    createTime: Date(timeIntervalSinceNow: -60 * 6),
                    likeCount: 10
                )
            ]
        ),

        // 4. 较长的评论内容（测试高度自适应）
        Comment2(
            id: "c4",
            authorName: "资深用户",
            authorAvatar: "",
            content:
                "关于这个问题，我做了一些深入的研究，我认为除了楼主提到的几点之外，我们还需要考虑内存管理和线程安全的问题。特别是在高性能要求的场景下，细微的同步问题都可能导致程序崩溃，所以建议大家在实际应用中要非常小心谨慎。代码写得好只是第一步，稳定性和可维护性才是长久之计。",
            createTime: Date(timeIntervalSinceNow: -60 * 4),
            likeCount: 15,
            replies: nil  // nil 表示尚未加载回复或没有回复
        ),
        Comment2(
            id: "c1",
            authorName: "评论者A",
            authorAvatar: "",
            content: "楼主写得太好了，内容很有启发性！我已经在别处分享了你的帖子。",
            createTime: Date(timeIntervalSinceNow: -60 * 20),
            likeCount: 5,
            replies: replies1  // 包含 4 条回复
        ),
        Comment2(
            id: "c1",
            authorName: "评论者A",
            authorAvatar: "",
            content: "楼主写得太好了，内容很有启发性！我已经在别处分享了你的帖子。",
            createTime: Date(timeIntervalSinceNow: -60 * 20),
            likeCount: 5,
            replies: replies1  // 包含 4 条回复
        ),
        Comment2(
            id: "c1",
            authorName: "评论者A",
            authorAvatar: "",
            content: "楼主写得太好了，内容很有启发性！我已经在别处分享了你的帖子。",
            createTime: Date(timeIntervalSinceNow: -60 * 20),
            likeCount: 5,
            replies: replies1  // 包含 4 条回复
        ),
        Comment2(
            id: "c1",
            authorName: "评论者A",
            authorAvatar: "",
            content: "楼主写得太好了，内容很有启发性！我已经在别处分享了你的帖子。",
            createTime: Date(timeIntervalSinceNow: -60 * 20),
            likeCount: 5,
            replies: replies1  // 包含 4 条回复
        ),
    ]
}

let replies1: [CommentReply] = [
    CommentReply(
        id: "r1",
        authorName: "小助手",
        repliedToUser: nil,
        content: "感谢你的肯定！我们致力于提供高质量内容。",
        createTime: Date(timeIntervalSinceNow: -60 * 5),
        likeCount: 1
    ),
    CommentReply(
        id: "r2",
        authorName: "热心网友C",
        repliedToUser: "评论者A",
        content: "确实，楼主的观点非常独到，受益匪浅。",
        createTime: Date(timeIntervalSinceNow: -60 * 3),
        likeCount: 2
    ),
    CommentReply(
        id: "r3",
        authorName: "潜水艇",
        repliedToUser: nil,
        content: "偷偷点个赞！",
        createTime: Date(timeIntervalSinceNow: -60 * 2),
        likeCount: 0
    ),
    CommentReply(
        id: "r4",
        authorName: "路人甲",
        repliedToUser: nil,
        content: "这条回复不会被默认显示，除非点击'查看更多'。",
        createTime: Date(timeIntervalSinceNow: -60 * 1),
        likeCount: 0
    ),
]
