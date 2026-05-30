# Adam's Skills — 个人技能库

[English](README.md) | 中文

一个用于 [Claude Code](https://claude.ai/code) 的个人技能库，以插件市场形式打包。每个技能是一个独立的 `SKILL.md` 文件，提供特定领域的指令，可通过斜杠命令在 Claude Code 会话中调用。

## 什么是技能（Skills）？

技能是 `SKILL.md` 格式的 Markdown 文件，在 Claude Code 中通过 `/<技能名>` 触发时，会被展开为完整的提示词注入到对话中。它们封装了可复用的模式、工作流和领域知识——涵盖从动画框架到 CLI 适配器再到搜索工具的方方面面。

## 仓库结构

```
adam-skills/
├── .claude-plugin/
│   └── marketplace.json         # 市场清单
├── plugins/
│   └── adam-skills/
│       ├── .claude-plugin/
│       │   └── plugin.json      # 插件清单
│       └── skills/
│           └── <技能名>/
│               └── SKILL.md     # 技能定义
├── skills/                      # 技能的开发副本
├── CLAUDE.md
├── LICENSE
├── README.md
└── README_CN.md
```

## 安装方式

### 通过 Claude Code 插件市场安装（推荐）

**第一步 — 添加市场源：**

```
/plugin marketplace add adampan0527/adam-skills
```

此命令会克隆仓库并将其注册为已知市场。

**第二步 — 安装插件：**

```
/plugin install adam-skills@adam-skills
```

Claude Code 读取 `.claude-plugin/marketplace.json`，找到插件条目，并注册 `plugins/adam-skills/skills/` 下的所有技能。

**第三步 — 使用技能：**

```
/<技能名>
```

#### 其他插件命令

```bash
# 更新到最新版本
/plugin update adam-skills@adam-skills

# 查看已安装的插件
/plugin list

# 查看插件详情
/plugin details adam-skills@adam-skills
```

### 手动安装

克隆仓库后，将所需的技能文件复制或软链接到 Claude Code 的技能目录：

```bash
git clone https://github.com/adampan0527/adam-skills.git
```

## 创建新技能

1. 创建技能目录：

   ```bash
   mkdir -p plugins/adam-skills/skills/<技能名>
   ```

2. 创建 `SKILL.md` 并添加必需的 frontmatter：

   ```markdown
   ---
   name: 技能名
   description: 简要描述该技能的使用场景和用途。
   ---

   # 技能名称

   [指令、模式和参考资料写在这里。]
   ```

3. 在 Claude Code 中输入 `/<技能名>` 进行测试。

### 编写规范

- **一个技能，一个领域** — 每个技能应聚焦于单一任务或模式。
- **小写加连字符命名** — 例如 `css-animations`、`smart-search`。
- **清晰的触发描述** — `description` 字段决定了 Claude Code 何时选择该技能。
- **内容自包含** — 技能会独立展开到对话中，需包含所有必要的上下文信息。

## 技能分类

| 分类           | 说明                                     |
| -------------- | ---------------------------------------- |
| `animation`    | 动画框架适配器（GSAP、Anime.js、CSS、WAAPI、Three.js） |
| `video`        | 视频合成与制作工作流                     |
| `dev-tools`    | CLI 适配器、开发工具                     |
| `search`       | 网络搜索与信息检索                       |

随着新技能的添加，分类将持续扩展。

## 许可证

[MIT](LICENSE) &copy; Yan Pan
