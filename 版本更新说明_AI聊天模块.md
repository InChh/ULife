# 版本更新说明：AI 聊天模块（2025-12-11）

## 一、概览
- 本次版本在原有校园活动、论坛、课表等功能基础上，**新增「AI 聊天助手」模块**，为用户提供智能问答与学习辅导能力。

## 二、客户端（iOS）改动
- **新增 `AIChatViewController`**：
  - 提供简洁的对话界面，支持上下滚动查看历史消息。
  - 支持输入框+发送按钮的基础聊天交互。
  - 首次打开时自动向后端发起“打点”建立会话并获取欢迎语。
- **新增 `AIAssistantManager` 悬浮球入口**：
  - 在应用主界面右下角展示 AI 助手悬浮球，根据用户设置决定显示/隐藏。
  - 点击悬浮球以模态方式打开 `AIChatViewController`。
- **新增 `AIAssistantService` & Protobuf 接入**：
  - 通过 `ProtoNetworkManager` 调用后端 `/v1/proto/ai/chat`、`/v1/proto/ai/history` 接口。
  - 使用 `Protocol/ai.proto` 生成的 `Campus_Ai_*` 消息体进行序列化/反序列化，支持会话 ID 与历史消息拉取。
- **状态与持久化**：
  - 在本地存储最近一次会话的 `conversation_id`，支持续写历史会话。
  - 启动聊天页面时自动加载历史记录并滚动至底部。

## 三、服务端（Rust 后端）改动
- **新增 `modules/ai` 模块**：
  - `controller_proto.rs`：
    - 暴露 `/v1/proto/ai/chat` 与 `/v1/proto/ai/history/:conversation_id` 两个 Protobuf 接口。
  - `service.rs`：
    - 封装与上游大模型（通过 `async-openai` + SiliconFlow 兼容接口）的交互逻辑。
    - 负责会话创建、消息落库、上下文拼接、usage 统计等逻辑。
  - `entity.rs`：
    - 定义 `Conversation`、`AiMessage` 等数据库实体映射。
- **新增数据库迁移 `008_create_ai_tables.sql`**：
  - 新增 `ai_conversations`、`ai_messages` 等表，用于存储 AI 会话与消息记录。
- **新增 Protobuf 定义 `Protocol/ai.proto` & 服务器侧 `campus.ai.rs`**：
  - 定义 `ChatRequest`、`ChatResponse`、`ChatHistoryRequest`、`ChatHistoryResponse` 等消息结构。

## 四、配置与部署
- 后端新增/依赖以下环境变量（详见 `参考文档/AI助手模块.md`）：
  - `SILICONFLOW_API_KEY`：上游大模型 API Key。
  - `SILICONFLOW_BASE_URL`：SiliconFlow 基础 URL，例如 `https://api.siliconflow.cn/v1`。
  - `AI_MODEL`：使用的聊天模型名称（需为通用对话模型，而非 OCR 模型）。
- 部署时需：
  - 运行最新数据库迁移，确保 AI 相关表结构创建完成。
  - 正确配置上述环境变量并重启后端服务。

## 五、使用说明（面向产品/测试）
- 在用户打开应用且满足开启 AI 助手的设置条件时，右下角会出现 AI 悬浮球。
- 点击悬浮球打开聊天页后：
  - 输入任意问题并点击「发送」，即可收到 AI 助手回复。
  - 若之前已有会话，则会自动加载历史记录并在同一会话内续聊。
- 目前仅支持文本问答，不支持文件/图片上传，如后续有需求可在此基础上扩展。
