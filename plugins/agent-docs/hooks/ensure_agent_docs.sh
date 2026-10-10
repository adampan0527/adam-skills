#!/usr/bin/env bash
# ensure_agent_docs.sh
#
# SessionStart hook for Claude Code and Codex.
#
# If the project root has no _AGENTS.md AND the root looks like a real
# project, scaffold the minimal progressive-disclosure entry point:
#   <root>/_AGENTS.md    <- single source of truth (entry prompt, filled progressively)
#   <root>/AGENTS.md     <- pointer to _AGENTS.md
#   <root>/CLAUDE.md     <- pointer to _AGENTS.md
#
# It deliberately does NOT pre-create docs/*.md. The _AGENTS.md it writes
# explains that docs are created on demand, because a stub document that
# every session's index table points at is pure wasted context.
#
# Safety guards, in order:
#   - AGENT_DOCS_DISABLE=1 in the environment   -> do nothing, everywhere
#   - <root>/.agent-docs-disable exists          -> do nothing, that project
#   - root is a system dir or $HOME              -> do nothing
#   - root has no project marker                 -> do nothing
# The hook is idempotent: once _AGENTS.md exists it exits silently.
#
# Env:
#   CODEX_PROJECT_ROOT / CLAUDE_PROJECT_DIR - fallback root when the hook
#                                            payload carries no cwd
#   AGENT_DOCS_DISABLE                      - set to 1 to opt out entirely
# Requires: bash 3.2+ and POSIX userland (mktemp/sed/cut/tr/ls/pwd). No node, jq, python.
# On Windows this needs Git Bash (or MSYS2) on PATH; Windows-native
# paths from the harness payload are converted before use.

set -uo pipefail

[ "${AGENT_DOCS_DISABLE:-0}" = "1" ] && exit 0

payload="$(cat 2>/dev/null || true)"

# Extract the session cwd from the hook payload (JSON on stdin).
cwd="$(printf '%s' "$payload" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

# Fallbacks: payload without cwd -> env var -> process cwd.
root="${cwd:-${CODEX_PROJECT_ROOT:-${CLAUDE_PROJECT_DIR:-}}}"
[ -n "$root" ] || root="$(pwd)"

# On Windows the harness reports a native path ("C:\Users\me\project" or
# "C:/Users/me/project"). Under Git Bash / MSYS, cd needs "/c/Users/me/project"
# instead. Normalise, then try both spellings so this works under any shell
# that can see the directory at all.
to_shell_path() {
  case "$1" in
    [A-Za-z]:[\\/]*)
      printf '/%s%s\n' \
        "$(printf '%s' "$1" | cut -c1 | tr '[:upper:]' '[:lower:]')" \
        "$(printf '%s' "$1" | cut -c3- | tr '\\' '/')"
      ;;
    *)
      printf '%s\n' "$1" | tr '\\' '/'
      ;;
  esac
}

resolved=""
for candidate in "$(to_shell_path "$root")" "$root"; do
  resolved="$(cd "$candidate" 2>/dev/null && pwd -P)" || resolved=""
  [ -n "$resolved" ] && break
done
[ -n "$resolved" ] || exit 0
root="$resolved"
[ -d "$root" ] || exit 0

# Keep the harness-reported spelling for the message humans read.
display_root="${cwd:-$root}"

AGENT_MD="$root/_AGENTS.md"
POINTER_TARGET="_AGENTS.md"

# Already initialised -> nothing to do.
[ -e "$AGENT_MD" ] && exit 0

