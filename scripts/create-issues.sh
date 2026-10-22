#!/usr/bin/env bash
#
# 批量创建 16 周周任务 Issue（含 5 个阶段标签）
#
# 用法:
#   ./scripts/create-issues.sh                    # 用 PATH 里的 gh
#   ./scripts/create-issues.sh /path/to/gh        # 用指定路径的 gh
#
set -uo pipefail

GH="${1:-gh}"
REPO="kooduckV2/frontend-roadmap"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/issue-bodies"

# ---------- 前置检查 ----------
if ! command -v "$GH" >/dev/null 2>&1 && [ ! -x "$GH" ]; then
  echo "✗ 找不到 gh: $GH"
  exit 1
fi

if ! "$GH" auth status >/dev/null 2>&1; then
  echo "✗ 尚未登录 GitHub，请先执行："
  echo "    $GH auth login -h github.com -p ssh -w"
  exit 1
fi

if [ ! -d "$DIR" ]; then
  echo "✗ 找不到 issue 内容目录: $DIR"
  exit 1
fi

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

# ---------- 标签 ----------
echo "== 创建阶段标签 =="
"$GH" label create "P1-基础" --repo "$REPO" --color "c5def5" --description "第 1–2 周 · 语言地基" --force
"$GH" label create "P2-前端" --repo "$REPO" --color "0e8a16" --description "第 3–5 周 · CSS / TS / Vue 起步" --force
"$GH" label create "P3-Vue"  --repo "$REPO" --color "42b883" --description "第 6–8 周 · 组件 / 路由 / 原理" --force
"$GH" label create "P4-后端" --repo "$REPO" --color "e11d48" --description "第 9–12 周 · Node / NestJS / 数据层" --force
"$GH" label create "P5-交付" --repo "$REPO" --color "6f42c1" --description "第 13–16 周 · 全栈打通 / 测试 / 部署" --force

# ---------- Issue（顺序创建，使「第 N 周」正好是 Issue #N） ----------
echo
echo "== 创建 16 个周任务 Issue =="
ok=0
fail=0
for i in $(seq 1 16); do
  n=$(printf "%02d" "$i")
  if url=$("$GH" issue create \
        --repo "$REPO" \
        --title "${TITLES[$i]}" \
        --body-file "$DIR/$n.md" \
        --label "${LABELS[$i]}" 2>/dev/null); then
    ok=$((ok + 1))
    printf "  ✓ %-28s %s\n" "${TITLES[$i]}" "${url##*/}"
  else
    fail=$((fail + 1))
    printf "  ✗ %s 创建失败\n" "${TITLES[$i]}"
  fi
done

echo
echo "== 完成：成功 $ok 个，失败 $fail 个 =="
echo "   https://github.com/$REPO/issues"
