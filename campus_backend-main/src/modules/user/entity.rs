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

/// 用户实体
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct User {
    pub id: String,
    pub student_id: String,
    pub name: String,
    #[serde(skip_serializing)]
    pub password_hash: String,
    pub avatar_url: Option<String>,
    pub role: String,
    pub college: String,
    pub major: String,
    pub grade: Option<String>,
    pub class_name: Option<String>,
    pub bio: Option<String>,
    pub phone: Option<String>,
    pub email: Option<String>,
    pub wechat_id: Option<String>,
    #[serde(serialize_with = "serialize_datetime")]
    pub created_at: NaiveDateTime,
}

/// 用户简要信息（用于返回给客户端，不包含密码）
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserInfo {
    pub id: String,
    pub student_id: String,
    pub name: String,
    pub avatar_url: Option<String>,
    pub role: String,
    pub college: String,
    pub major: String,
    pub grade: Option<String>,
    pub class_name: Option<String>,
    pub bio: Option<String>,
    pub phone: Option<String>,
    pub email: Option<String>,
    pub wechat_id: Option<String>,
    pub weekly_course_count: i32,
    pub forum_activity_score: i32,
    pub collection_count: i32,
    pub setting_privacy_course: String,
    pub setting_notification_switch: bool,
}

/// 登录请求
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub student_id: String,
    pub password: String,
}

/// 登录响应
#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub token: String,
    pub user: UserInfo,
}

/// 注册请求
#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub student_id: String,
    pub password: String,
    pub name: String,
    pub college: String,
    pub major: String,
    pub phone: String,
}

/// 注册响应
#[derive(Debug, Serialize)]
pub struct RegisterResponse {
    pub user_id: String,
}

/// 更新用户资料请求
#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct UpdateProfileRequest {
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub bio: Option<String>,
    pub phone: Option<String>,
    pub email: Option<String>,
    pub wechat_id: Option<String>,
    pub setting_theme: Option<String>,
    pub setting_privacy_course: Option<String>,
    pub setting_notification_switch: Option<bool>,
}

/// 修改密码请求
#[derive(Debug, Deserialize)]
pub struct ChangePasswordRequest {
    pub old_password: String,
    pub new_password: String,
}

/// 批量导入用户项
#[derive(Debug, Serialize)]
#[allow(dead_code)]
pub struct ImportUserItem {
    pub row: i32,
    pub student_id: String,
    pub name: String,
    pub status: String,
    pub initial_password: Option<String>,
    pub error: Option<String>,
}

/// 批量导入响应
#[derive(Debug, Serialize)]
#[allow(dead_code)]
pub struct ImportUsersResponse {
    pub success_count: i32,
    pub failed_count: i32,
    pub total_count: i32,
    pub file_name: String,
    pub import_time: String,
    pub details: ImportDetails,
}

#[derive(Debug, Serialize)]
#[allow(dead_code)]
pub struct ImportDetails {
    pub success_list: Vec<ImportUserItem>,
    pub failed_list: Vec<ImportUserItem>,
}
