#!/bin/bash
# Dify 快速启动脚本

set -e

PROJECT_DIR="/Users/seqi/projects/claude_project/new_ai/projects/dify"

echo "🚀 启动 Dify AI 平台..."
echo ""

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ 错误: Docker 未运行，请先启动 Docker Desktop"
    exit 1
fi

echo "✅ Docker 运行正常"
echo ""

# 进入 docker 目录
cd "$PROJECT_DIR/docker"

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "📝 创建环境配置文件..."
    cp .env.example .env
    echo "✅ 环境配置文件已创建"
    echo ""
fi

# 启动服务
echo "🐳 启动 Docker 容器..."
echo "这可能需要 1-2 分钟，请耐心等待..."
echo ""

docker compose up -d

echo ""
echo "✅ Dify 启动成功！"
echo ""
echo "📍 访问地址:"
echo "   控制台: http://localhost/install"
echo "   API 文档: http://localhost/api/docs"
echo ""
echo "📊 查看日志:"
echo "   cd $PROJECT_DIR/docker && docker compose logs -f"
echo ""
echo "🛑 停止服务:"
echo "   cd $PROJECT_DIR/docker && docker compose down"
echo ""
