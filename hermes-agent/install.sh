#!/usr/bin/env bash
# install.sh — 安装 human-like 自主思考系统到 Hermes Agent
# 用法: bash install.sh
#
# 此脚本完成文件系统层面的准备（复制配置文件、创建目录）。
# 完成后请告诉 Hermes Agent 执行 activate.md 来创建 cron 任务。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd)"
HERMES_DATA="$HOME/.hermes/human-like"

echo ""
echo " Human-Like 安装程序 (Hermes Agent)"
echo " =================================="
echo ""

# 1. 创建数据目录
echo "[1/3] 创建数据目录 $HERMES_DATA ..."
mkdir -p "$HERMES_DATA/thoughts"
echo "   ✓ $HERMES_DATA/"
echo "   ✓ $HERMES_DATA/thoughts/"

# 2. 复制配置文件
echo "[2/3] 复制配置文件 ..."
cp -f "$SCRIPT_DIR/configs/thinking-state.json" "$HERMES_DATA/thinking-state.json"
cp -f "$SCRIPT_DIR/configs/thinking-queue.json" "$HERMES_DATA/thinking-queue.json"
echo "   ✓ thinking-state.json"
echo "   ✓ thinking-queue.json"

# 2.5 复制 cron payloads（确保 cron 任务能自动找到指令文件）
echo "[3/4] 复制 cron 指令 ..."
cp -rf "$SCRIPT_DIR/cron-payloads" "$HERMES_DATA/cron-payloads"
echo "   ✓ cron-payloads/"

# 3. 输出下一步
echo ""
echo " =================================="
echo " 安装完成"
echo " =================================="
echo ""
echo "下一步: 在 Hermes 会话中执行以下指令来创建 cron 任务："
echo ""
echo "  cat $SCRIPT_DIR/activate.md"
echo ""
echo "或者直接把 activate.md 的内容贴给 Agent 说：\"请执行这个激活指令\"。"
echo ""
