#!/usr/bin/env bash
# ensure_agent_docs.sh
#
# Codex SessionStart hook.
# If the project root has no _AGENTS.md, scaffold:
#   <root>/_AGENTS.md    <- single source of truth (entry prompt, filled progressively)
#   <root>/AGENTS.md     <- pointer to _AGENTS.md
#   <root>/CLAUDE.md    <- pointer to _AGENTS.md
#   <root>/docs/*.md    <- the documents referenced by the table inside _AGENTS.md
# The hook is idempotent: it only acts when _AGENTS.md is missing.
#
# Env:
#   CODEX_PROJECT_ROOT  - fallback root when the hook payload carries no cwd
#   AGENT_DOCS_DISABLE  - set to 1 to opt out entirely
# Requires: bash 3.2+ and POSIX userland (mktemp/sed/pwd). No node, jq or python.

set -uo pipefail

[ "${AGENT_DOCS_DISABLE:-0}" = "1" ] && exit 0

payload="$(cat 2>/dev/null || true)"

# Extract the session cwd from the hook payload (JSON on stdin).
cwd="$(printf '%s' "$payload" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

# Fallbacks: payload without cwd -> env var -> process cwd.
root="${cwd:-${CODEX_PROJECT_ROOT:-}}"
[ -n "$root" ] || root="$(pwd)"
root="$(cd "$root" 2>/dev/null && pwd -P)" || exit 0
[ -d "$root" ] || exit 0

AGENT_MD="$root/_AGENTS.md"
POINTER_TARGET="_AGENTS.md"

# Already initialised -> nothing to do.
[ -e "$AGENT_MD" ] && exit 0

