use chrono::{DateTime, Utc};

#[derive(Debug, Clone, uniffi::Record, serde::Serialize, serde::Deserialize)]
pub struct Comment {
    pub id: String,
    pub author_name: String,
    pub author_avatar: String,
    pub content: String,
    pub create_time: String,
    /// 顶层评论点赞数
    pub like_count: u32,
    /// 该评论下的回复列表
    pub replies: Option<Vec<CommentReply>>,
}

#[derive(Debug, Clone, uniffi::Record, serde::Serialize, serde::Deserialize)]
pub struct CommentReply {
    pub id: String,
    pub author_name: String,
    /// 回复给谁 (例如：回复 @张三)
    pub replied_to_user: Option<String>,
    pub content: String,
    pub create_time: String,
    /// 回复点赞数
    pub like_count: u32,
}
