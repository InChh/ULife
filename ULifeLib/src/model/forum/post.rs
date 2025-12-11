#[derive(Debug, Clone, uniffi::Record, serde::Serialize, serde::Deserialize)]
/// 论坛帖子
pub struct ForumPost {
    id: i32,
    title: String,
    content: String,
    category: String,  // 板块
    tags: Vec<String>, // 标签
    image_urls: Vec<String>,
    author_id: i32,
    author_name: String,
    author_avatar: String,
    author_role: String,
    publish_time: String,
    view_count: i32,  // 观看人数
    like_count: i32,  // 点赞数
    reply_count: i32, // 踩数
    is_liked: bool,
    is_replied: bool,
    is_pinned: bool, // 是否置顶
}
