// Protobuf 版本的 Forum Controller
use axum::{
    extract::{Path, State},
    response::{IntoResponse, Response},
    routing::{get, post},
    Router,
    http::{StatusCode, header},
    body::Bytes,
};
use prost::Message;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::bbs::service::BbsService;
use crate::modules::bbs::entity as bbs_entity;
use crate::proto::forum::*;

/// Protobuf 响应包装
fn protobuf_response<M: Message>(message: M) -> Response {
    let mut buf = Vec::new();
    message.encode(&mut buf).unwrap();
    
    (
        StatusCode::OK,
        [(header::CONTENT_TYPE, "application/x-protobuf; charset=utf-8")],
        buf
    ).into_response()
}

/// 获取板块列表 (Protobuf)
async fn get_boards_proto(
    State(pool): State<MySqlPool>,
) -> Result<Response, AppError> {
    let boards = BbsService::get_boards(&pool).await?;
    
    let proto_boards: Vec<Board> = boards.into_iter().map(|b| Board {
        id: b.id,
        name: b.name,
        icon: b.icon,
        description: b.description,
        board_type: b.board_type,
    }).collect();
    
    let response = GetBoardsResponse {
        list: proto_boards,
    };
    
    Ok(protobuf_response(response))
}

/// 获取帖子列表 (Protobuf)
async fn get_posts_proto(
    State(pool): State<MySqlPool>,
    body: Bytes,
) -> Result<Response, AppError> {
    let request = GetPostsRequest::decode(body)
        .map_err(|e| AppError::Validation(format!("Invalid protobuf: {}", e)))?;
    
    let query = bbs_entity::GetPostsQuery {
        page: request.page,
        page_size: request.page_size,
        board_id: request.board_id,
        filter: request.filter,
        sort: request.sort,
        keyword: request.keyword,
    };
    
    let (list, pagination) = BbsService::get_posts(&pool, query, Some("test_user_id")).await?;
    
    // 转换为 protobuf
    let proto_posts: Vec<PostListItem> = list.into_iter().map(|p| PostListItem {
        id: p.id,
        title: p.title,
        author: Some(UserLite {
            id: p.author.id,
            student_id: p.author.student_id,
            name: p.author.name,
            avatar_url: p.author.avatar_url,
            college: p.author.college,
        }),
        board_id: p.board_id,
        board_name: p.board_name,
        created_at: p.created_at,
        tags: p.tags,
        cover_image_url: p.cover_image_url.unwrap_or_default(),
        summary: p.summary.unwrap_or_default(),
        stats: Some(Stats {
            view_count: p.stats.view_count,
            like_count: p.stats.like_count,
            comment_count: p.stats.comment_count,
        }),
        user_interaction: Some(UserInteraction {
            is_liked: p.user_interaction.is_liked,
            is_collected: p.user_interaction.is_collected,
        }),
    }).collect();
    
    let proto_pagination = Pagination {
        total: pagination.total,
        page: pagination.page,
        page_size: pagination.page_size,
        pages: pagination.pages,
    };
    
    let response = GetPostsResponse {
        list: proto_posts,
        pagination: Some(proto_pagination),
    };
    
    Ok(protobuf_response(response))
}

/// 论坛 Protobuf 路由
pub fn bbs_proto_routes() -> Router<MySqlPool> {
    Router::new()
        .route("/v1/proto/forum/boards", get(get_boards_proto))
        .route("/v1/proto/forum/posts", post(get_posts_proto))
}

