use axum::{
    extract::State,
    response::Json,
    routing::get,
    Router,
};
use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::ai::service::AIService;

/// 统一响应结构（与活动等模块保持一致）
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

#[derive(Serialize)]
struct DailyDigestDto {
    date: String,
    summary: String,
    created_at: String,
}

/// 获取最近一条“今日校园简报”
async fn get_daily_digest(
    State(pool): State<MySqlPool>,
) -> Result<Json<ApiResponse<Option<DailyDigestDto>>>, AppError> {
    // 复用 AIService 中的查询逻辑：在 system_digest 会话中取最新一条 assistant 消息
    if let Some((summary, created_at)) = AIService::latest_daily_digest(&pool).await? {
        let created_at_iso =
            DateTime::<Utc>::from_naive_utc_and_offset(created_at, Utc).to_rfc3339();
        // NaiveDateTime 使用 `date()` 获取日期部分
        let date = created_at.date().to_string();
        let dto = DailyDigestDto {
            date,
            summary,
            created_at: created_at_iso,
        };
        Ok(ApiResponse::success(Some(dto)))
    } else {
        // 没有简报时，返回 data: null，code 200
        Ok(ApiResponse::success(None))
    }
}

pub fn ai_routes() -> Router<MySqlPool> {
    Router::new().route("/v1/ai/daily_digest", get(get_daily_digest))
}

