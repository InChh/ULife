use axum::{
    extract::{Query, State},
    response::Json,
    routing::get,
    Router,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::course::entity::*;
use crate::modules::course::service::CourseService;

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

/// 获取学期列表
async fn get_semesters(
    State(pool): State<MySqlPool>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    let semesters = CourseService::get_semesters(&pool).await?;
    Ok(ApiResponse::success(json!({
        "semesters": semesters
    })))
}

/// 获取公共课程查询参数
#[derive(Debug, Deserialize)]
struct GetPublicCoursesParams {
    semester_id: Option<i32>,
    name: Option<String>,
    teacher: Option<String>,
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
    20
}

/// 获取公共课程列表
async fn get_public_courses(
    State(pool): State<MySqlPool>,
    Query(params): Query<GetPublicCoursesParams>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    let query = GetPublicCoursesQuery {
        semester_id: params.semester_id,
        name: params.name,
        teacher: params.teacher,
        page: params.page,
        page_size: params.page_size,
    };
    
    let (list, pagination) = CourseService::get_public_courses(&pool, query).await?;
    
    Ok(ApiResponse::success(json!({
        "list": list,
        "pagination": pagination
    })))
}

/// 获取用户课表查询参数
#[derive(Debug, Deserialize)]
struct GetScheduleParams {
    semester_id: i32,
    week: Option<i32>,
}

/// 获取用户课表
async fn get_user_schedule(
    State(pool): State<MySqlPool>,
    Query(params): Query<GetScheduleParams>,
) -> Result<Json<ApiResponse<serde_json::Value>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    
    let query = GetScheduleQuery {
        semester_id: params.semester_id,
        week: params.week,
    };
    
    let items = CourseService::get_user_schedule(&pool, user_id, query).await?;
    
    Ok(ApiResponse::success(json!({
        "items": items
    })))
}

/// 新增课表项
async fn add_schedule_items(
    State(pool): State<MySqlPool>,
    Json(req): Json<AddScheduleItemsRequest>,
) -> Result<Json<ApiResponse<AddScheduleItemsResponse>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    
    let response = CourseService::add_schedule_items(&pool, user_id, req).await?;
    Ok(ApiResponse::success(response))
}

/// 删除课表项查询参数
#[derive(Debug, Deserialize)]
struct DeleteScheduleQuery {
    item_id: i64,
}

/// 删除课表项
async fn delete_schedule_item(
    State(pool): State<MySqlPool>,
    Query(params): Query<DeleteScheduleQuery>,
) -> Result<Json<ApiResponse<Option<()>>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    
    CourseService::delete_schedule_item(&pool, user_id, params.item_id).await?;
    Ok(ApiResponse::success(None))
}

/// 更新课表项查询参数
#[derive(Debug, Deserialize)]
struct UpdateScheduleQuery {
    item_id: i64,
}

/// 更新课表项
async fn update_schedule_item(
    State(pool): State<MySqlPool>,
    Query(params): Query<UpdateScheduleQuery>,
    Json(req): Json<UpdateScheduleItemRequest>,
) -> Result<Json<ApiResponse<ScheduleItem>>, AppError> {
    // TODO: 从认证中间件中提取 user_id
    let user_id = "test_user_id";
    
    let item = CourseService::update_schedule_item(&pool, user_id, params.item_id, req).await?;
    Ok(ApiResponse::success(item))
}

/// 课表路由
pub fn course_routes() -> Router<MySqlPool> {
    Router::new()
        // 学期
        .route("/v1/semesters", get(get_semesters))
        // 公共课程
        .route("/v1/courses/public", get(get_public_courses))
        // 用户课表
        .route("/v1/schedule", 
            get(get_user_schedule)
            .post(add_schedule_items)
            .delete(delete_schedule_item)
            .patch(update_schedule_item)
        )
}
