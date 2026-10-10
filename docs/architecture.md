# 架构与模块划分

> 内容来源：原仓库根目录 `CLAUDE.md`（已于 2026-10-10 迁移，本文件为唯一副本）。

## 30 秒速览
- 一句话：这是一个 Claude Code / Codex 插件市场仓库，把个人 skill 打包成插件分发，通过 `/plugin marketplace add` 安装。
- 入口：`.claude-plugin/marketplace.json`（市场目录）

## 目录 / 模块地图
```
adam-skills/
├── .claude-plugin/
│   └── marketplace.json         # 市场目录（/plugin 必需）
├── plugins/
│   ├── agent-docs/              # 项目文档脚手架插件
│   │   ├── .claude-plugin/plugin.json   # Claude Code 清单
│   │   ├── .codex-plugin/plugin.json    # Codex 清单（含 interface）
│   │   ├── hooks/               # SessionStart 钩子
│   │   └── LICENSE, README.md
│   └── edu/                     # 教育领域插件（教学相关 skill 都放这里）
│       ├── .claude-plugin/plugin.json   # 插件清单（必需，不带 $schema）
│       ├── .codex-plugin/plugin.json    # Codex 清单（必需）
│       └── skills/
│           └── <skill-name>/
│               ├── SKILL.md            # 带 YAML frontmatter 的技能定义
│               ├── references/         # SKILL.md 按需加载的参考文档
│               ├── templates/          # 脚手架（HTML/TSX/CSS/配置）
│               └── themes/             # 主题 token（JSON + CSS）
├── scripts/
│   └── check.sh                 # 纯 bash 校验脚本（manifest / SKILL.md 规则）
├── .github/workflows/check.yml  # CI：push / PR 自动跑 scripts/check.sh
├── docs/                        # 索引只指向填实了的文档；其余按需创建，不占位
├── _AGENTS.md                   # 唯一 Agent 提示词内容源
├── AGENTS.md / CLAUDE.md        # 纯指针
└── README.md / README_CN.md / LICENSE
```

### 插件按领域划分

一个插件对应一个领域，插件名即领域名；领域不符就另开插件，不做杂项集合。

| 插件 | 领域 | 装什么 |
| --- | --- | --- |
| `edu` | 教育 / 教学 | 所有教学相关 skill（当前：`edu-web-powerpoint`） |
| `dev` | 开发工具 | 开发工具类 skill（当前：`lr-harness`） |
| `agent-docs` | Agent 工程化 | 项目文档脚手架（含 SessionStart hook） |

| 路径 | 职责 | 关键入口 |
| --- | --- | --- |
| `.claude-plugin/marketplace.json` | 市场目录，列出所有插件及其 `source`；Codex 也直接读这一份 | 市场目录 |
| `plugins/<name>/.claude-plugin/plugin.json` | Claude Code 侧单插件清单（name/version/description） | 插件清单 |
| `plugins/<name>/.codex-plugin/plugin.json` | Codex 侧单插件清单，多 `interface` 展示字段，显式 `skills`/`hooks` | 插件清单 |
| `plugins/<name>/skills/<skill>/SKILL.md` | 技能定义，两边 harness 均按 `description` 自动选择 | SKILL.md |
| `plugins/agent-docs/hooks/ensure_agent_docs.sh` | 会话开始时检测并生成文档骨架 | SessionStart 钩子 |
| `scripts/check.sh` | 提交前跑，强制 manifest 与 SKILL.md 的硬性红线 | 校验 |

## 依赖关系
- 内部依赖方向：市场目录 → 两份插件清单 → skills，单向下游，插件之间不互相引用。
- 两个 harness 的关系：Claude Code 只读 `.claude-plugin/*`；Codex 按 `.codex-plugin` → `.claude-plugin` → `.cursor-plugin` 的顺序取**第一份存在的**清单。市场目录两边共用 `.claude-plugin/marketplace.json` 一份。
- 外部依赖：除 Claude Code / Codex 插件系统外无运行时依赖；仓库根目录无 `package.json`。
- 平台：macOS / Linux / Windows 通用。Windows 需 Git Bash（两个 harness 本身已依赖）；hook 会把
  harness 传来的 `C:\...` 路径归一化为 MSYS 形式再使用。

## 边界与约束
- 本仓库只存放「可分发的插件/skill 资产」，不放构建产物、依赖目录。
- **已发布的插件名视为对外 API**：`edu@adam-skills` 这类安装串已经进了别人的文档与脚本，改名等于破坏它们。确需改名时先在 marketplace 保留旧条目过渡一个版本。
- `edu-web-powerpoint` 的 `templates/` 与 `themes/` 是**要复制给终端用户的脚手架**，不是本仓库自己的代码，不应在本仓库内构建或改动其依赖。
