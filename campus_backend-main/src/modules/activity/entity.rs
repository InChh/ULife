use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use chrono::NaiveDateTime;

/// 活动实体
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Activity {
    pub id: String,
    pub title: String,
    pub content: String,
    pub cover_url: Option<String>,
    pub activity_type: i8,
    pub location: String,
    pub organizer: String,
    #[serde(serialize_with = "serialize_datetime")]
    pub start_time: NaiveDateTime,
    #[serde(serialize_with = "serialize_datetime")]
    pub end_time: NaiveDateTime,
    pub quota: i32,
    pub current_enrollments: i32,
    pub need_sign_in: bool,
    pub status: i8,
    #[serde(serialize_with = "serialize_datetime")]
    pub created_at: NaiveDateTime,
}

// 序列化 NaiveDateTime 为 ISO8601 格式
fn serialize_datetime<S>(dt: &NaiveDateTime, serializer: S) -> Result<S::Ok, S::Error>
where
    S: serde::Serializer,
{
    let s = format!("{}Z", dt.format("%Y-%m-%dT%H:%M:%S"));
    serializer.serialize_str(&s)
}

/// 活动详情（包含用户交互信息）
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActivityDetail {
    #[serde(flatten)]
    pub activity: Activity,
    pub is_enrolled: bool,
    pub is_collected: bool,
}

/// 活动列表项（精简信息）
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct ActivityListItem {
    pub id: String,
    pub title: String,
    pub cover_url: Option<String>,
    pub location: String,
    #[serde(serialize_with = "serialize_datetime")]
    pub start_time: NaiveDateTime,
    pub quota: i32,
    pub current_enrollments: i32,
}

/// 分页信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Pagination {
    pub total: i64,
    pub page: i32,
    pub page_size: i32,
    pub pages: i32,
}

/// 创建活动请求
#[derive(Debug, Deserialize)]
pub struct CreateActivityRequest {
    pub title: String,
    pub content: String,
    pub location: String,
    pub organizer: String,
    pub start_time: String,
    pub end_time: String,
}

/// 更新活动请求
#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct PatchActivityRequest {
    pub title: Option<String>,
    pub content: Option<String>,
    pub cover_url: Option<String>,
    pub activity_type: Option<i8>,
    pub location: Option<String>,
    pub organizer: Option<String>,
    pub start_time: Option<String>,
    pub end_time: Option<String>,
    pub quota: Option<i32>,
    pub need_sign_in: Option<bool>,
    pub status: Option<i8>,
}

/// 报名活动请求
#[derive(Debug, Deserialize)]
pub struct EnrollActivityRequest {
    pub user_name: String,
    pub student_id: String,
    pub major: String,
    pub phone_number: Option<String>,
}

/// 报名记录
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct EnrollmentRecord {
    pub user_id: String,
    pub user_name: String,
    pub student_id: String,
    pub major: String,
    pub phone_number: Option<String>,
    pub activity_id: String,
    #[serde(serialize_with = "serialize_datetime")]
    pub enroll_time: NaiveDateTime,
    pub attendance_status: i8,
}

/// 我的报名活动
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct MyEnrollmentItem {
    pub activity_id: String,
    pub title: String,
    pub cover_url: Option<String>,
    #[serde(serialize_with = "serialize_datetime")]
    pub start_time: NaiveDateTime,
    #[serde(serialize_with = "serialize_datetime")]
    pub end_time: NaiveDateTime,
    pub my_status: i8,
}

/// 我的收藏活动
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct MyCollectionItem {
    pub activity_id: String,
    pub title: String,
    pub cover_url: Option<String>,
    #[serde(serialize_with = "serialize_datetime")]
    pub start_time: NaiveDateTime,
    #[serde(serialize_with = "serialize_datetime")]
    pub end_time: NaiveDateTime,
}

