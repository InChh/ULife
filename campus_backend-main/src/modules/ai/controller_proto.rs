use axum::{
    extract::{Path, State},
    http::{header, StatusCode},
    response::{IntoResponse, Response},
    routing::{get, post},
    body::Bytes,
    Router,
};
use prost::Message;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::ai::service::AIService;
use crate::proto::ai::{ChatHistoryRequest, ChatRequest};

fn protobuf_response<M: Message>(message: M) -> Response {
    let mut buf = Vec::new();
    message.encode(&mut buf).unwrap();

    (
        StatusCode::OK,
        [(header::CONTENT_TYPE, "application/x-protobuf; charset=utf-8")],
        buf,
    )
        .into_response()
}

async fn chat_proto(
    State(pool): State<MySqlPool>,
    body: Bytes,
) -> Result<Response, AppError> {
    let request = ChatRequest::decode(body)
        .map_err(|e| AppError::Validation(format!("Invalid protobuf: {}", e)))?;

    // TODO: 从认证中获取真实用户ID
    let user_id = "test_user_id";
    let response = AIService::chat(&pool, user_id, &request).await?;
    Ok(protobuf_response(response))
}

async fn history_proto(
    State(pool): State<MySqlPool>,
    Path(conversation_id): Path<i64>,
) -> Result<Response, AppError> {
    let req = ChatHistoryRequest {
        conversation_id,
    };
    let user_id = "test_user_id";
    let response = AIService::history(&pool, user_id, req.conversation_id).await?;
    Ok(protobuf_response(response))
}

pub fn ai_proto_routes() -> Router<MySqlPool> {
    Router::new()
        .route("/v1/proto/ai/chat", post(chat_proto))
        .route("/v1/proto/ai/history/:conversation_id", get(history_proto))
}
