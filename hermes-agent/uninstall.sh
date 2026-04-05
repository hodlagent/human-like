#!/usr/bin/env bash
# uninstall.sh — 卸载 human-like 自主思考系统
# 用法: bash uninstall.sh
#
# 此脚本会：
#  1. 提示用户让 Hermes Agent 移除 cron 任务（执行 deactivate.md）
#  2. 可选删除 ~/.hermes/human-like/ 下的所有数据（包括思考记录）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")" && pwd)"
HERMES_DATA="$HOME/.hermes/human-like"

echo ""
echo " Human-Like 卸载程序 (Hermes Agent)"
echo " =================================="
echo ""

echo "步骤 1/2: 请先在 Hermes 会话中执行以下指令来删除 cron 任务："
echo ""
echo "  cat $SCRIPT_DIR/deactivate.md"
echo ""
echo "  或者直接把 deactivate.md 的内容贴给 Agent 说：\"请执行这个卸载指令\"。"
echo ""

echo "步骤 2/2: 本地数据清理"
echo ""
echo "是否删除数据目录 $HERMES_DATA 及其所有内容？"
echo "（包含 thinking-state.json、thinking-queue.json 和所有思考记录）"
echo ""
read -p "确认删除？(y/N): " answer

case "$answer" in
  [yY][eE][sS]|[yY])
    echo "  正在删除 $HERMES_DATA ..."
    rm -rf "$HERMES_DATA"
    echo "  ✓ 数据目录已删除"
    ;;
  *)
    echo "  跳过数据删除（目录保留）"
    ;;
esac

echo ""
echo " =================================="
echo " 卸载完成"
echo " =================================="
echo ""
