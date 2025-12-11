use async_openai::config::OpenAIConfig;
use async_openai::types::{
    ChatCompletionRequestAssistantMessageArgs, ChatCompletionRequestMessage,
    ChatCompletionRequestUserMessageArgs, CreateChatCompletionRequestArgs,
};
use async_openai::Client;
use chrono::{DateTime, NaiveDateTime, Utc};
use sqlx::{MySqlPool, Row};

use crate::common::error::AppError;
use crate::modules::ai::entity::{AiMessage, Conversation};
use crate::proto::ai::{ChatHistoryResponse, ChatMessage, ChatResponse, ChatUsage};

const DEFAULT_TEMPERATURE: f32 = 0.7;
const DEFAULT_MAX_TOKENS: u32 = 512;

fn now_iso8601(dt: NaiveDateTime) -> String {
    DateTime::<Utc>::from_naive_utc_and_offset(dt, Utc).to_rfc3339()
}

fn build_ai_client() -> Result<Client<OpenAIConfig>, AppError> {
    let api_key = std::env::var("SILICONFLOW_API_KEY")
        .map_err(|_| AppError::Internal("Missing env SILICONFLOW_API_KEY".into()))?;
    let base_url = std::env::var("SILICONFLOW_BASE_URL")
        .unwrap_or_else(|_| "https://api.siliconflow.cn/v1".to_string());

    let mut config = OpenAIConfig::new().with_api_key(api_key);
    config = config.with_api_base(base_url);

    Ok(Client::with_config(config))
}

async fn get_model_name() -> Result<String, AppError> {
    std::env::var("AI_MODEL")
        .map_err(|_| AppError::Internal("Missing env AI_MODEL".into()))
}

pub struct AIService;

impl AIService {
    async fn ensure_conversation(
        pool: &MySqlPool,
        user_id: &str,
        conversation_id: Option<u64>,
        model: &str,
        title: Option<&str>,
    ) -> Result<u64, AppError> {
        if let Some(cid) = conversation_id {
            let exists: Option<u64> = sqlx::query(
                "SELECT id FROM ai_conversations WHERE id = ? AND user_id = ? LIMIT 1",
            )
            .bind(cid)
            .bind(user_id)
            .fetch_optional(pool)
            .await?
            .map(|row| row.get(0));

            return exists.ok_or_else(|| AppError::NotFound("Conversation not found".into()));
        }

        let title_val = title.unwrap_or("").to_string();
        let rec = sqlx::query(
            "INSERT INTO ai_conversations (user_id, title, model) VALUES (?, ?, ?)",
        )
        .bind(user_id)
        .bind(title_val)
        .bind(model)
        .execute(pool)
        .await?;

        Ok(rec.last_insert_id())
    }

    async fn append_message(
        pool: &MySqlPool,
        conversation_id: u64,
        role: &str,
        content: &str,
        tokens: Option<u32>,
    ) -> Result<(), AppError> {
        sqlx::query("INSERT INTO ai_messages (conversation_id, role, content, tokens) VALUES (?, ?, ?, ?)")
            .bind(conversation_id)
            .bind(role)
            .bind(content)
            .bind(tokens)
            .execute(pool)
            .await?;
        Ok(())
    }

    async fn list_messages(
        pool: &MySqlPool,
        conversation_id: u64,
        user_id: &str,
    ) -> Result<(Conversation, Vec<AiMessage>), AppError> {
        let conversation: Option<Conversation> = sqlx::query_as::<_, Conversation>(
            "SELECT id, user_id, title, model, created_at, updated_at FROM ai_conversations WHERE id = ? AND user_id = ?",
        )
        .bind(conversation_id)
        .bind(user_id)
        .fetch_optional(pool)
        .await?;

        let conversation = conversation.ok_or_else(|| AppError::NotFound("Conversation not found".into()))?;

        let messages = sqlx::query_as::<_, AiMessage>(
            "SELECT id, conversation_id, role, content, tokens, created_at FROM ai_messages WHERE conversation_id = ? ORDER BY created_at ASC, id ASC",
        )
        .bind(conversation_id)
        .fetch_all(pool)
        .await?;

        Ok((conversation, messages))
    }

