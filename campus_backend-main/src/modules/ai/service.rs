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
use crate::modules::ai::tools::{
    get_forum_recent_posts, get_recent_activities, get_today_weather, ActivityToolArgs,
    ActivityToolItem, ForumSummaryItem, WeatherInfo, WeatherToolArgs,
};
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

/// 从用户问题中尽量提取中文城市名；如果没有命中，则回退为“校园”。
fn extract_location_from_text(text: &str) -> String {
    // 简单规则：如果包含下列常见城市名之一，则返回该城市名。
    // 如需更多城市，可在此列表中按需补充。
    const CITIES: [&str; 10] = [
        "北京", "上海", "广州", "深圳", "杭州", "南京", "成都", "武汉", "西安", "安阳",
    ];

    for city in CITIES.iter() {
        if text.contains(city) {
            return city.to_string();
        }
    }

    // 没有显式城市名时，回退为“校园”
    "校园".to_string()
}

/// 工具规划结果，用于告诉后端需要调用哪些工具以及调用参数。
#[derive(Debug, serde::Deserialize)]
struct ToolPlan {
    #[serde(default)]
    use_activity_tool: bool,
    #[serde(default)]
    use_weather_tool: bool,
    #[serde(default)]
    use_forum_tool: bool,
    activity_args: Option<ActivityToolArgs>,
    weather_args: Option<WeatherToolArgs>,
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