# Never scaffold inside these directories.
case "$root" in
  /System|/System/*|/Library|/Library/*|/private/var|/private/etc|/dev|/Applications) exit 0 ;;
esac
[ "$root" = "$(cd "$HOME" && pwd -P)" ] && exit 0

DOCS_DIR="$root/docs"
mkdir -p "$DOCS_DIR" || exit 0

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
| 文档目录 | `docs/` |

**填写规则**：每一行都只写「查得到的事实」，一行不超过 30 字；写不出来就保持 `待填写`，不要编造。

## 2. 什么时候看哪份文档

下表是本项目的**文档索引**。遇到左边的情况时，**只**阅读右边这一份文档，读完再继续干活。

| 遇见的情况 | 应该看哪个文档 |
| --- | --- |
| 第一次进入项目，想知道整体结构、模块划分与依赖关系 | [docs/architecture.md](docs/architecture.md) |
| 要写代码或提 PR，想知道命名/风格/目录约定 | [docs/conventions.md](docs/conventions.md) |
| 需要构建、运行、测试、打包、发布 | [docs/development-workflow.md](docs/development-workflow.md) |
| 要补测试或关心测试覆盖率与质量门禁 | [docs/testing.md](docs/testing.md) |
| 碰到业务概念、领域模型、名词看不懂 | [docs/domain-model.md](docs/domain-model.md) |
| 涉及配置项、环境变量、密钥、部署与运维 | [docs/operations.md](docs/operations.md) |
| 遇到报错、疑难排查、历史踩坑 | [docs/troubleshooting.md](docs/troubleshooting.md) |
| 上表都没覆盖的新情况 | 先回到本文件新增一行「情况 → 文档」，再补写那份文档 |

所有被引用的文档都放在项目根目录的 `docs/` 文件夹里（本文件已自动创建该目录）。

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

<!-- 待填写：写下「不做就一定出事」的规则，例如：禁止直接改生产配置、禁止绕过测试提交、禁止删除未跟踪文件。暂时没有就留空。 -->

（暂无）

## 5. 维护本文件

- 修改本项目约定时，**改 `docs/` 下的正文**，本文件只维护索引。
- 新增文档 = 在 `docs/` 建文件 + 在第 2 节表格加一行，两件事必须同时做完。
- `AGENTS.md` 与 `CLAUDE.md` 只是指针，**永远不要往里面写正文**。
MDEOF

# --------------------------------------------------------- docs/ skeletons ---
write_if_absent "$DOCS_DIR/architecture.md" <<'EOF'
# 架构与模块划分

> 状态：**待填充**（由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 生成的占位文档）

## 30 秒速览
- 一句话：<待填写>
- 入口：<待填写>

## 目录 / 模块地图
| 路径 | 职责 | 关键入口 |
| --- | --- | --- |
| <待填写> | <待填写> | <待填写> |

## 依赖关系
- 内部依赖方向：<待填写>
- 外部依赖：<待填写>

## 边界与约束
- <待填写：这个模块不能做什么>
EOF

write_if_absent "$DOCS_DIR/conventions.md" <<'EOF'
# 代码规范与目录约定

> 状态：**待填充**（由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 生成的占位文档）

## 硬性规则
- <待填写：命名、目录分层、禁止事项>

## 由工具强制的部分（不要手写，指向命令即可）
| 检查 | 命令 | 失败时 |
| --- | --- | --- |
| <待填写> | <待填写> | <待填写> |

## 提交约定
- 分支 / commit 风格：<待填写>
EOF

write_if_absent "$DOCS_DIR/development-workflow.md" <<'EOF'
# 开发流程：构建 / 运行 / 测试 / 发布

> 状态：**待填充**（由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 生成的占位文档）

| 动作 | 命令 | 前置条件 |
| --- | --- | --- |
| 安装依赖 | <待填写> | <待填写> |
| 本地启动 | <待填写> | <待填写> |
| 构建 | <待填写> | <待填写> |
| 快速自检 | <待填写> | <待填写> |
| 发布 | <待填写> | <待填写> |

## 本地环境要求
- 运行时 / 版本：<待填写>
- 需要的服务：<待填写>
EOF

write_if_absent "$DOCS_DIR/testing.md" <<'EOF'
# 测试策略与质量门禁

> 状态：**待填充**（由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 生成的占位文档）

- 测试放在哪里：<待填写>
- 怎么跑：<待填写>
- 覆盖率要求：<待填写>
- 什么改动必须补测试：<待填写>
- 允许被跳过的场景：<待填写>
EOF

write_if_absent "$DOCS_DIR/domain-model.md" <<'EOF'
# 领域模型与术语表

> 状态：**待填充**（由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 生成的占位文档）

| 术语 | 含义 | 代码里的名字 |
| --- | --- | --- |
| <待填写> | <待填写> | <待填写> |

## 核心概念关系
- <待填写>
EOF

write_if_absent "$DOCS_DIR/operations.md" <<'EOF'
# 配置、部署与运维

> 状态：**待填充**（由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 生成的占位文档）

## 环境变量
| 变量 | 作用 | 是否必需 | 默认值 |
| --- | --- | --- | --- |
| <待填写> | <待填写> | <待填写> | <待填写> |

## 部署
- 环境：<待填写>
- 发布步骤：<待填写>
- 回滚：<待填写>

## 密钥与凭据
- <待填写：只写「去哪里取、怎么注入」，绝不写真实值>
EOF

write_if_absent "$DOCS_DIR/troubleshooting.md" <<'EOF'
# 疑难排查与历史踩坑

> 状态：**待填充**（由 `agent-docs` 插件的 `hooks/ensure_agent_docs.sh` 生成的占位文档）

## 常见问题
### <症状>
- 原因：<待填写>
- 排查：<待填写>
- 修复：<待填写>

## 历史教训
- <待填写：踩过一次的坑就记在这里，避免重复踩>
EOF

[ "$created_any" -eq 0 ] && exit 0

# Tell the agent the scaffold exists and how to maintain it.
cat <<EOF
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"[project-init] 检测到项目根目录 ${root} 之前没有 ${POINTER_TARGET}，已自动生成 ${POINTER_TARGET} / AGENTS.md / CLAUDE.md 以及 docs/ 下的 7 份占位文档。当前项目**还没有真正的入口提示词**：请在本次工作中按 ${POINTER_TARGET} 中的「渐进式披露原则」把基础说明填成真实内容，把确实复用得到的知识写进 docs/ 并在索引表格里加行，不要一次性倾倒全部上下文，也不要往 AGENTS.md / CLAUDE.md 写正文。"}}
EOF
