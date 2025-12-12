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

## 版本更新概览

### 2025-12-12：AI 聊天助手 + 工具能力 + 每日简报

- **AI 聊天助手**
  - 新增 `AIChatViewController` 与悬浮球入口（`AIAssistantManager`，现使用“小机器人”风格图标）。
  - 使用 Protobuf 接入后端 `/v1/proto/ai/chat`、`/v1/proto/ai/history`，支持会话 ID 持久化与历史消息加载。
  - 提供“刷新会话”能力，可一键清空上下文并重新拉起欢迎语。

- **后端 AI 工具体系**
  - 在 `modules/ai/tools.rs` 中新增三类工具：
    - 活动查询：基于 `activities` 表，按时间范围查询近期校园活动，为 AI 做推荐与总结。
    - 天气查询：通过 Open‑Meteo API + 地理编码实时获取指定城市当天天气。
    - 论坛摘要：复用 `BbsService::get_posts`，抽取近期热帖，支持“论坛在讨论什么”类问题。
  - `AIService::chat` 根据用户问题关键词自动决定是否调用上述工具，并将 JSON 结果注入 System 提示；如模型仍返回空内容，则由服务端使用工具结果生成兜底回答。

- **每日校园简报**
  - 后端新增定时任务 `AIService::generate_daily_digest`：周期性汇总当天活动与论坛数据，请求大模型生成不超过 100 字的“今日校园简报”，写入 `system_digest` 会话。
  - 提供 `GET /v1/ai/daily_digest` 接口，返回最近一条简报。
  - iOS 端新增 `DailyDigestManager`：在启动/回前台时调用该接口，并通过本地通知向用户推送简报（每天一次，Debug 下可开启高频测试模式）。

- **稳定性与体验**
  - 修复 UTF‑8 截断导致的 panic（会话标题、帖子摘要等统一按字符截断）。
  - 网络层增强错误日志输出与容错处理，避免单次 Protobuf/JSON 解码失败导致整体中断。

