//
//  ForumRequest.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/9.
//
import Foundation
import UIKit

// MARK: - Request
public struct GetPostListRequest: Equatable {
    public var boardId: String?
    public var filter: Filter?
    public var keyword: String?
    public var page: Int
    public var pageSize: Int
    public var sort: Sort?

    public init(
        boardId: String?,
        filter: Filter?,
        keyword: String?,
        page: Int,
        pageSize: Int,
        sort: Sort?
    ) {
        self.boardId = boardId
        self.filter = filter
        self.keyword = keyword
        self.page = page
        self.pageSize = pageSize
        self.sort = sort
    }
}

// MARK: - Request
public struct CreatePostRequest: Equatable {
    /// 板块id
    public var boardid: String
    public var content: String
    /// 上传附件 可为空或缺省
    public var media: [MediaItem]?
    /// 帖子标签，例如 二手 数码
    public var tags: [String]
    public var title: String

    public init(
        boardid: String,
        content: String,
        media: [MediaItem]?,
        tags: [String],
        title: String
    ) {
        self.boardid = boardid
        self.content = content
        self.media = media
        self.tags = tags
        self.title = title
    }
}

public struct PostListResponse {
    public let posts: [PostLite]
    public let pagination: Pagination
}

public enum Filter: String, Equatable {
    case all
    case myCollege
}

public enum Sort: String, Equatable {
    case hot
    case latest
    case new
}

// MARK: - Request
public struct LikeOrDisListRequest: Equatable {
    public var id: String
    /// 操作：点赞/取消点赞
    public var actions: Actions

    public init(id: String, actions: Actions) {
        self.id = id
        self.actions = actions
    }
}

// MARK: - Request
public struct ColectOrDisColectRequest: Equatable {
    public var id: String
    /// 执行的操作
    public var action: Action

    public init(id: String, action: Action) {
        self.id = id
        self.action = action
    }
}

/// 执行的操作
public enum Action: String, Equatable {
    case collect
    case uncollect
}

/// 操作：点赞/取消点赞
public enum Actions: String, Equatable {
    case like
    case unlike
}

public struct LikeOrDisListResponse: Equatable {
    /// 帖子最新的总点赞数
    public var currentLikeCount: Int
    /// 当前用户是否已点赞
    public var isLiked: Bool

    public init(currentLikeCount: Int, isLiked: Bool) {
        self.currentLikeCount = currentLikeCount
        self.isLiked = isLiked
    }
}

// MARK: - DataClass
public struct ColectOrDisColectResponse: Equatable {

    public var currentCollectCount: Int
    /// 当前用户是否已收藏
    public var isCollected: Bool

    public init(currentCollectCount: Int, isCollected: Bool) {
        self.currentCollectCount = currentCollectCount
        self.isCollected = isCollected
    }
}

// MARK: - DataClass
struct CreateCommentResponse: Equatable {
    var comment: Comment
    /// 新创建评论id
    var commentid: String

    init(comment: Comment, commentid: String) {
        self.comment = comment
        self.commentid = commentid
    }
}

// MARK: - Request
public struct ReportRequest: Equatable {
    /// 详细描述，详细描述（可选）
    public var description: String?
    /// 举报类型，举报类型：枚举值，例如 ad (广告), politics (政治敏感), abuse (人身攻击), other (其他)
    public var reason: Reason
    /// 被举报的帖子或评论的唯一 ID
    public var targetid: String
    /// 举报目标类型：post 或 comment
    public var targetType: TargetType

    public init(
        description: String?,
        reason: Reason,
        targetid: String,
        targetType: TargetType
    ) {
        self.description = description
        self.reason = reason
        self.targetid = targetid
        self.targetType = targetType
    }
}

/// 举报类型，举报类型：枚举值，例如 ad (广告), politics (政治敏感), abuse (人身攻击), other (其他)
public enum Reason: String, Equatable {
    case abuse
    case ad
    case other
    case politics
}

/// 举报目标类型：post 或 comment
public enum TargetType: String, Equatable {
    case comment
    case post
}

class ForumRequest {

    //获取可用板块列表/api/v1/forum/boards
    public func getBoard() -> [Board] {
        return Board.mockBoards
    }

    //发布新帖子
    public func CreatePost(request: CreatePostRequest) -> Post {
        return Post.mockDetail(for: "1")
    }

    //获取帖子列表
    public func GetPostList(request: GetPostListRequest) -> PostListResponse {
        return PostLite.getMockPostList(page: request.page)
    }

    //获取帖子详情
    public func GetPostDetail(id: String) -> Post {
        return Post.mockDetail(for: id)
    }

    //帖子点赞/取消点赞
    public func LikeOrDisList(Requst: LikeOrDisListRequest)
        -> LikeOrDisListResponse
    {
        return LikeOrDisListResponse(
            currentLikeCount: 100,
            isLiked: Requst.actions == Actions.like
        )
    }

    //帖子收藏/取消收藏
    public func ColectOrDisColect(Requst: ColectOrDisColectRequest)
        -> ColectOrDisColectResponse
    {
        return ColectOrDisColectResponse(
            currentCollectCount: 100,
            isCollected: Requst.action == Action.collect
        )
    }

    //发表评论
    public func CreateComment(
        id: String, //帖子 id
        content: String,
        replyToCommentid: String? //回复的评论 id, 为 null 的话代表回复的帖子
    ) -> CreateCommentResponse {
        return CreateCommentResponse(
            comment: Comment(
                id: "xxx-C05",
                authorName: UserLite.mockAuthor1.name,
                authorAvatar: UserLite.mockAuthor1.avatarurl,
                content: content,
                createTime: Calendar.current.date(
                    byAdding: .minute,
                    value: -10,
                    to: Date()
                )!,
                likeCount: 1,
                replies: nil
            ),
            commentid: "xxx"
        )
    }

    //获取评论列表(不分页)
    public func GetCommentList(id: String) -> [Comment] {
        return mockComments(for: id)
    }

    //举报帖子/评论
    public func Report(request: ReportRequest) -> String {
        return "1"
    }

    //删除评论
    public func deleteComment(id: String) {

    }

    //评论点赞/取消点赞
    public func LikeOrDisListComment(Requst: LikeOrDisListRequest)
        -> LikeOrDisListResponse
    {
        return LikeOrDisListResponse(
            currentLikeCount: 100,
            isLiked: Requst.actions == Actions.like
        )
    }
}
