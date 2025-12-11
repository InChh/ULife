use axum::{
    extract::{Path, State},
    response::Json,
    routing::{delete, get, post},
    Router,
};
use serde::Serialize;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::user::entity::*;
use crate::modules::user::service::UserService;

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

/// 用户登录
async fn login(
    State(pool): State<MySqlPool>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<ApiResponse<LoginResponse>>, AppError> {
    let response = UserService::login(&pool, req).await?;
    Ok(ApiResponse::success(response))
}

/// 用户注册
async fn register(
    State(pool): State<MySqlPool>,
    Json(req): Json<RegisterRequest>,
) -> Result<Json<ApiResponse<RegisterResponse>>, AppError> {
    let response = UserService::register(&pool, req).await?;
    Ok(ApiResponse::success(response))
}

/// 获取当前用户信息
async fn get_current_user(
    State(pool): State<MySqlPool>,
    // TODO: 从认证中间件中提取 user_id
) -> Result<Json<ApiResponse<UserInfo>>, AppError> {
    // 临时使用硬编码的 user_id
    let user_id = "test_user_id";
    let user_info = UserService::get_user_info(&pool, user_id).await?;
    Ok(ApiResponse::success(user_info))
}

/// 更新用户资料
async fn update_profile(
    State(pool): State<MySqlPool>,
    Json(req): Json<UpdateProfileRequest>,
    // TODO: 从认证中间件中提取 user_id
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    let user_id = "test_user_id";
    UserService::update_profile(&pool, user_id, req).await?;
    Ok(ApiResponse::success(None))
}

/// 修改密码
async fn change_password(
    State(pool): State<MySqlPool>,
    Json(req): Json<ChangePasswordRequest>,
    // TODO: 从认证中间件中提取 user_id
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    let user_id = "test_user_id";
    UserService::change_password(&pool, user_id, req).await?;
    Ok(ApiResponse::success(None))
}

/// 退出登录
async fn logout() -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    // TODO: 实际应该让 Token 失效
    // 这里简单返回成功
    Ok(ApiResponse::success(None))
}

/// 删除用户（管理员）
async fn delete_user(
    State(pool): State<MySqlPool>,
    Path(user_id): Path<String>,
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    UserService::delete_user(&pool, &user_id).await?;
    Ok(ApiResponse::success(None))
}

/// 用户路由
pub fn user_routes() -> Router<MySqlPool> {
    Router::new()
        // 认证相关
        .route("/v1/auth/login", post(login))
        .route("/v1/auth/register", post(register))
        .route("/v1/auth/logout", post(logout))
        .route("/v1/auth/change-password", post(change_password))
        // 用户信息
        .route("/v1/users/me", get(get_current_user).put(update_profile))
        .route("/v1/users/:user_id", delete(delete_user))
}
