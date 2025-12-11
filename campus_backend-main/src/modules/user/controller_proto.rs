// Protobuf 版本的 User Controller
use axum::{
    extract::State,
    response::{IntoResponse, Response},
    routing::post,
    Router,
    http::{StatusCode, header},
    body::Bytes,
};
use prost::Message;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::user::service::UserService;
use crate::modules::user::entity as user_entity;
use crate::proto::user::*;

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

/// 登录 (Protobuf 版本)
async fn login_proto(
    State(pool): State<MySqlPool>,
    body: Bytes,
) -> Result<Response, AppError> {
    // 解析 protobuf 请求
    let request = LoginRequest::decode(body)
        .map_err(|e| AppError::Validation(format!("Invalid protobuf: {}", e)))?;
    
    // 调用 service
    let login_req = user_entity::LoginRequest {
        student_id: request.student_id,
        password: request.password,
    };
    
    let response = UserService::login(&pool, login_req).await?;
    
    // 转换为 protobuf 响应
    let proto_user = UserInfo {
        id: response.user.id,
        student_id: response.user.student_id,
        name: response.user.name,
        avatar_url: response.user.avatar_url.unwrap_or_default(),
        role: response.user.role,
        college: response.user.college,
        major: response.user.major,
        grade: response.user.grade.unwrap_or_default(),
        class_name: response.user.class_name.unwrap_or_default(),
        bio: response.user.bio.unwrap_or_default(),
        phone: response.user.phone.unwrap_or_default(),
        email: response.user.email.unwrap_or_default(),
        wechat_id: response.user.wechat_id.unwrap_or_default(),
        weekly_course_count: response.user.weekly_course_count,
        forum_activity_score: response.user.forum_activity_score,
        collection_count: response.user.collection_count,
        setting_privacy_course: response.user.setting_privacy_course,
        setting_notification_switch: response.user.setting_notification_switch,
    };
    
    let proto_response = LoginResponse {
        token: response.token,
        user: Some(proto_user),
    };
    
    Ok(protobuf_response(proto_response))
}

/// 注册 (Protobuf 版本)
async fn register_proto(
    State(pool): State<MySqlPool>,
    body: Bytes,
) -> Result<Response, AppError> {
    let request = RegisterRequest::decode(body)
        .map_err(|e| AppError::Validation(format!("Invalid protobuf: {}", e)))?;
    
    let register_req = user_entity::RegisterRequest {
        student_id: request.student_id,
        password: request.password,
        name: request.name,
        college: request.college,
        major: request.major,
        phone: request.phone,
    };
    
    let response = UserService::register(&pool, register_req).await?;
    
    let proto_response = RegisterResponse {
        user_id: response.user_id,
    };
    
    Ok(protobuf_response(proto_response))
}

/// 用户 Protobuf 路由
pub fn user_proto_routes() -> Router<MySqlPool> {
    Router::new()
        .route("/v1/proto/auth/login", post(login_proto))
        .route("/v1/proto/auth/register", post(register_proto))
}

