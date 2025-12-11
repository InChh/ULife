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


