use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use chrono::NaiveDateTime;

/// 序列化 NaiveDateTime 为 ISO8601 格式
fn serialize_datetime<S>(dt: &NaiveDateTime, serializer: S) -> Result<S::Ok, S::Error>
where
    S: serde::Serializer,
{
    let s = format!("{}Z", dt.format("%Y-%m-%dT%H:%M:%S"));
    serializer.serialize_str(&s)
}

/// 学期
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Semester {
    pub id: i32,
    pub name: String,
    pub start_date: String,
    pub end_date: String,
    pub is_current: bool,
}

/// 公共课程（全校课程）
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct PublicCourse {
    pub id: i64,
    pub course_name: String,
    pub teacher_name: String,
    pub teacher_id: Option<i64>,
    pub location: String,
    pub day_of_week: i32,
    pub start_section: i32,
    pub end_section: i32,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub weeks_range: Option<String>, // JSON 字符串存储，如 "[1,2,3,4,5]"
    #[serde(rename = "type")]
    pub course_type: String,         // 'compulsory' or 'elective'
    pub credits: i32,
    pub description: Option<String>,
    pub semester_id: i32,
}

/// 用户课表项
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct ScheduleItem {
    pub id: i64,
    pub source_id: Option<i64>, // 对应公共课的 ID
    pub user_id: String,
    pub semester_id: i32,
    pub course_name: String,
    pub teacher_name: Option<String>,
    pub location: Option<String>,
    pub day_of_week: i32,
    pub start_section: i32,
    pub end_section: i32,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub weeks_range: Option<String>, // JSON 字符串
    #[serde(rename = "type")]
    pub course_type: Option<String>,
    pub credits: Option<i32>,
    pub description: Option<String>,
    pub color_hex: String,
    pub is_custom: bool,
    #[serde(serialize_with = "serialize_datetime")]
    pub created_at: NaiveDateTime,
}

/// 分页信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Pagination {
    pub total: i64,
    pub page: i32,
    pub page_size: i32,
    pub pages: i32,
}

/// 获取公共课程列表查询参数
#[derive(Debug, Deserialize)]
pub struct GetPublicCoursesQuery {
    pub semester_id: Option<i32>,
    pub name: Option<String>,
    pub teacher: Option<String>,
    pub page: i32,
    pub page_size: i32,
}

/// 获取用户课表查询参数
#[derive(Debug, Deserialize)]
pub struct GetScheduleQuery {
    pub semester_id: i32,
    pub week: Option<i32>,
}

/// 新增课表项请求（单个）
#[derive(Debug, Clone, Deserialize)]
pub struct AddScheduleItemRequest {
    pub source_id: Option<i64>,
    pub semester_id: i32,
    pub course_name: String,
    pub teacher_name: Option<String>,
    pub location: Option<String>,
    pub day_of_week: i32,
    pub start_section: i32,
    pub end_section: i32,
    pub weeks: Vec<i32>,
    #[serde(rename = "type")]
    pub course_type: Option<String>,
    pub credits: Option<i32>,
    pub description: Option<String>,
    pub color_hex: String,
    pub is_custom: bool,
}

/// 批量新增课表项请求
#[derive(Debug, Deserialize)]
pub struct AddScheduleItemsRequest {
    pub items: Vec<AddScheduleItemRequest>,
}

/// 批量新增响应
#[derive(Debug, Serialize)]
pub struct AddScheduleItemsResponse {
    pub successful_items: Vec<ScheduleItem>,
    pub failed_items: Vec<FailedItem>,
}

#[derive(Debug, Serialize)]
pub struct FailedItem {
    pub course_name: String,
    pub error_message: String,
}

/// 更新课表项请求
#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct UpdateScheduleItemRequest {
    pub source_id: Option<i64>,
    pub semester_id: Option<i32>,
    pub course_name: Option<String>,
    pub teacher_name: Option<String>,
    pub location: Option<String>,
    pub day_of_week: Option<i32>,
    pub start_section: Option<i32>,
    pub end_section: Option<i32>,
    pub weeks: Option<Vec<i32>>,
    #[serde(rename = "type")]
    pub course_type: Option<String>,
    pub credits: Option<i32>,
    pub description: Option<String>,
    pub color_hex: Option<String>,
    pub is_custom: Option<bool>,
}
