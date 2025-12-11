//
//  ForumRequest.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/9.
//
import Foundation
import UIKit

// MARK: - Request Models
public struct GetPostListRequest: Codable {
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

public struct CreatePostRequest: Codable {
    public var board_id: String
    public var content: String
    public var media: [MediaItem]?
    public var tags: [String]
    public var title: String

    public init(
        boardId: String,
        content: String,
        media: [MediaItem]?,
        tags: [String],
        title: String
    ) {
        self.board_id = boardId
        self.content = content
        self.media = media
        self.tags = tags
        self.title = title
    }
}

// MARK: - Response Models
public struct BoardsResponse: Codable {
    public let list: [Board]
}

public struct PostListResponseData: Codable {
    public let list: [PostLite]
    public let pagination: Pagination
    
    public init(list: [PostLite], pagination: Pagination) {
        self.list = list
        self.pagination = pagination
    }
}

// 类型别名，保持与旧代码兼容
public typealias PostListResponse = PostListResponseData

public struct PostDetailResponse: Codable {
    public let post: Post
}

public struct LikeOrDisListRequest: Codable {
    public var action: Actions

    public init(action: Actions) {
        self.action = action
    }
}

public struct ColectOrDisColectRequest: Codable {
    public var action: Action

    public init(action: Action) {
        self.action = action
    }
}

public enum Action: String, Codable {
    case collect
    case uncollect
}

public enum Actions: String, Codable {
    case like
    case unlike
}

public struct LikeOrDisListResponse: Codable {
    public var current_like_count: Int
    public var is_liked: Bool

    var currentLikeCount: Int { current_like_count }
    var isLiked: Bool { is_liked }
}

public struct ColectOrDisColectResponse: Codable {
    public var is_collected: Bool
    
    var isCollected: Bool { is_collected }
}

public struct CreateCommentRequest: Codable {
    public var content: String
    public var reply_to_comment_id: String?
    
    public init(content: String, replyToCommentId: String?) {
        self.content = content
        self.reply_to_comment_id = replyToCommentId
    }
}

public struct CreateCommentResponseData: Codable {
    public var comment_id: String
    public var comment: Comment
    
    var commentId: String { comment_id }
}

public struct CommentsListResponse: Codable {
    public let list: [Comment]
    public let pagination: Pagination
    
    public init(list: [Comment], pagination: Pagination) {
        self.list = list
        self.pagination = pagination
    }
}

public struct ReportRequest: Codable {
    public var description: String?
    public var reason: Reason
    public var target_id: String
    public var target_type: TargetType

    public init(
        description: String?,
        reason: Reason,
        targetId: String,
        targetType: TargetType
    ) {
        self.description = description
        self.reason = reason
        self.target_id = targetId
        self.target_type = targetType
    }
}

public struct ReportResponse: Codable {
    public var report_id: String
}

public enum Reason: String, Codable {
    case abuse
    case ad
    case other
    case politics
}

public enum TargetType: String, Codable {
    case comment
    case post
}

public enum Filter: String, Codable {
    case all
    case myCollege = "my_college"
}

public enum Sort: String, Codable {
    case hot
    case latest
    case new
}

// MARK: - Forum Request Class
class ForumRequest {
    private let networkManager = NetworkManager.shared
    private struct CreatePostResponseDTO: Codable { let post: Post }
    
    // MARK: - Get Boards
    public func getBoard() async throws -> [Board] {
        let response: BoardsResponse = try await networkManager.request(
            endpoint: APIEndpoints.forumBoards,
            method: .get
        )
        return response.list
    }

    // MARK: - Create Post
    public func CreatePost(request: CreatePostRequest) async throws -> Post {
        let response: CreatePostResponseDTO = try await networkManager.request(
            endpoint: APIEndpoints.forumPosts,
            method: .post,
            body: request
        )
        return response.post
    }

    // MARK: - Get Post List
    public func GetPostList(request: GetPostListRequest) async throws -> PostListResponseData {
        var params: [String: Any] = [
            "page": request.page,
            "pageSize": request.pageSize
        ]
        
        if let boardId = request.boardId {
            params["boardId"] = boardId
        }
        if let filter = request.filter {
            params["filter"] = filter.rawValue
        }
        if let sort = request.sort {
            params["sort"] = sort.rawValue
        }
        if let keyword = request.keyword {
            params["keyword"] = keyword
        }
        
        let response: PostListResponseData = try await networkManager.request(
            endpoint: APIEndpoints.forumPosts,
            method: .get,
            parameters: params
        )
        return response
    }

    // MARK: - Get Post Detail
    public func GetPostDetail(id: String) async throws -> Post {
        let response: Post = try await networkManager.request(
            endpoint: APIEndpoints.forumPostDetail(id),
            method: .get
        )
        return response
    }

    // MARK: - Like/Unlike Post
    public func LikeOrDisList(Request: LikeOrDisListRequest, postId: String) async throws -> LikeOrDisListResponse {
        let response: LikeOrDisListResponse = try await networkManager.request(
            endpoint: APIEndpoints.forumPostLike(postId),
            method: .post,
            body: Request
        )
        return response
    }

    // MARK: - Collect/Uncollect Post
    public func ColectOrDisColect(Request: ColectOrDisColectRequest, postId: String) async throws -> ColectOrDisColectResponse {
        let response: ColectOrDisColectResponse = try await networkManager.request(
            endpoint: APIEndpoints.forumPostCollect(postId),
            method: .post,
            body: Request
        )
        return response
    }

    // MARK: - Create Comment
    public func CreateComment(postId: String, request: CreateCommentRequest) async throws -> CreateCommentResponseData {
        let response: CreateCommentResponseData = try await networkManager.request(
            endpoint: APIEndpoints.forumPostComments(postId),
            method: .post,
            body: request
        )
        return response
    }
    
    // MARK: - Get Comment List
    public func GetCommentList(postId: String, page: Int = 1, pageSize: Int = 100) async throws -> [Comment] {
        let params: [String: Any] = [
            "page": page,
            "pageSize": pageSize
        ]
        
        let response: CommentsListResponse = try await networkManager.request(
            endpoint: APIEndpoints.forumPostComments(postId),
            method: .get,
            parameters: params
        )
        return response.list
    }

    // MARK: - Report Post/Comment
    public func Report(request: ReportRequest) async throws -> String {
        let response: ReportResponse = try await networkManager.request(
            endpoint: APIEndpoints.forumReports,
            method: .post,
            body: request
        )
        return response.report_id
    }

    // MARK: - Delete Comment
    public func deleteComment(id: String) async throws {
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.forumCommentDetail(id),
            method: .delete
        )
    }

    // MARK: - Like/Unlike Comment
    public func LikeOrDisListComment(Request: LikeOrDisListRequest, commentId: String) async throws -> LikeOrDisListResponse {
        let response: LikeOrDisListResponse = try await networkManager.request(
            endpoint: APIEndpoints.forumCommentLike(commentId),
            method: .post,
            body: Request
        )
        return response
    }
    
    // MARK: - Delete Post
    public func deletePost(id: String) async throws {
        try await networkManager.requestWithoutData(
            endpoint: APIEndpoints.forumPostDetail(id),
            method: .delete
        )
    }
}

