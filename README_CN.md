# Adam's Skills — 个人技能库

[English](README.md) | 中文

一个用于 [Claude Code](https://claude.ai/code) 的个人技能库。每个技能是一个独立的 Markdown 文件，提供特定领域的指令，可通过斜杠命令在 Claude Code 会话中调用。

## 什么是技能（Skills）？

技能是 `.md` 格式的 Markdown 文件，在 Claude Code 中通过 `/<技能名>` 触发时，会被展开为完整的提示词注入到对话中。它们封装了可复用的模式、工作流和领域知识——涵盖从动画框架到 CLI 适配器再到搜索工具的方方面面。

## 仓库结构

```
adam-skills/
├── CLAUDE.md            # Claude Code 项目指引
├── LICENSE              # MIT 许可证
├── README.md
├── README_CN.md         # 中文说明文档
└── skills/
    ├── <分类目录>/      # 例如 animation、dev-tools、search
    │   ├── 技能-a.md
    │   └── 技能-b.md
    └── ...
```

## 安装方式

### 通过 Claude Code 市场安装（推荐）

在 Claude Code 会话中使用 `/plugin` 命令直接安装：

```
/plugin install adampan0527/adam-skills
```

Claude Code 会自动拉取仓库并将 `skills/` 下的所有技能注册到当前环境。安装完成后即可通过斜杠命令立即使用。

更新到最新版本：

```
/plugin update adampan0527/adam-skills
```

查看已安装的插件：

```
/plugin list
```

### 通过命令行添加（CLI）

在命令行中将本仓库添加为技能源：

```bash
claude skill add https://github.com/adampan0527/adam-skills.git
```

### 手动安装

克隆仓库后，将所需的技能文件复制或软链接到 Claude Code 的技能目录：

```bash
git clone https://github.com/adampan0527/adam-skills.git
```

## 使用方法

安装完成后，在 Claude Code 会话中通过斜杠命令调用技能：

```
/<技能名>
```

例如，若 `skills/animation/` 下有一个名为 `gsap` 的技能：

```
/gsap
```

## 创建新技能

1. 在 `skills/` 下选择或创建分类目录：

   ```bash
   mkdir -p skills/<分类>
   ```

2. 创建新的 Markdown 文件：

   ```bash
   touch skills/<分类>/<技能名>.md
   ```

3. 添加必需的 frontmatter 元数据和正文内容：

   ```markdown
   ---
   name: 技能名
   description: 简要描述该技能的使用场景和用途。
   ---

   # 技能名称

   [指令、模式和参考资料写在这里。]
   ```

4. 在 Claude Code 中输入 `/<技能名>` 进行测试。

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
