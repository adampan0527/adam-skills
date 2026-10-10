# 代码规范与目录约定

> 内容来源：原仓库根目录 `CLAUDE.md`（已于 2026-10-10 迁移，本文件为唯一副本）。

## 硬性规则

### 插件系统文件
本仓库同时服务 Claude Code 与 Codex，两边的清单**都要有**，且关键字段必须一致。

- `.claude-plugin/marketplace.json` — 市场索引，列出所有插件及其 `source` 路径。**禁止**包含 `$schema`。
- `plugins/<plugin>/.claude-plugin/plugin.json` — Claude Code 侧的单插件清单。**禁止**包含 `$schema`。
- `plugins/<plugin>/.codex-plugin/plugin.json` — Codex 侧的单插件清单，额外带 `interface` 展示字段与显式 `skills` / `hooks` 路径。**禁止**包含 `$schema`。
- 两份清单的 `name` / `version` / `description` **必须逐字一致**（由 `scripts/check.sh` 校验）；marketplace 条目的 `version` 也必须等于清单里的 `version`。
- skill 必须放在 `plugins/<plugin>/skills/<name>/SKILL.md` 才能被插件系统识别。

Codex 读取 manifest 的优先级是 `.codex-plugin/plugin.json` → `.claude-plugin/plugin.json` → `.cursor-plugin/plugin.json`。只写 `.claude-plugin` 也能装上，但插件商店页会缺展示信息。

### 插件按领域划分
**一个插件 = 一个领域**，插件名就是领域名，不做杂项集合。

- `edu` — 教育 / 教学领域。**所有教学相关的 skill 都放这里**，包括以后新增的。
- `agent-docs` — Agent 工程化（文档脚手架）。
- 新领域（如视频、搜索、CLI）→ **另开一个插件**，不要塞进现有的。

判断标准：新 skill 的**目标用户场景**和现有插件一致就放进去；不一致就开新插件。
`marketplace.json` 的 `category` 用可读领域名（`Education` / `Developer Tools`），
而 `.codex-plugin` 的 `interface.category` 保持一致。

### SKILL.md
- 路径固定为 `plugins/<plugin>/skills/<skill-name>/SKILL.md`（`<plugin>` 是所属领域插件）。
- 目录名小写、连字符分隔（如 `css-animations`、`smart-search`）。
- 文件必须以 YAML frontmatter 开头，至少含 `name` 与 `description`。
- `description` 决定两个 harness 何时自动选中该 skill，**必须**写清触发场景。
- `description` 只写「做什么 + 什么时候用」，**不要**把执行流程写进去——两个 harness
  每次会话都会注入这个字段，流程属于正文。控制在 300 字节以内。

### 目录约定
- 避免单文件子目录；参考文档保持扁平（如 `references/CHAPTER-EXAMPLES.md`，而不是 `references/EXAMPLES/README.md`）。

### SKILL.md 模板
```markdown
---
name: skill-name
description: 这个 skill 做什么，以及什么时候该用它。
---

# Skill Name

[Instructions for the skill go here.]
```

## 由工具强制的部分

本仓库没有 CI、没有 `package.json`、没有 linter，但有一个人工可跑的校验脚本：

```bash
bash scripts/check.sh
```

它用纯 bash + POSIX 工具（`find` / `grep` / `sed` / `awk`，无需 node、jq、python）强制以下红线，失败时逐条打印 `FAIL: <规则> <路径>` 并 `exit 1`：

| 规则 | 检查内容 |
| --- | --- |
| `no-$schema` | 任何 manifest 里都不出现 `$schema` |
| `marketplace-source` / `marketplace-name` | marketplace 每条都有 name，且 `source` 指向真实目录 |
| `claude-manifest-present` / `codex-manifest-present` | 每个插件两份清单都在 |
| `manifest-parity:<field>` | 两份清单的 `name` / `version` / `description` 一致 |
| `version-parity` | marketplace 条目 version == 清单 version |
| `skill-frontmatter-open` / `-name` / `-description` | 每个 SKILL.md 以 `---` 开头且含 name、description |

提交前跑一次；改动 manifest / marketplace / SKILL.md 后必跑。

GitHub Actions（`.github/workflows/check.yml`）在 push 到 `main`、任意 PR 以及手动触发时都会自动跑同一条命令，所以本地漏跑不会漏到远端。


## 提交约定
- 分支 / commit 风格：Conventional Commits（`feat:`、`fix:`、`docs:`、`refactor:`、`chore:`）。
- 新增文档 = 在 `docs/` 建文件 + 在 `_AGENTS.md` 第 2 节表格加一行，两件事必须同时做完。

## 新增一个 skill 的步骤
1. 判断领域：和现有插件一致 → 2a；不一致 → 2b。
2. **a. 加进已有插件**：`mkdir -p plugins/<plugin>/skills/<skill-name>`
2. **b. 开新领域插件**：见下方「新增一个插件的步骤」。
3. 按 SKILL.md 模板创建文件
4. 按需添加 `references/`、`templates/`、`themes/`
5. 确认 `description` 写清了触发条件，且不含执行流程
6. 跑 `bash scripts/check.sh`，必须 `exit 0`
7. 在 Claude Code 里用 `/<skill-name>` 验证（Codex 里直接点名该 skill）

## 新增一个插件的步骤
1. `mkdir -p plugins/<plugin>/.claude-plugin plugins/<plugin>/.codex-plugin plugins/<plugin>/skills`
2. 写 `.claude-plugin/plugin.json`：`name` / `version` / `description`
3. 写 `.codex-plugin/plugin.json`：字段照抄上面那份（**逐字一致**），再加 `interface`
   展示块与显式 `skills` / `hooks` 路径
4. 在 `.claude-plugin/marketplace.json` 的 `plugins` 数组里加条目：`name` / `version` /
   `description` / `source: "./plugins/<plugin>"` / `category`
5. 跑 `bash scripts/check.sh`，必须 `exit 0`（它会校验两份清单一致性、marketplace 条目
   与版本对齐、以及两份清单都存在）

> 已发布的插件名不要随意改：`edu@adam-skills` 之类的安装串已经写进了别人的文档和脚本，
> 改插件名等于破坏这些安装。确需改名时，先在 marketplace 里保留一个指向新 source 的
> 旧条目过渡一个版本。
