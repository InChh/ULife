use axum::{
    extract::{Path, Query, State},
    response::Json,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::activity::entity::*;
use crate::modules::activity::service::ActivityService;

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

/// 获取活动列表查询参数
#[derive(Debug, Deserialize)]
struct GetActivitiesQuery {
    keyword: Option<String>,
    activity_type: Option<i8>,
    #[serde(default = "default_page")]
    page: i32,
    #[serde(default = "default_page_size")]
    #[serde(rename = "pageSize")]
    page_size: i32,
}

fn default_page() -> i32 {
    1
}

fn default_page_size() -> i32 {
    10
}

/// 获取活动列表
async fn get_activities_list(
    State(pool): State<MySqlPool>,
    Query(params): Query<GetActivitiesQuery>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    let (list, pagination) = ActivityService::get_activities_list(
        &pool,
        params.keyword,
        params.activity_type,
        params.page,
        params.page_size,
    )
    .await?;

    Ok(ApiResponse::success(json!({
        "list": list,
        "pagination": pagination
    })))
}

/// 获取活动详情
async fn get_activity_detail(
    State(pool): State<MySqlPool>,
    Path(activity_id): Path<String>,
    // TODO: 从 Token 中提取 user_id
) -> Result<Json<ApiResponse<ActivityDetail>>, AppError> {
    // 临时使用硬编码的 user_id，实际应该从认证中间件中获取
    let user_id = Some("test_user_id");
    let detail = ActivityService::get_activity_detail(&pool, &activity_id, user_id).await?;
    Ok(ApiResponse::success(detail))
}

/// 创建活动（管理员）
async fn create_activity(
    State(pool): State<MySqlPool>,
    Json(req): Json<CreateActivityRequest>,
) -> Result<Json<ApiResponse<Vec<Activity>>>, AppError> {
    let activity = ActivityService::create_activity(&pool, req).await?;
    Ok(ApiResponse::success(vec![activity]))
}

/// 更新活动（管理员）
async fn update_activity(
    State(pool): State<MySqlPool>,
    Path(activity_id): Path<String>,
    Json(req): Json<PatchActivityRequest>,
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    ActivityService::update_activity(&pool, &activity_id, req).await?;
    Ok(ApiResponse::success(None))
}

/// 报名活动
async fn enroll_activity(
    State(pool): State<MySqlPool>,
    Path(activity_id): Path<String>,
    Json(req): Json<EnrollActivityRequest>,
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    // TODO: 从 Token 中提取 user_id
    let user_id = "test_user_id";
    ActivityService::enroll_activity(&pool, user_id, &activity_id, req).await?;
    Ok(ApiResponse::success(None))
}

/// 取消报名
async fn cancel_enrollment(
    State(pool): State<MySqlPool>,
    Path(activity_id): Path<String>,
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    // TODO: 从 Token 中提取 user_id
    let user_id = "test_user_id";
    ActivityService::cancel_enrollment(&pool, user_id, &activity_id).await?;
    Ok(ApiResponse::success(None))
}

/// 收藏活动
async fn collect_activity(
    State(pool): State<MySqlPool>,
    Path(activity_id): Path<String>,
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    // TODO: 从 Token 中提取 user_id
    let user_id = "test_user_id";
    ActivityService::collect_activity(&pool, user_id, &activity_id).await?;
    Ok(ApiResponse::success(None))
}

/// 取消收藏
async fn uncollect_activity(
    State(pool): State<MySqlPool>,
    Path(activity_id): Path<String>,
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    // TODO: 从 Token 中提取 user_id
    let user_id = "test_user_id";
    ActivityService::uncollect_activity(&pool, user_id, &activity_id).await?;
    Ok(ApiResponse::success(None))
}

/// 获取活动报名列表（管理员）
async fn get_enrollments(
    State(pool): State<MySqlPool>,
    Path(activity_id): Path<String>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    let (total, list) = ActivityService::get_enrollments(&pool, &activity_id).await?;
    Ok(ApiResponse::success(json!({
        "total_enrolled": total,
        "enrollment_list": list
    })))
}

/// 我的活动查询参数
#[derive(Debug, Deserialize)]
struct MyActivitiesQuery {
    #[serde(default)]
    include_enrollments: bool,
    #[serde(default)]
    include_collections: bool,
    #[serde(default = "default_page")]
    page: i32,
    #[serde(default = "default_page_size")]
    #[serde(rename = "pageSize")]
    page_size: i32,
}

/// 获取我的活动
async fn get_my_activities(
    State(pool): State<MySqlPool>,
    Query(params): Query<MyActivitiesQuery>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    // TODO: 从 Token 中提取 user_id
    let user_id = "test_user_id";
    
    let (enrolled_data, collected_data) = ActivityService::get_my_activities(
        &pool,
        user_id,
        params.include_enrollments,
        params.include_collections,
        params.page,
        params.page_size,
    )
    .await?;

    let mut response = json!({});
    
    if let Some((list, pagination)) = enrolled_data {
        response["enrolled_data"] = json!({
            "list": list,
            "pagination": pagination
        });
    }
    
    if let Some((list, pagination)) = collected_data {
        response["collected_data"] = json!({
            "list": list,
            "pagination": pagination
        });
    }

    Ok(ApiResponse::success(response))
}

/// 活动路由
pub fn activity_routes() -> Router<MySqlPool> {
    Router::new()
        // 活动列表和创建
        .route("/v1/activities", get(get_activities_list).post(create_activity))
        // 活动详情和更新
        .route("/v1/activities/:activity_id", get(get_activity_detail).patch(update_activity))
        // 报名
        .route("/v1/activities/:activity_id/enroll", post(enroll_activity).delete(cancel_enrollment))
        // 收藏
        .route("/v1/activities/:activity_id/collect", post(collect_activity).delete(uncollect_activity))
        // 报名列表（管理员）
        .route("/v1/activities/:activity_id/enrollments", get(get_enrollments))
        // 我的活动
        .route("/v1/my/activities", get(get_my_activities))
}

