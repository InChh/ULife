#!/bin/bash

# 校园后端启动脚本
echo "======================================"
echo "   Campus Backend 启动脚本"
echo "======================================"
echo ""

# 检查端口 3000 是否被占用
PORT=3000
PID=$(lsof -ti:$PORT)

if [ ! -z "$PID" ]; then
    echo "⚠️  警告: 端口 $PORT 已被进程 $PID 占用"
    echo "正在关闭占用端口的进程..."
    kill $PID 2>/dev/null
    sleep 1
    echo "✅ 旧进程已关闭"
    echo ""
fi

# 检查数据库连接
echo "📋 检查配置..."
if [ ! -f .env ]; then
    echo "❌ 错误: 未找到 .env 文件"
    echo "请先复制 .env.example 并配置数据库连接"
    exit 1
fi
echo "✅ 配置文件存在"
echo ""

# 编译项目
echo "🔨 编译项目..."
if cargo build 2>&1 | grep -q "error:"; then
    echo "❌ 编译失败，请检查错误信息"
    exit 1
fi
echo "✅ 编译成功"
echo ""

# 启动服务
echo "🚀 启动服务..."
echo "服务将在 http://0.0.0.0:$PORT 运行"
echo "按 Ctrl+C 停止服务"
echo ""
echo "======================================"
echo ""

cargo run