        // 如果是新会话，取首条 user 消息的前 32 个「字符」作为标题
        let title = request
            .messages
            .iter()
            .find(|m| m.role.to_lowercase() == "user")
            .and_then(|m| {
                let s: String = m.content.chars().take(32).collect();
                if s.is_empty() { None } else { Some(s) }
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
        let req_max_tokens: u16 = req_max_tokens_i32.clamp(1, u16::MAX as i32) as u16;

        // 固定的 system 提示，避免模型重复用户输入，并显式告知其具备的“工具”能力
        let mut upstream_with_system = upstream_messages;
        upstream_with_system.insert(
            0,
            ChatCompletionRequestMessage::from(
                ChatCompletionRequestUserMessageArgs::default()
                    .role(async_openai::types::Role::System)
                    .content(
                        "你是校园 AI 助手，请直接回答问题，避免重复用户输入，保持简洁。\n\
                         后端为你提供了两个工具：\n\
                         1）“校园活动查询工具”，可以基于数据库中的活动记录，按时间范围返回近期的校园活动列表，\
                         方便你按类型或时间做总结与推荐；\n\
                         2）“天气工具”，可以给出今天校园的天气概况（包括温度与简单描述）。\n\
                         当用户询问天气、是否适合户外活动、近期校园活动/讲座/比赛时，你可以结合这些工具返回的 JSON 数据，\
                         用自然语言给出具体、贴近现实的回答。",
                    )
                    .build()
                    .unwrap(),
            ),
        );

        // ========== 第一步：在后端根据用户最后一句话进行简单规则匹配，决定是否需要调用“活动查询工具”和“天气工具” ==========
        // 为了可靠性，这里不再依赖大模型返回 JSON，而是用关键词触发，先满足需求再考虑升级为真正的 function calling。
        let last_user_content = request
            .messages
            .iter()
            .rev()
            .find(|m| m.role.to_lowercase() == "user")
            .map(|m| m.content.clone())
            .unwrap_or_default();

        let lower = last_user_content.to_lowercase();
        let mut plan = ToolPlan {
            use_activity_tool: false,
            use_weather_tool: false,
            use_forum_tool: false,
            activity_args: None,
            weather_args: None,
        };

        // 简单中文+英文关键词规则：
        // - 含有“天气”或“weather”则触发天气工具
        // - 含有“活动”“讲座”“比赛”或“event”则触发活动工具
        if lower.contains("天气") || lower.contains("weather") {
            plan.use_weather_tool = true;
            plan.weather_args = Some(WeatherToolArgs {
                // 尝试从原始问题中解析城市，例如“北京”“安阳”，否则退回“校园”
                location: Some(extract_location_from_text(&last_user_content)),
            });
        }

        if lower.contains("活动") || lower.contains("讲座") || lower.contains("比赛") || lower.contains("event") {
            plan.use_activity_tool = true;
            plan.activity_args = Some(ActivityToolArgs {
                time_range: "7d".to_string(),
                category: None,
                limit: 20,
            });
        }

        // 论坛相关提问，触发论坛摘要工具
        if lower.contains("论坛") || lower.contains("帖子") || lower.contains("讨论") {
            plan.use_forum_tool = true;
        }

        // ========== 第二步：根据规划结果调用真实工具（数据库 / 天气 / 论坛），并把结果注入到对话上下文 ==========
        let mut tool_notes: Vec<String> = Vec::new();
        // 供后续在模型返回空内容时做兜底回答使用
        let mut activity_items_for_fallback: Option<Vec<ActivityToolItem>> = None;
        let mut weather_for_fallback: Option<WeatherInfo> = None;
        let mut forum_items_for_fallback: Option<Vec<ForumSummaryItem>> = None;

        if plan.use_activity_tool {
            if let Some(args) = plan.activity_args {
                match get_recent_activities(pool, user_id, args).await {
                    Ok(activities) if !activities.is_empty() => {
                        let json = serde_json::to_string(&activities)
                            .unwrap_or_else(|_| "[]".to_string());
                        tool_notes.push(format!("【活动数据】{}", json));
                        activity_items_for_fallback = Some(activities);
                    }
                    Ok(_) => {
                        // 没有查到活动，不视为错误，只是不注入数据
                    }
                    Err(e) => {
                        tracing::warn!("get_recent_activities failed: {}", e);
                    }
                }
            }
        }

        if plan.use_weather_tool {
            let weather_args = plan.weather_args.unwrap_or(WeatherToolArgs {
                location: Some("校园".to_string()),
            });
            match get_today_weather(weather_args).await {
                Ok(info) => {
                    let json = serde_json::to_string(&info)
                        .unwrap_or_else(|_| "{\"error\":\"serialize\"}".into());
                    tool_notes.push(format!("【天气数据】{}", json));
                    weather_for_fallback = Some(info);
                }
                Err(e) => {
                    tracing::warn!("get_today_weather failed: {}", e);
                }
            }
        }

        if plan.use_forum_tool {
            match get_forum_recent_posts(pool, user_id, 10).await {
                Ok(items) if !items.is_empty() => {
                    let json = serde_json::to_string(&items)
                        .unwrap_or_else(|_| "[]".to_string());
                    tool_notes.push(format!("【论坛数据】{}", json));
                    forum_items_for_fallback = Some(items);
                }
                Ok(_) => {
                    // 论坛没有帖子，不视为错误
                }
                Err(e) => {
                    tracing::warn!("get_forum_recent_posts failed: {}", e);
                }
            }
        }

        if !tool_notes.is_empty() {
            let merged = tool_notes.join("\n");
            upstream_with_system.push(ChatCompletionRequestMessage::from(
                ChatCompletionRequestUserMessageArgs::default()
                    .role(async_openai::types::Role::System)
                    .content(format!(
                        "下面是你可以使用的后端工具查询结果（JSON 格式，仅供参考，不要照搬原文）：\n{}",
                        merged
                    ))
                    .build()
                    .unwrap(),
            ));
        }

        // ========== 第三步：在增强后的上下文基础上，让大模型生成最终回答 ==========
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

        let mut reply_message = resp
            .choices
            .first()
            .and_then(|c| c.message.content.clone())
            .unwrap_or_default();

        // 如果模型在有工具数据的情况下仍然返回空内容，使用一个简单的规则模板做兜底回答，
        // 避免前端看到“这次我没有生成有效的回答”。
        if reply_message.trim().is_empty() {
            if let Some(info) = weather_for_fallback {
                reply_message = format!(
                    "根据后端天气工具的数据，{} 今天是 {}，气温大约 {}℃，{}",
                    info.location, info.date, info.temperature_celsius, info.summary
                );
            } else if let Some(items) = activity_items_for_fallback {
                if items.is_empty() {
                    reply_message =
                        "我在数据库里暂时没有查到今天或最近几天的校园活动记录。你可以稍后再试试，或者关注学校官网/公众号的最新通知。"
                            .to_string();
                } else {
                    let mut lines = Vec::new();
                    lines.push("根据数据库中的记录，接下来一段时间内有以下校园活动：".to_string());
                    for (idx, a) in items.iter().take(5).enumerate() {
                        lines.push(format!(
                            "{}. 《{}》 - 地点：{}，开始时间：{}，名额：{}/{}",
                            idx + 1,
                            a.title,
                            a.location,
                            now_iso8601(a.start_time),
                            a.current_enrollments,
                            a.quota
                        ));
                    }
                    if items.len() > 5 {
                        lines.push(format!(
                            "…… 还有 {} 个活动，这里就不一一列出了。",
                            items.len() - 5
                        ));
                    }
                    lines.push("你可以告诉我你感兴趣的活动类型，我可以帮你再做更精细的推荐。".to_string());
                    reply_message = lines.join("\n");
                }
            } else if let Some(items) = forum_items_for_fallback {
                if items.is_empty() {
                    reply_message =
                        "我在论坛数据库里暂时没有查到今天或最近几天的讨论帖。你可以稍后再试，或者直接打开论坛模块查看最新帖子。"
                            .to_string();
                } else {
                    let mut lines = Vec::new();
                    lines.push("根据论坛数据库里的最新帖子，大家最近主要在讨论这些话题：".to_string());
                    for (idx, p) in items.iter().take(5).enumerate() {
                        lines.push(format!(
                            "{}. [{}]《{}》 - 摘要：{}（点赞 {}，评论 {}）",
                            idx + 1,
                            p.board_name,
                            p.title,
                            p.summary,
                            p.like_count,
                            p.comment_count
                        ));
                    }
                    if items.len() > 5 {
                        lines.push(format!(
                            "…… 还有 {} 条热度较高的帖子，这里就不一一列出了。",
                            items.len() - 5
                        ));
                    }
                    lines.push("如果你对某个话题感兴趣，可以告诉我标题或大致内容，我帮你继续分析。".to_string());
                    reply_message = lines.join("\n");
                }
            }
        }

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
