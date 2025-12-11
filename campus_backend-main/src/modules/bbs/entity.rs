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

/// 板块
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Board {
    pub id: String,
    pub name: String,
    pub icon: String,
    pub description: String,
    pub board_type: String, // 'static' or 'dynamic'
}

/// 帖子实体
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
#[allow(dead_code)]
pub struct Post {
    pub id: String,
    pub title: String,
    pub content: String,
    pub board_id: String,
    pub board_name: Option<String>,
    pub author_id: String,
    pub author_name: Option<String>,
    pub author_avatar: Option<String>,
    pub author_college: Option<String>,
    pub tags: Option<String>, // JSON 字符串存储
    pub cover_image_url: Option<String>,
    pub status: String, // 'approved', 'pending', 'rejected', 'hidden'
    pub view_count: i32,
    pub like_count: i32,
    pub comment_count: i32,
    pub report_count: i32,
    #[serde(serialize_with = "serialize_datetime")]
    pub created_at: NaiveDateTime,
    pub last_replied_at: Option<NaiveDateTime>,
}

/// 帖子详情（包含用户交互信息）
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PostDetail {
    pub id: String,
    pub title: String,
    pub content: String,
    pub board_id: String,
    pub board_name: String,
    pub author: UserLite,
    pub tags: Vec<String>,
    pub media: Vec<MediaItem>,
    pub stats: Stats,
    pub user_interaction: UserInteraction,
    pub status: String,
    pub report_count: i32,
    pub created_at: String,
    pub last_replied_at: Option<String>,
}

/// 帖子列表项
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PostListItem {
    pub id: String,
    pub title: String,
    pub author: UserLite,
    pub board_id: String,
    pub board_name: String,
    pub created_at: String,
    pub tags: Vec<String>,
    pub cover_image_url: Option<String>,
    pub summary: Option<String>,
    pub stats: Stats,
    pub user_interaction: UserInteraction,
}

/// 用户简要信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserLite {
    pub id: String,
    pub student_id: String,
    pub name: String,
    pub avatar_url: String,
    pub college: String,
}

/// 媒体项
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaItem {
    #[serde(rename = "type")]
    pub media_type: String,
    pub url: String,
    pub thumbnail_url: String,
    pub meta: MediaMeta,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaMeta {
    pub size: String,
    pub width: Option<String>,
    pub height: Option<String>,
    pub filename: String,
}

/// 统计信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Stats {
    pub view_count: i32,
    pub like_count: i32,
    pub comment_count: i32,
}

/// 用户交互信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserInteraction {
    pub is_liked: bool,
    pub is_collected: bool,
}

/// 评论
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Comment {
    pub id: String,
    pub post_id: String,
    pub author_id: String,
    pub content: String,
    pub parent_id: Option<String>,
    pub reply_to_user_id: Option<String>,
    pub like_count: i32,
    #[serde(serialize_with = "serialize_datetime")]
    pub created_at: NaiveDateTime,
}

/// 评论详情（包含用户信息）
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommentDetail {
    pub id: String,
    pub post_id: String,
    pub author: UserLite,
    pub content: String,
    pub parent_id: Option<String>,
    pub reply_to: Option<UserLite>,
    pub stats: CommentStats,
    pub user_interaction: CommentUserInteraction,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommentStats {
    pub like_count: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommentUserInteraction {
    pub is_liked: bool,
}

/// 分页信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Pagination {
    pub total: i64,
    pub page: i32,
    pub page_size: i32,
    pub pages: i32,
}

/// 创建帖子请求
#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct CreatePostRequest {
    pub board_id: String,
    pub title: String,
    pub content: String,
    pub tags: Vec<String>,
    pub media: Option<Vec<MediaItem>>,
}

/// 创建帖子响应
#[derive(Debug, Serialize)]
pub struct CreatePostResponse {
    pub post: PostDetail,
}

/// 获取帖子列表查询参数
#[derive(Debug, Deserialize)]
#[allow(dead_code)]
pub struct GetPostsQuery {
    pub page: i32,
    pub page_size: i32,
    pub board_id: Option<String>,
    pub filter: Option<String>, // 'all' or 'my_college'
    pub sort: Option<String>,   // 'latest', 'new', 'hot'
    pub keyword: Option<String>,
}

/// 点赞/取消点赞请求
#[derive(Debug, Deserialize)]
pub struct LikeRequest {
    pub action: String, // 'like' or 'unlike'
}

/// 点赞响应
#[derive(Debug, Serialize)]
pub struct LikeResponse {
    pub current_like_count: i32,
    pub is_liked: bool,
}

/// 收藏/取消收藏请求
#[derive(Debug, Deserialize)]
pub struct CollectRequest {
    pub action: String, // 'collect' or 'uncollect'
}

/// 收藏响应
#[derive(Debug, Serialize)]
pub struct CollectResponse {
    pub is_collected: bool,
}

/// 创建评论请求
#[derive(Debug, Deserialize)]
pub struct CreateCommentRequest {
    pub content: String,
    pub reply_to_comment_id: Option<String>,
}

/// 创建评论响应
#[derive(Debug, Serialize)]
pub struct CreateCommentResponse {
    pub comment_id: String,
    pub comment: CommentDetail,
}

/// 举报请求
#[derive(Debug, Deserialize)]
pub struct ReportRequest {
    pub target_type: String, // 'post' or 'comment'
    pub target_id: String,
    pub reason: String,      // 'ad', 'politics', 'abuse', 'other'
    pub description: Option<String>,
}

/// 举报响应
#[derive(Debug, Serialize)]
pub struct ReportResponse {
    pub report_id: String,
}
