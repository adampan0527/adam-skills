#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# scaffold.sh —— 一键脚手架，创建一个 edu-web-powerpoint 项目。
#
# 用法：
#   bash scripts/scaffold.sh <target-dir> [--theme=<id>]
#   bash scripts/scaffold.sh --list-themes
#
# 例子：
#   bash <path-to-edu-web-powerpoint>/scripts/scaffold.sh ./presentation
#   bash <path-to-edu-web-powerpoint>/scripts/scaffold.sh ./lesson --theme=chalkboard
#   bash <path-to-edu-web-powerpoint>/scripts/scaffold.sh --list-themes
# ─────────────────────────────────────────────────────────────
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$SKILL_DIR/templates"
THEMES_DIR="$SKILL_DIR/themes"
DEFAULT_THEME="academic-blue"

list_themes() {
  echo "可用主题（来自 ${THEMES_DIR}）:"
  echo
  for dir in "$THEMES_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    local meta="$dir/theme.json"
    [[ -f "$meta" ]] || continue
    local id name desc
    id=$(grep -E '"id"' "$meta" | head -n1 | sed -E 's/.*"id":[[:space:]]*"([^"]+)".*/\1/')
    name=$(grep -E '"nameZh"' "$meta" | head -n1 | sed -E 's/.*"nameZh":[[:space:]]*"([^"]+)".*/\1/')
    desc=$(grep -E '"descriptionZh"' "$meta" | head -n1 | sed -E 's/.*"descriptionZh":[[:space:]]*"([^"]+)".*/\1/')
    printf "  • %-18s %s\n      %s\n\n" "$id" "$name" "$desc"
  done
  echo "用 --theme=<id> 选定一个。默认：${DEFAULT_THEME}。"
}

# ── 解析参数 ──
TARGET=""
THEME="$DEFAULT_THEME"
for arg in "$@"; do
  case "$arg" in
    --list-themes)
      list_themes
      exit 0
      ;;
    --theme=*)
      THEME="${arg#--theme=}"
      ;;
    --*)
      echo "✗ 未知参数: $arg" >&2
      exit 1
      ;;
    *)
      if [[ -z "$TARGET" ]]; then TARGET="$arg"; fi
      ;;
  esac
done

TARGET="${TARGET:-presentation}"
THEME_DIR="$THEMES_DIR/$THEME"
THEME_TOKENS="$THEME_DIR/tokens.css"

if [[ ! -d "$THEME_DIR" || ! -f "$THEME_TOKENS" ]]; then
  echo "✗ 找不到主题 '${THEME}'。可用主题：" >&2
  echo >&2
  for dir in "$THEMES_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    echo "    • $(basename "$dir")" >&2
  done
  exit 1
fi

if [[ -d "$TARGET" && -n "$(ls -A "$TARGET" 2>/dev/null || true)" ]]; then
  echo "✗ 目标目录 '${TARGET}' 已存在且非空，已中止。" >&2
  exit 1
fi

if ! command -v npm >/dev/null; then
  echo "✗ 需要 npm，但在 PATH 里没找到。" >&2
  exit 1
fi

echo "▸ 在 $TARGET 创建 Vite + React + TS 项目"
echo "▸ 使用主题：$THEME"
npm create vite@latest "$TARGET" -- --template react-ts >/dev/null

cd "$TARGET"
echo "▸ 安装依赖..."
npm install >/dev/null 2>&1

echo "▸ 用演示骨架替换默认 boilerplate"

rm -f \
  src/App.tsx src/App.css \
  src/main.tsx src/index.css \
  src/assets/react.svg \
  public/vite.svg \
  README.md
rmdir src/assets 2>/dev/null || true

mkdir -p \
  src/styles src/hooks src/components src/registry \
  src/chapters/01-example \
  public

cp "$TEMPLATES/vite.config.ts" .
cp "$TEMPLATES/index.html" .

cp "$TEMPLATES/src/main.tsx" src/main.tsx
cp "$TEMPLATES/src/App.tsx"  src/App.tsx

cp "$THEME_TOKENS"                          src/styles/tokens.css
cp "$TEMPLATES/src/styles/base.css"         src/styles/base.css
cp "$TEMPLATES/src/styles/animations.css"   src/styles/animations.css
cp "$TEMPLATES/src/styles/fonts.css"        src/styles/fonts.css

cp "$TEMPLATES/src/hooks/useStageScale.ts"   src/hooks/useStageScale.ts
cp "$TEMPLATES/src/hooks/useStepper.ts"      src/hooks/useStepper.ts

cp "$TEMPLATES/src/components/Stage.tsx"          src/components/Stage.tsx
cp "$TEMPLATES/src/components/MaskReveal.tsx"     src/components/MaskReveal.tsx
cp "$TEMPLATES/src/components/ProgressBar.tsx"    src/components/ProgressBar.tsx
cp "$TEMPLATES/src/components/ProgressBar.css"    src/components/ProgressBar.css

cp "$TEMPLATES/src/registry/types.ts"    src/registry/types.ts
cp "$TEMPLATES/src/registry/chapters.ts" src/registry/chapters.ts

cp "$TEMPLATES/src/chapters/01-example/Example.tsx"     src/chapters/01-example/Example.tsx
cp "$TEMPLATES/src/chapters/01-example/Example.css"     src/chapters/01-example/Example.css
cp "$TEMPLATES/src/chapters/01-example/narrations.ts"   src/chapters/01-example/narrations.ts

# 留个标记
echo "$THEME" > .theme

echo "▸ 跑 typecheck ..."
if npx tsc --noEmit; then
  echo "✓ typecheck 通过"
else
  echo "✗ typecheck 失败" >&2
  exit 1
fi

cat <<EOF

✓ 完成。下一步：

  1. cd $TARGET
  2. npm run dev

当前主题：${THEME}（见 .theme）

然后：

  • 点舞台任意位置推进全局 step 计数器。
  • 鼠标移到底部边缘可显出进度条。
  • 把 src/chapters/01-example/ 替换成你自己的章节。
  • 在 src/registry/chapters.ts 注册每个新章节。
  • 每章必须有 narrations.ts（数组长度 = step 数）。
  • 章节改了就 bump src/hooks/useStepper.ts 的 STORAGE_KEY。

写章节时必读：

  • $SKILL_DIR/references/CHAPTER-CRAFT.md
  • $SKILL_DIR/themes/$THEME/theme.json

要换一个主题，覆盖 tokens.css 即可：
  cp $SKILL_DIR/themes/<id>/tokens.css src/styles/tokens.css

EOF
