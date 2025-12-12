# ULife 项目指南

面向校园的 iOS 客户端 + Rust 后端项目。iOS 端通过本地运行的后端 (`http://localhost:3000/api`) 提供活动、论坛、课表、个人中心等功能。

## 目录结构
- `ULife/`：iOS App 源码与资源
- `campus_backend-main/`：Axum + MySQL 后端
- `Protocol/`：protobuf 定义
- `ULifeLib/`：供 iOS 调用的 Rust 静态库与 Swift Package
- `参考文档/`：模块与接口说明

## 基础环境
- macOS，Xcode 15+，建议 iOS 17 模拟器/真机
- Rust stable（通过 `rustup` 安装），Cargo
- MySQL 8+（utf8mb4，需可创建/导入 `ULife`）
- `protoc`（如需重新生成 Swift protobuf）

## 后端准备（`campus_backend-main/`）
运行 docs 里面的 init 数据库文件即可

## 启动后端
```bash
cd campus_backend-main
chmod +x start.sh run.sh
./start.sh      # 或 ./run.sh
```
服务默认监听 `http://0.0.0.0:3000/api`。启动脚本会检查端口占用与 `.env`。

## 启动 iOS 客户端（`ULife/`）
1. 打开 `ULife.xcodeproj`，选择 Scheme `ULife`，目标设备为 iOS 17+。
2. 确保后端已启动，且与 `ULife/Utils/Consts.swift` 中的 `APIConfig.baseURL` 一致（默认为 `http://localhost:3000/api`；若需真机调试请改成局域网可达的地址）。
3. 直接在 Xcode 中 Run 即可。工程已包含 `ULifeLib/RustFramework.xcframework`，无需额外构建。

## Protobuf 相关
- 协议定义位于 `Protocol/*.proto`；Swift 生成文件位于 `ULife/Models/Proto/Protocol/`。  
- 若更新协议，请安装 `protoc` 及 `swift-protobuf` 插件，并重新生成对应文件后提交。

## 常用命令速查
- 后端编译检查：`cd campus_backend-main && cargo check`
- 后端测试：`cd campus_backend-main && cargo test`
- 清理后端构建：`cd campus_backend-main && cargo clean`

## 版本更新（AI 聊天助手 & 工具接入）

### 2025-12-12：AI 聊天助手 + 工具能力

- **新增 AI 聊天助手模块**
  - iOS 端新增 `AIChatViewController`，通过悬浮球入口（`AIAssistantManager`）打开，与后端 `/v1/proto/ai/chat`、`/v1/proto/ai/history` 交互。
  - 使用 `Protocol/ai.proto` + `ai.pb.swift`/`campus.ai.rs` 实现 Protobuf 通信，会话 ID 和历史消息会在本地与服务端双向持久化。
  - 支持一键“刷新”清空当前会话上下文并重新开始新对话。

- **后端 AI 模块增强**
  - 新增 `modules/ai` 下的 `tools.rs`，封装可供大模型使用的工具：
    - **活动查询工具**：从 `activities` 表中按时间范围查询近期校园活动，供模型做“活动推荐/总结”。
    - **天气工具**：通过 Open‑Meteo API + 地理编码实时获取指定城市当天天气，用于回答“今天天气如何”等问题。
    - **论坛摘要工具**：复用 `BbsService::get_posts` 获取近期高热度帖子，让模型能回答“今天校园论坛在讨论什么”类问题。
  - `AIService::chat` 中：
    - 基于用户最近一条消息做简单关键词规划（活动/天气/论坛），按需调用上述工具并把 JSON 结果注入对话上下文。
    - 若模型在有工具数据时仍返回空内容，服务端会基于工具结果生成兜底回答，避免前端出现“无法生成有效回答”。

- **网络与稳定性改进**
  - 修复 UTF‑8 截断导致的 panic（会话标题、摘要统一改为按字符截断）。
  - Protobuf/JSON 网络层增加更详细的日志与错误处理，避免因单次请求失败导致会话整体中断。

