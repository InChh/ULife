// Protobuf 版本的 Course Controller
use axum::{
    extract::State,
    response::{IntoResponse, Response},
    routing::{get, post},
    Router,
    http::{StatusCode, header},
    body::Bytes,
};
use prost::Message;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::course::service::CourseService;
use crate::modules::course::entity as course_entity;
use crate::proto::course::*;

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

/// 获取学期列表 (Protobuf)
async fn get_semesters_proto(
    State(pool): State<MySqlPool>,
) -> Result<Response, AppError> {
    let semesters = CourseService::get_semesters(&pool).await?;
    
    let proto_semesters: Vec<Semester> = semesters.into_iter().map(|s| Semester {
        id: s.id,
        name: s.name,
        start_date: s.start_date,
        end_date: s.end_date,
        is_current: s.is_current,
    }).collect();
    
    let response = GetSemestersResponse {
        semesters: proto_semesters,
    };
    
    Ok(protobuf_response(response))
}

/// 获取公共课程列表 (Protobuf)
async fn get_public_courses_proto(
    State(pool): State<MySqlPool>,
    body: Bytes,
) -> Result<Response, AppError> {
    let request = GetPublicCoursesRequest::decode(body)
        .map_err(|e| AppError::Validation(format!("Invalid protobuf: {}", e)))?;
    
    let query = course_entity::GetPublicCoursesQuery {
        semester_id: request.semester_id,
        name: request.name,
        teacher: request.teacher,
        page: request.page,
        page_size: request.page_size,
    };
    
    let (courses, pagination) = CourseService::get_public_courses(&pool, query).await?;
    
    // 转换为 protobuf
    let proto_courses: Vec<PublicCourse> = courses.into_iter().map(|c| {
        // 解析 weeks_range JSON 字符串
        let weeks: Vec<i32> = c.weeks_range
            .and_then(|w| serde_json::from_str(&w).ok())
            .unwrap_or_default();
        
        PublicCourse {
            id: c.id,
            course_name: c.course_name,
            teacher_name: c.teacher_name,
            teacher_id: c.teacher_id.unwrap_or(0),
            location: c.location,
            day_of_week: c.day_of_week,
            start_section: c.start_section,
            end_section: c.end_section,
            weeks_range: weeks,
            r#type: c.course_type,
            credits: c.credits,
            description: c.description.unwrap_or_default(),
            semester_id: c.semester_id,
        }
    }).collect();
    
    let proto_pagination = Pagination {
        total: pagination.total,
        page: pagination.page,
        page_size: pagination.page_size,
        pages: pagination.pages,
    };
    
    let response = GetPublicCoursesResponse {
        list: proto_courses,
        pagination: Some(proto_pagination),
    };
    
    Ok(protobuf_response(response))
}

/// 获取用户课表 (Protobuf)
async fn get_schedule_proto(
    State(pool): State<MySqlPool>,
    body: Bytes,
) -> Result<Response, AppError> {
    let request = GetScheduleRequest::decode(body)
        .map_err(|e| AppError::Validation(format!("Invalid protobuf: {}", e)))?;
    
    let query = course_entity::GetScheduleQuery {
        semester_id: request.semester_id,
        week: request.week,
    };
    
    // TODO: 从认证中间件提取 user_id
    let user_id = "test_user_id";
    
    let items = CourseService::get_user_schedule(&pool, user_id, query).await?;
    
    // 转换为 protobuf
    let proto_items: Vec<ScheduleItem> = items.into_iter().map(|item| {
        let weeks: Vec<i32> = item.weeks_range
            .and_then(|w| serde_json::from_str(&w).ok())
            .unwrap_or_default();
        
        ScheduleItem {
            id: item.id,
            source_id: item.source_id.unwrap_or(0),
            user_id: item.user_id,
            semester_id: item.semester_id,
            course_name: item.course_name,
            teacher_name: item.teacher_name.unwrap_or_default(),
            location: item.location.unwrap_or_default(),
            day_of_week: item.day_of_week,
            start_section: item.start_section,
            end_section: item.end_section,
            weeks_range: weeks,
            r#type: item.course_type.unwrap_or_default(),
            credits: item.credits.unwrap_or(0),
            description: item.description.unwrap_or_default(),
            color_hex: item.color_hex,
            is_custom: item.is_custom,
            created_at: item.created_at.format("%Y-%m-%dT%H:%M:%SZ").to_string(),
        }
    }).collect();
    
    let response = GetScheduleResponse {
        items: proto_items,
    };
    
    Ok(protobuf_response(response))
}

/// 课表 Protobuf 路由
pub fn course_proto_routes() -> Router<MySqlPool> {
    Router::new()
        .route("/v1/proto/semesters", get(get_semesters_proto))
        .route("/v1/proto/courses/public", post(get_public_courses_proto))
        .route("/v1/proto/schedule", post(get_schedule_proto))
}