# Never scaffold inside these directories.
case "$root" in
  /System|/System/*|/Library|/Library/*|/private/var|/private/etc|/dev|/Applications) exit 0 ;;
  /c/Windows|/c/Windows/*|/c/Program\ Files|/c/Program\ Files/*|/c/ProgramData) exit 0 ;;
esac

# Never scaffold into the user's home directory. Guard on HOME being set:
# `cd ""` succeeds and stays put, so an unset HOME would otherwise make every
# project look like $HOME and silently disable the hook everywhere.
if [ -n "${HOME:-}" ]; then
  home="$(cd "$HOME" 2>/dev/null && pwd -P)" || home=""
  [ -n "$home" ] && [ "$root" = "$home" ] && exit 0
fi

# Per-project opt out: an empty file the user can drop in to silence us for
# good without touching their shell profile.
[ -e "$root/.agent-docs-disable" ] && exit 0

# --------------------------------------------- is this actually a project? ---
# Scaffolding a random scratch directory (or a folder the user just cd'd into
# while exploring) is noise, not help. Require a project marker.
looks_like_project() {
  local marker
  for marker in .git .hg .svn \
               package.json pyproject.toml setup.py requirements.txt \
               go.mod Cargo.toml pom.xml build.gradle build.gradle.kts \
               composer.json Gemfile Makefile CMakeLists.txt \
               .project
  do
    [ -e "$root/$marker" ] && return 0
  done
  # Already carries an agent entry point under another name -> hand-managed
  # project, and an index is still worth having. Note: a bare docs/ directory
  # is deliberately NOT a signal. Plenty of non-project folders keep notes in
  # docs/, and scaffolding them would be a false positive.
  [ -e "$root/AGENTS.md" ] || [ -e "$root/CLAUDE.md" ]
}
looks_like_project || exit 0

created_any=0

write_if_absent() {
  # $1 = target file, stdin = content
  local target="$1"
  [ -e "$target" ] && return 0
  local tmp
  tmp="$(mktemp "${target}.XXXXXX")" || return 1
  cat > "$tmp" && mv "$tmp" "$target"
  created_any=1
}

# ---------------------------------------------------------------- pointers ---
write_if_absent "$root/AGENTS.md" <<EOF
# AGENTS.md（入口指针）

本文件**不存放任何提示词正文**，只是给各 AI 工具的入口指针。

请阅读唯一的内容源：[${POINTER_TARGET}](./${POINTER_TARGET})，并严格按其中的规则工作。

- 内容源：\`${POINTER_TARGET}\`（根目录）
- 详细文档：\`docs/\` 目录，索引见 \`${POINTER_TARGET}\` 中的「什么时候看哪份文档」表格
EOF

write_if_absent "$root/CLAUDE.md" <<EOF
# CLAUDE.md（入口指针）

本文件**不存放任何提示词正文**，只是给 Claude Code 等工具的入口指针。

请阅读唯一的内容源：[${POINTER_TARGET}](./${POINTER_TARGET})，并严格按其中的规则工作。

- 内容源：\`${POINTER_TARGET}\`（根目录）
- 详细文档：\`docs/\` 目录，索引见 \`${POINTER_TARGET}\` 中的「什么时候看哪份文档」表格
EOF

# ------------------------------------------------------- the single source ---
write_if_absent "$AGENT_MD" <<'MDEOF'
# _AGENTS.md — 本项目唯一的 Agent 提示词入口

> ⚠️ **当前状态：本项目还没有入口提示词。**
> 本文件是由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 在项目首次启动时自动生成的骨架，
> 除了「基础说明」和下面的索引表格之外，**没有任何针对本项目的具体约定**。
>
> 请按照下方「渐进式披露原则」把内容**逐条、按需**地填充进来，而不是一次性写一大篇。

---

## 1. 基础说明

| 项目 | 内容 |
| --- | --- |
| 项目名称 | <待填写：从 `package.json` / `pyproject.toml` / README 推断后填写> |
| 一句话定位 | <待填写：这个项目是做什么的> |
| 主要语言 / 运行时 | <待填写> |
| 主要入口 | <待填写：CLI 入口、server 入口、库导出…> |
| 包管理器 / 构建命令 | <待填写> |
| 测试命令 | <待填写> |
| 代码规范来源 | <待填写：如 eslint / ruff / clippy / 自定义脚本> |
| 文档目录 | `docs/`（**按需创建**，见第 2 节） |

**填写规则**：每一行都只写「查得到的事实」，一行不超过 30 字；写不出来就保持 `待填写`，不要编造。

## 2. 什么时候看哪份文档

下表是本项目的**文档索引**。遇到左边的情况时，**只**阅读右边这一份文档，读完再继续干活。

| 遇见的情况 | 应该看哪个文档 |
| --- | --- |
| 第一次进入项目，想知道整体结构、模块划分与依赖关系 | <按需创建：docs/architecture.md> |
| 要写代码或提 PR，想知道命名/风格/目录约定 | <按需创建：docs/conventions.md> |
| 上表都没覆盖的新情况 | 先回到本文件新增一行「情况 → 文档」，再补写那份文档 |

`docs/` 下的文档**按需创建，不预先占位**：只有当你真的写下了值得复用的内容，
才 `mkdir -p docs` 建对应文件，并**同时**在上表加一行指向它。
反之，一份全是 `待填写` 的空文档被索引后，每次会话都会白白读它一遍。

## 3. 渐进式披露原则（Progressive Disclosure）

本项目所有 Agent 上下文遵循三条硬规则：

1. **入口最小化**：`_AGENTS.md` 只允许放「基础说明」+「索引表格」+「硬性红线」，正文一律外链。
   任何一节超过 20 行，就说明它该搬进 `docs/` 了。
2. **按需加载**：判断该读哪份文档的标准是**上表的「情况」列**，不是「文件好不好看」。
   没匹配到就不读；匹配到就读，且**只读这一份**。
3. **写进哪里由「是否会被复用」决定**：
   - 一次性的、只跟当前任务有关的 → 写在当次回复或 issue 里，**不要**进仓库；
   - 下次还会用到的 → 写进对应的 `docs/*.md`，并**同时在第 2 节表格里加一行**指向它；
   - 会反复触发的硬性约束（禁止操作、必须先做的检查）→ 提级写进本文件第 4 节。

## 4. 硬性红线

MDEOF

# Red lines that hold for every project regardless of stack.
cat >> "$AGENT_MD" <<'MDEOF'
- **禁止**编造基础说明里的事实：查不到就写 `待填写`。
- **禁止**往 `AGENTS.md` / `CLAUDE.md` 写正文——它们只能是指针。

## 5. 维护本文件

- 修改本项目约定时，**改 `docs/` 下的正文**，本文件只维护索引。
- 新增文档 = 在 `docs/` 建文件 + 在第 2 节表格加一行，两件事必须同时做完。
- `AGENTS.md` 与 `CLAUDE.md` 只是指针，**永远不要往里面写正文**。

## 6. 不想让本插件再动这个项目

在本项目根目录建一个空文件 `.agent-docs-disable` 即可。
MDEOF

[ "$created_any" -eq 0 ] && exit 0

# Tell the agent the scaffold exists and how to maintain it.
cat <<EOF
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[project-init] 检测到项目根目录 ${display_root} 之前没有 ${POINTER_TARGET}，已自动生成 ${POINTER_TARGET} / AGENTS.md / CLAUDE.md 三个文件。当前项目**还没有真正的入口提示词**：请在本次工作中按 ${POINTER_TARGET} 中的「渐进式披露原则」把基础说明填成真实内容。docs/ 下的文档**按需创建**——不要预先铺一堆待填写占位文件，只有真的写下了可复用的内容才建文件并加索引行。不想要这套脚手架的话，在根目录建一个空的 .agent-docs-disable 即可。"}}
EOF