    pub async fn chat(
        pool: &MySqlPool,
        user_id: &str,
        request: &crate::proto::ai::ChatRequest,
    ) -> Result<ChatResponse, AppError> {
        if request.messages.is_empty() {
            return Err(AppError::Validation("messages cannot be empty".into()));
        }

        let model = get_model_name().await?;
        let client = build_ai_client()?;

        // 如果是新会话，取首条 user 消息的前 32 字符作为标题
        let title = request
            .messages
            .iter()
            .find(|m| m.role.to_lowercase() == "user")
            .and_then(|m| {
                let mut s = m.content.clone();
                if s.len() > 32 {
                    s.truncate(32);
                }
                if s.is_empty() {
                    None
                } else {
                    Some(s)
                }
            });

        let request_cid = request
            .conversation_id
            .and_then(|v| u64::try_from(v).ok());

        let conversation_id =
            Self::ensure_conversation(pool, user_id, request_cid, &model, title.as_deref())
                .await?;

        // 写入用户消息
        for msg in &request.messages {
            Self::append_message(pool, conversation_id, &msg.role, &msg.content, None).await?;
        }

        // 构建上游 messages：使用当前会话的所有历史（已含本次用户消息），避免重复
        let mut upstream_messages: Vec<ChatCompletionRequestMessage> = Vec::new();
        let (_, history_msgs) = Self::list_messages(pool, conversation_id, user_id).await?;
        for hm in history_msgs {
            let role_lower = hm.role.to_lowercase();
            if role_lower == "assistant" {
                upstream_messages.push(ChatCompletionRequestMessage::from(
                    ChatCompletionRequestAssistantMessageArgs::default()
                        .content(hm.content)
                        .build()
                        .unwrap(),
                ));
            } else {
                upstream_messages.push(ChatCompletionRequestMessage::from(
                    ChatCompletionRequestUserMessageArgs::default()
                        .content(hm.content)
                        .build()
                        .unwrap(),
                ));
            }
        }

        let req_temperature = request.temperature.unwrap_or(DEFAULT_TEMPERATURE as f64) as f32;
        let req_max_tokens_i32 = request.max_tokens.unwrap_or(DEFAULT_MAX_TOKENS as i32);
        // async-openai expects u16
        let req_max_tokens: u16 = req_max_tokens_i32
            .clamp(1, u16::MAX as i32)
            as u16;

        // 固定的 system 提示，避免模型重复用户输入
        let mut upstream_with_system = upstream_messages;
        upstream_with_system.insert(
            0,
            ChatCompletionRequestMessage::from(
                ChatCompletionRequestUserMessageArgs::default()
                    .role(async_openai::types::Role::System)
                    .content("你是校园 AI 助手，请直接回答问题，避免重复用户输入，保持简洁。")
                    .build()
                    .unwrap(),
            ),
        );

        let create_req = CreateChatCompletionRequestArgs::default()
            .model(model.clone())
            .temperature(req_temperature)
            .max_tokens(req_max_tokens)
            .messages(upstream_with_system)
            .build()
            .map_err(|e| AppError::Validation(format!("Invalid chat request: {}", e)))?;

        let resp = client
            .chat()
            .create(create_req)
            .await
            .map_err(|e| AppError::Internal(format!("LLM call failed: {}", e)))?;

        let reply_message = resp
            .choices
            .first()
            .and_then(|c| c.message.content.clone())
            .unwrap_or_default();

        // 保存 assistant 消息
        let completion_tokens = resp
            .usage
            .as_ref()
            .map(|u| u.completion_tokens as u32);

        Self::append_message(pool, conversation_id, "assistant", &reply_message, completion_tokens).await?;

        let usage_proto = resp.usage.as_ref().map(|u| ChatUsage {
            prompt_tokens: u.prompt_tokens as i32,
            completion_tokens: u.completion_tokens as i32,
            total_tokens: u.total_tokens as i32,
        });

        let reply_proto = ChatMessage {
            role: "assistant".to_string(),
            content: reply_message,
            created_at: "".to_string(),
        };

        Ok(ChatResponse {
            conversation_id: i64::try_from(conversation_id)
                .map_err(|_| AppError::Internal("conversation id overflow".into()))?,
            reply: Some(reply_proto),
            usage: usage_proto,
            model,
            request_id: resp.id.clone(),
        })
    }

    pub async fn history(
        pool: &MySqlPool,
        user_id: &str,
        conversation_id: i64,
    ) -> Result<ChatHistoryResponse, AppError> {
        let cid_u64 = u64::try_from(conversation_id)
            .map_err(|_| AppError::Validation("conversation_id must be positive".into()))?;

        let (conversation, messages) = Self::list_messages(pool, cid_u64, user_id).await?;

        let proto_messages: Vec<ChatMessage> = messages
            .into_iter()
            .map(|m| ChatMessage {
                role: m.role,
                content: m.content,
                created_at: now_iso8601(m.created_at),
            })
            .collect();

        Ok(ChatHistoryResponse {
            conversation_id,
            messages: proto_messages,
            model: conversation.model,
        })
    }
}
