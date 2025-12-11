use chrono::NaiveDateTime;
use sqlx::FromRow;

#[derive(Debug, FromRow)]
pub struct Conversation {
    pub id: u64,
    pub user_id: String,
    pub title: Option<String>,
    pub model: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Debug, FromRow)]
pub struct AiMessage {
    pub id: u64,
    pub conversation_id: u64,
    pub role: String,
    pub content: String,
    pub tokens: Option<u32>,
    pub created_at: NaiveDateTime,
}
