#!/bin/bash

echo "🚀 启动后端服务..."
echo ""
echo "📂 工作目录: $(pwd)"
echo ""

# 检查端口占用
PORT=3000
PID=$(lsof -ti:$PORT 2>/dev/null)

if [ ! -z "$PID" ]; then
    echo "⚠️  端口 $PORT 被进程 $PID 占用，正在关闭..."
    kill $PID 2>/dev/null
    sleep 1
    echo "✅ 旧进程已关闭"
    echo ""
fi

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "❌ 错误: 未找到 .env 文件"
    exit 1
fi

# 编译并运行
echo "🔨 编译并启动服务..."
echo ""

cargo run
