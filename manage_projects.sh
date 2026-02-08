#!/bin/bash
# AI 项目管理系统主控脚本

PROJECTS_DIR="/Users/seqi/projects/claude_project/new_ai/projects"
LOG_FILE="/Users/seqi/projects/claude_project/new_ai/projects_log.json"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 显示标题
show_banner() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     🤖 AI 项目管理系统                  ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

# 列出所有项目
list_projects() {
    show_banner
    echo -e "${GREEN}📚 已下载的项目列表${NC}"
    echo ""

    if [ ! -f "$LOG_FILE" ]; then
        echo "还没有下载任何项目"
        echo ""
        return
    fi

    local i=1
    while IFS= read -r line; do
        if [[ $line == *"name"* ]]; then
            local name=$(echo "$line" | jq -r '.name')
            local path=$(echo "$line" | jq -r '.path')
            local stars=$(echo "$line" | jq -r '.stars')
            local desc=$(echo "$line" | jq -r '.description')

            echo -e "${YELLOW}[$i] $name${NC} ⭐ $stars"
            echo "    路径: $path"
            echo "    说明: $desc"
            echo ""
            ((i++))
        fi
    done < "$LOG_FILE"
}

# 启动项目
start_project() {
    show_banner

    if [ ! -f "$LOG_FILE" ] || [ $(jq '.projects | length' "$LOG_FILE") -eq 0 ]; then
        echo -e "${RED}❌ 没有可启动的项目${NC}"
        return
    fi

    echo -e "${GREEN}🚀 选择要启动的项目${NC}"
    echo ""

    # 列出项目
    local i=1
    declare -a projects
    while IFS= read -r line; do
        if [[ $line == *"name"* ]]; then
            local name=$(echo "$line" | jq -r '.name')
            local path=$(echo "$line" | jq -r '.path')
            projects[i]="$path"
            echo -e "  ${GREEN}$i${NC}. $name"
            ((i++))
        fi
    done < <(jq -c '.projects[]' "$LOG_FILE")

    echo ""
    read -p "请选择项目编号 [1-$(($i-1))]: " choice

    if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -lt $i ]; then
        local project_path="${projects[$choice]}"
        echo ""
        echo -e "${BLUE}正在启动项目...${NC}"

        # 检查是否有 start.sh
        if [ -f "$project_path/start.sh" ]; then
            bash "$project_path/start.sh"
        elif [ -f "$project_path/activate_env.sh" ]; then
            echo "进入项目目录: $project_path"
            echo "运行以下命令激活环境："
            echo ""
            echo "  cd $project_path"
            echo "  ./activate_env.sh"
            echo ""
        else
            echo "项目目录: $project_path"
            echo "请查看项目 README 了解启动方法"
        fi
    else
        echo -e "${RED}❌ 无效的选择${NC}"
    fi
}

# 查看项目详情
show_project_info() {
    show_banner

    if [ ! -f "$LOG_FILE" ]; then
        echo -e "${RED}❌ 还没有下载任何项目${NC}"
        return
    fi

    echo -e "${GREEN}📋 查看项目详情${NC}"
    echo ""

    # 列出项目
    local i=1
    declare -a projects
    while IFS= read -r line; do
        if [[ $line == *"name"* ]]; then
            local name=$(echo "$line" | jq -r '.name')
            local path=$(echo "$line" | jq -r '.path')
            projects[i]="$path"
            echo -e "  ${GREEN}$i${NC}. $name"
            ((i++))
        fi
    done < <(jq -c '.projects[]' "$LOG_FILE")

    echo ""
    read -p "请选择项目编号 [1-$(($i-1))]: " choice

    if [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 1 ] && [ $choice -lt $i ]; then
        local project_path="${projects[$choice]}"
        local info_file="$project_path/PROJECT_INFO.md"

        if [ -f "$info_file" ]; then
            clear
            cat "$info_file"
        else
            echo -e "${YELLOW}⚠️  该项目还没有详细说明文档${NC}"
            echo "项目路径: $project_path"
        fi
    else
        echo -e "${RED}❌ 无效的选择${NC}"
    fi
}

# 主菜单
show_menu() {
    show_banner
    echo -e "${GREEN}请选择操作:${NC}"
    echo ""
    echo "  ${BLUE}1${NC}. 📋 列出所有项目"
    echo "  ${BLUE}2${NC}. 🚀 启动项目"
    echo "  ${BLUE}3${NC}. 📖 查看项目详情"
    echo "  ${BLUE}4${NC}. ➕ 添加新项目"
    echo "  ${BLUE}5${NC}. ❌ 退出"
    echo ""
    read -p "请输入选项 [1-5]: " choice

    case $choice in
        1)
            list_projects
            read -p "按回车键继续..."
            show_menu
            ;;
        2)
            start_project
            read -p "按回车键继续..."
            show_menu
            ;;
        3)
            show_project_info
            read -p "按回车键继续..."
            show_menu
            ;;
        4)
            echo ""
            echo "添加新项目功能即将推出"
            echo ""
            read -p "按回车键继续..."
            show_menu
            ;;
        5)
            echo ""
            echo -e "${GREEN}👋 再见！${NC}"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 无效的选项${NC}"
            sleep 1
            show_menu
            ;;
    esac
}

# 启动程序
if [ "$1" == "list" ]; then
    list_projects
elif [ "$1" == "start" ]; then
    start_project
else
    show_menu
fi
