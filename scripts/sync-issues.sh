#!/usr/bin/env bash
#
# 把 issue-bodies/*.md 同步到「已存在」的周任务 Issue（按标题匹配，就地更新，不新建重复）
#
# 与 create-issues.sh 的区别：
#   create-issues.sh  → 无条件 gh issue create，只能跑一次，重跑会产生重复 Issue
#   sync-issues.sh    → 先按标题找已有 Issue，找到就 edit，找不到才 create；默认 dry-run
#
# 用法:
#   ./scripts/sync-issues.sh                  # 只预览，不写任何东西
#   ./scripts/sync-issues.sh --apply          # 真正写回 GitHub
#   ./scripts/sync-issues.sh --apply /path/to/gh
#
set -uo pipefail

GH="gh"
APPLY=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    -*)      echo "✗ 未知参数: $arg"; exit 1 ;;
    *)       GH="$arg" ;;
  esac
done

REPO="kooduckV2/frontend-roadmap"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/issue-bodies"

TITLES=(
  "" \
  "第 1 周｜环境 + JS 语言基础" \
  "第 2 周｜原型链与异步" \
  "第 3 周｜CSS 布局" \
  "第 4 周｜TypeScript 基础" \
  "第 5 周｜TS 进阶 + Vue3 起步" \
  "第 6 周｜组件化" \
  "第 7 周｜路由、状态与权限" \
  "第 8 周｜Vue 响应式原理" \
  "第 9 周｜Node.js 运行时" \
  "第 10 周｜NestJS 基础" \
  "第 11 周｜NestJS 鉴权与切面" \
  "第 12 周｜数据库与 ORM" \
  "第 13 周｜全栈打通 + 类型共享" \
  "第 14 周｜测试" \
  "第 15 周｜工程化与部署" \
  "第 16 周｜性能、可观测性与收尾"
)

LABELS=(
  "" "P1-基础" "P1-基础" \
  "P2-前端" "P2-前端" "P2-前端" \
  "P3-Vue" "P3-Vue" "P3-Vue" \
  "P4-后端" "P4-后端" "P4-后端" "P4-后端" \
  "P5-交付" "P5-交付" "P5-交付" "P5-交付"
)

# ---------- 前置检查 ----------
if ! command -v "$GH" >/dev/null 2>&1 && [ ! -x "$GH" ]; then
  echo "✗ 找不到 gh: $GH"
  echo "  macOS 安装：brew install gh   然后：gh auth login"
  exit 1
fi

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "✗ 尚未登录 GitHub：$GH auth login -h github.com -p ssh -w"
  exit 1
fi

[ "$APPLY" -eq 1 ] || echo "== DRY-RUN（只预览，不写入；加 --apply 才真正执行）=="
echo

# ---------- 现有 Issue 标题 → 编号 ----------
existing="$("$GH" issue list --repo "$REPO" --state all --limit 200 \
  --json number,title --jq '.[] | "\(.number)\t\(.title)"')" || {
  echo "✗ 拉取 Issue 列表失败"; exit 1; }

echo "== 现有 Issue：$(printf '%s\n' "$existing" | grep -c .) 个 =="
echo

updated=0; created=0; skipped=0
for i in $(seq 1 16); do
  n=$(printf "%02d" "$i")
  title="${TITLES[$i]}"
  num="$(printf '%s\n' "$existing" | awk -F'\t' -v t="$title" '$2 == t { print $1; exit }')"

  if [ -n "$num" ]; then
    printf "  ↻ #%-3s 更新  %s\n" "$num" "$title"
    if [ "$APPLY" -eq 1 ]; then
      if "$GH" issue edit "$num" --repo "$REPO" --body-file "$DIR/$n.md" >/dev/null 2>&1; then
        updated=$((updated + 1))
      else
        printf "       ✗ 更新失败\n"; skipped=$((skipped + 1))
      fi
    fi
  else
    printf "  +     新建  %s\n" "$title"
    if [ "$APPLY" -eq 1 ]; then
      url="$("$GH" issue create --repo "$REPO" --title "$title" \
        --body-file "$DIR/$n.md" --label "${LABELS[$i]}" 2>/dev/null)"
      if [ -n "$url" ]; then
        created=$((created + 1)); printf "       ✓ %s\n" "${url##*/}"
      else
        printf "       ✗ 创建失败\n"; skipped=$((skipped + 1))
      fi
    fi
  fi
done

echo
if [ "$APPLY" -eq 1 ]; then
  echo "== 完成：更新 $updated，新建 $created，失败 $skipped =="
else
  echo "== 预览结束。确认无误后加 --apply 执行 =="
fi
echo "   https://github.com/$REPO/issues"
