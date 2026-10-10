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

### SKILL.md
- 路径固定为 `plugins/edu/skills/<skill-name>/SKILL.md`。
- 目录名小写、连字符分隔（如 `css-animations`、`smart-search`）。
- 文件必须以 YAML frontmatter 开头，至少含 `name` 与 `description`。
- `description` 决定 Claude Code 何时自动选中该 skill，**必须**写清触发场景。

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

提交前跑一次；改动 manifest / marketplace / SKILL.md 后必跑。本仓库暂无 GitHub Actions 自动执行。


## 提交约定
- 分支 / commit 风格：Conventional Commits（`feat:`、`fix:`、`docs:`、`refactor:`、`chore:`）。
- 新增文档 = 在 `docs/` 建文件 + 在 `_AGENTS.md` 第 2 节表格加一行，两件事必须同时做完。

## 新增一个 skill 的步骤
1. `mkdir -p plugins/edu/skills/<skill-name>`
2. 按上面的模板创建 `SKILL.md`
3. 按需添加 `references/`、`templates/`、`themes/`
4. 确认 `description` 写清了触发条件
5. 若新增了插件目录，补一份 `.codex-plugin/plugin.json`（字段照抄 `.claude-plugin` 那份再加 `interface`）
6. 跑 `bash scripts/check.sh`，必须 `exit 0`
7. 在 Claude Code 里用 `/<skill-name>` 验证（Codex 里直接点名该 skill）
