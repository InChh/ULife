//
//  ForumRequestProto.swift
//  ULife
//
//  论坛模块 Protobuf API 请求

import Foundation
import SwiftProtobuf

// MARK: - Forum Request Class (Protobuf)
class ForumRequestProto {
    private let protoManager = ProtoNetworkManager.shared
    
    // MARK: - Get Boards
    func getBoard() async throws -> [Board] {
        // Protobuf GET 请求不需要 body
        let response: Campus_Forum_GetBoardsResponse = try await protoManager.requestProto(
            endpoint: APIEndpoints.protobuf.forumBoards,
            method: .get,
            request: Campus_Forum_GetBoardsRequest()
        )
        
        // 转换为客户端模型
        return response.list.map { protoBoard in
            Board(
                description: protoBoard.description_p.isEmpty ? nil : protoBoard.description_p,
                icon: protoBoard.icon.isEmpty ? nil : protoBoard.icon,
                id: protoBoard.id.isEmpty ? nil : protoBoard.id,
                name: protoBoard.name.isEmpty ? nil : protoBoard.name,
                type: protoBoard.boardType == "static" ? .typeStatic : .typeDynamic
            )
        }
    }
    
    // MARK: - Get Post List
    func GetPostList(request: GetPostListRequest) async throws -> PostListResponseData {
        // 构建 protobuf 请求
        var protoRequest = Campus_Forum_GetPostsRequest()
        protoRequest.page = Int32(request.page)
        protoRequest.pageSize = Int32(request.pageSize)
        
        if let boardId = request.boardId {
            protoRequest.boardID = boardId
        }
        if let filter = request.filter {
            protoRequest.filter = filter.rawValue
        }
        if let sort = request.sort {
            protoRequest.sort = sort.rawValue
        }
        if let keyword = request.keyword {
            protoRequest.keyword = keyword
        }
        
        // 发送请求
        let response: Campus_Forum_GetPostsResponse = try await protoManager.requestProto(
            endpoint: APIEndpoints.protobuf.forumPosts,
            method: .post,
            request: protoRequest
        )
        
        // 转换为客户端模型
        let posts = response.list.map { protoPost -> PostLite in
            let author = UserLite(
                avatarurl: protoPost.author.avatarURL,
                college: protoPost.author.college,
                id: protoPost.author.id,
                name: protoPost.author.name,
                studentid: protoPost.author.studentID
            )
            
            let stats = Stats(
                commentCount: Int(protoPost.stats.commentCount),
                likeCount: Int(protoPost.stats.likeCount),
                viewCount: Int(protoPost.stats.viewCount)
            )
            
            let userInteraction = UserInteraction(
                isCollected: protoPost.userInteraction.isCollected,
                isLiked: protoPost.userInteraction.isLiked
            )
            
            return PostLite(
                author: author,
                boardid: protoPost.boardID,
                boardName: protoPost.boardName.isEmpty ? nil : protoPost.boardName,
                coverImageurl: protoPost.coverImageURL.isEmpty ? nil : protoPost.coverImageURL,
                createdAt: protoPost.createdAt,
                id: protoPost.id,
                stats: stats,
                summary: protoPost.summary.isEmpty ? nil : protoPost.summary,
                tags: protoPost.tags.isEmpty ? nil : protoPost.tags,
                title: protoPost.title,
                userInteraction: userInteraction
            )
        }
        
        let pagination = Pagination(
            page: Int(response.pagination.page),
            pages: Int(response.pagination.pages),
            pageSize: Int(response.pagination.pageSize),
            total: Int(response.pagination.total)
        )
        
        return PostListResponseData(list: posts, pagination: pagination)
    }
    
    // MARK: - Get Post Detail
    func GetPostDetail(id: String) async throws -> Post {
        // TODO: 实现获取帖子详情的 protobuf 接口
        // 暂时抛出错误
        throw NetworkError.serverError(501, "Protobuf GetPostDetail not implemented yet")
    }
    
    // 其他方法类似实现...
}

