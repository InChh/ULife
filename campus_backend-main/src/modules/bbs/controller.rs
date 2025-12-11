use axum::{
    extract::{Path, Query, State},
    response::Json,
    routing::{delete, get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::bbs::entity::*;
use crate::modules::bbs::service::BbsService;

/// 统一响应结构
#[derive(Serialize)]
struct ApiResponse<T> {
    code: i32,
    message: String,
    data: T,
}

impl<T: Serialize> ApiResponse<T> {
    fn success(data: T) -> Json<Self> {
        Json(ApiResponse {
            code: 200,
            message: "success".to_string(),
            data,
        })
    }
}

/// 获取板块列表
async fn get_boards(
    State(pool): State<MySqlPool>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    let boards = BbsService::get_boards(&pool).await?;
    Ok(ApiResponse::success(json!({
        "list": boards
    })))
}

/// 创建帖子
async fn create_post(
    State(pool): State<MySqlPool>,
    Json(req): Json<CreatePostRequest>,
    // TODO: 从认证中间件中提取 user_id
) -> Result<Json<ApiResponse<CreatePostResponse>>, AppError> {
    let user_id = "test_user_id";
    let post = BbsService::create_post(&pool, user_id, req).await?;
    Ok(ApiResponse::success(CreatePostResponse { post }))
}

/// 获取帖子列表查询参数
#[derive(Debug, Deserialize)]
struct GetPostsQueryParams {
    #[serde(default = "default_page")]
    page: i32,
    #[serde(default = "default_page_size")]
    #[serde(rename = "pageSize")]
    page_size: i32,
    #[serde(rename = "boardId")]
    board_id: Option<String>,
    filter: Option<String>,
    sort: Option<String>,
    keyword: Option<String>,
}

fn default_page() -> i32 {
    1
}

fn default_page_size() -> i32 {
    20
}

/// 获取帖子列表
async fn get_posts(
    State(pool): State<MySqlPool>,
    Query(params): Query<GetPostsQueryParams>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    let query = GetPostsQuery {
        page: params.page,
        page_size: params.page_size,
        board_id: params.board_id,
        filter: params.filter,
        sort: params.sort,
        keyword: params.keyword,
    };
    
    // TODO: 从认证中间件中提取 user_id
    let user_id = Some("test_user_id");
    
    let (list, pagination) = BbsService::get_posts(&pool, query, user_id).await?;
    
    Ok(ApiResponse::success(json!({
        "list": list,
        "pagination": pagination
    })))
}

/// 获取帖子详情
async fn get_post_detail(
    State(pool): State<MySqlPool>,
    Path(post_id): Path<String>,
) -> Result<Json<ApiResponse<PostDetail>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = Some("test_user_id");
    let post = BbsService::get_post_detail(&pool, &post_id, user_id).await?;
    Ok(ApiResponse::success(post))
}

/// 删除帖子
async fn delete_post(
    State(pool): State<MySqlPool>,
    Path(post_id): Path<String>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    BbsService::delete_post(&pool, &post_id, user_id).await?;
    Ok(ApiResponse::success(json!({})))
}

/// 点赞/取消点赞帖子
async fn like_post(
    State(pool): State<MySqlPool>,
    Path(post_id): Path<String>,
    Json(req): Json<LikeRequest>,
) -> Result<Json<ApiResponse<LikeResponse>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    let response = BbsService::like_post(&pool, &post_id, user_id, &req.action).await?;
    Ok(ApiResponse::success(response))
}

/// 收藏/取消收藏帖子
async fn collect_post(
    State(pool): State<MySqlPool>,
    Path(post_id): Path<String>,
    Json(req): Json<CollectRequest>,
) -> Result<Json<ApiResponse<CollectResponse>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    let response = BbsService::collect_post(&pool, &post_id, user_id, &req.action).await?;
    Ok(ApiResponse::success(response))
}

/// 创建评论
async fn create_comment(
    State(pool): State<MySqlPool>,
    Path(post_id): Path<String>,
    Json(req): Json<CreateCommentRequest>,
) -> Result<Json<ApiResponse<CreateCommentResponse>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    let response = BbsService::create_comment(&pool, &post_id, user_id, req).await?;
    Ok(ApiResponse::success(response))
}

/// 获取评论列表查询参数
#[derive(Debug, Deserialize)]
struct GetCommentsQuery {
    #[serde(default = "default_page")]
    page: i32,
    #[serde(default = "default_page_size")]
    #[serde(rename = "pageSize")]
    page_size: i32,
}

/// 获取评论列表
async fn get_comments(
    State(pool): State<MySqlPool>,
    Path(post_id): Path<String>,
    Query(params): Query<GetCommentsQuery>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = Some("test_user_id");
    
    let (list, pagination) = BbsService::get_comments(&pool, &post_id, params.page, params.page_size, user_id).await?;
    
    Ok(ApiResponse::success(json!({
        "list": list,
        "pagination": pagination
    })))
}

/// 删除评论
async fn delete_comment(
    State(pool): State<MySqlPool>,
    Path(comment_id): Path<String>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    BbsService::delete_comment(&pool, &comment_id, user_id).await?;
    Ok(ApiResponse::success(json!({})))
}

/// 点赞/取消点赞评论
async fn like_comment(
    State(pool): State<MySqlPool>,
    Path(comment_id): Path<String>,
    Json(req): Json<LikeRequest>,
) -> Result<Json<ApiResponse<LikeResponse>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    let response = BbsService::like_comment(&pool, &comment_id, user_id, &req.action).await?;
    Ok(ApiResponse::success(response))
}

/// 举报
async fn report(
    State(pool): State<MySqlPool>,
    Json(req): Json<ReportRequest>,
) -> Result<Json<ApiResponse<ReportResponse>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    let response = BbsService::report(&pool, user_id, req).await?;
    Ok(ApiResponse::success(response))
}

/// 论坛路由
pub fn bbs_routes() -> Router<MySqlPool> {
    Router::new()
        // 板块
        .route("/v1/forum/boards", get(get_boards))
        // 帖子
        .route("/v1/forum/posts", post(create_post).get(get_posts))
        .route("/v1/forum/posts/:post_id", get(get_post_detail).delete(delete_post))
        .route("/v1/forum/posts/:post_id/like", post(like_post))
        .route("/v1/forum/posts/:post_id/collect", post(collect_post))
        // 评论
        .route("/v1/forum/posts/:post_id/comments", post(create_comment).get(get_comments))
        .route("/v1/forum/comments/:comment_id", delete(delete_comment))
        .route("/v1/forum/comments/:comment_id/like", post(like_comment))
        // 举报
        .route("/v1/forum/reports", post(report))
}
