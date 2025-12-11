## 模块概述
- 功能：为校内用户提供 AI 聊天助手，支持查看历史消息与续写，不允许客户端自行选择模型，模型在后端配置中写死。
- 接入方式：使用硅基流动（OpenAI 兼容）HTTP API，通过 `async-openai` 调用。
- 鉴权：沿用全局 Bearer Token（`Authorization: Bearer <token>`）。

## 技术选型
- 框架：Axum（与现有后端一致）。
- LLM SDK：`async-openai`（支持自定义 base_url 与 api_key）。
- 序列化：`serde` 系列。
- 日志与超时：使用现有 tracing/timeout 中间件，新增上游 request_id 记录。
- 流式返回：优先使用 SSE，备选 chunked。

## 配置项（env）
- `SILICONFLOW_API_KEY`：上游 API Key。
- `SILICONFLOW_BASE_URL`：如 `https://api.siliconflow.cn/v1`（以官方为准）。
- `AI_MODEL`：写死的模型名称，如 `deepseek-r1`（客户端不可覆盖）。
- `AI_TIMEOUT_MS`：可选，默认 30_000。

## API 设计
- 前缀：`/api/ai`
- 时间格式：ISO 8601（UTC）。
- 响应格式：与全局规范一致 `{ code, message, data }`。

### POST /api/ai/chat
- 功能：用户与 AI 助手聊天，返回回复；支持流式。
- 权限要求：需要认证。
- 请求头：
  - `Authorization: Bearer <token>`
  - `Accept: text/event-stream`（若需流式）
- 请求体（JSON）：
```json
{
  "conversation_id": 123,         // 可选，继续历史会话；不传则新建
  "messages": [                   // 必填，按顺序传递上下文
    { "role": "user", "content": "你好" }
  ],
  "stream": true,                 // 可选，默认 false
  "temperature": 0.7,             // 可选
  "max_tokens": 512               // 可选
}
```
- 说明：
  - `role` 允许 `system`/`user`/`assistant`，客户端通常传 user，system 由后端配置或追加。
  - 模型名从服务器配置 `AI_MODEL` 读取，不接受客户端传值。
  - 若 `conversation_id` 提供且属于当前用户，则在该会话下追加；否则报 404。

- 同步响应（`stream=false` 或未传）：
```json
{
  "code": 200,
  "message": "ok",
  "data": {
    "conversation_id": 123,
    "reply": "模型回答",
    "usage": { "prompt_tokens": 123, "completion_tokens": 45, "total_tokens": 168 },
    "model": "deepseek-r1",
    "request_id": "upstream-or-generated"
  }
}
```

- 流式响应（`stream=true`，SSE）：
  - `Content-Type: text/event-stream`
  - 事件序列：
    - `data: {"conversation_id":123,"delta":"部分内容","model":"deepseek-r1"}`
    - 可选 `data: {"usage": {...}}` 在尾部
    - `data: [DONE]` 结束

- 错误码：
  - 400 参数错误（messages 为空等）
  - 401 未认证
  - 404 会话不存在或不属于当前用户
  - 429 上游限流/自方限流（可附 `retry_after_ms`）
  - 500 上游错误或超时

## 数据库设计（MySQL）
> 仅存储会话与消息元信息，便于客户端查看历史与续写。

### 表：`ai_conversations`
- `id` BIGINT UNSIGNED PK AUTO_INCREMENT
- `user_id` BIGINT UNSIGNED NOT NULL          // 关联用户
- `title` VARCHAR(128) NULL                   // 会话标题（可取首轮消息前 N 字）
- `model` VARCHAR(64) NOT NULL                // 使用的模型（从配置）
- `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- 索引：
  - `idx_ai_conv_user` (`user_id`, `id`)

### 表：`ai_messages`
- `id` BIGINT UNSIGNED PK AUTO_INCREMENT
- `conversation_id` BIGINT UNSIGNED NOT NULL
- `role` ENUM('system','user','assistant') NOT NULL
- `content` MEDIUMTEXT NOT NULL
- `tokens` INT UNSIGNED NULL                  // 可存估算 token 数
- `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- 外键：
  - `fk_ai_msg_conv` (`conversation_id`) REFERENCES `ai_conversations` (`id`)
- 索引：
  - `idx_ai_msg_conv_created` (`conversation_id`, `created_at`)

### 表：`ai_usage_daily`（可选，用于配额统计）
- `id` BIGINT UNSIGNED PK AUTO_INCREMENT
- `user_id` BIGINT UNSIGNED NOT NULL
- `date` DATE NOT NULL
- `prompt_tokens` INT UNSIGNED NOT NULL DEFAULT 0
- `completion_tokens` INT UNSIGNED NOT NULL DEFAULT 0
- `total_tokens` INT UNSIGNED NOT NULL DEFAULT 0
- 唯一索引：`uniq_ai_usage_user_date` (`user_id`, `date`)

## 简要流程
1) 校验用户登录与会话归属。
2) 将用户消息写入 `ai_messages`（若新会话，先建 `ai_conversations`）。
3) 追加系统提示（可选）后，调用上游模型（模型名取自配置）。
4) 写入 assistant 消息与用量；同步或流式返回。
5) 异常时记录上游 request_id/状态码，向客户端返回对应错误。

## 客户端约定
- 客户端仅提供聊天框与历史列表，不暴露模型选择。
- 续写时需携带 `conversation_id` 与本地已展示的上下文（或后端查库拼接）。
- 流式场景下注意断线重连与停止按钮（取消请求）。
