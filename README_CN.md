# Adam's Skills — 个人技能库

[English](README.md) | 中文

一个用于 [Claude Code](https://claude.ai/code) 的个人技能库，以插件形式发布。每个 skill 是一个 `SKILL.md` 文件，通过 `/<skill-name>` 触发，为 Claude 注入特定领域的专业知识和工作流。

## 安装

**Step 1 — 添加市场源（只需执行一次）：**

在 Claude Code 中运行：

```
/plugin marketplace add adampan0527/adam-skills
```

**Step 2 — 安装插件：**

```
/plugin install edu@adam-skills
```

**Step 3 — 重启 Claude Code 使插件生效。**

安装完成后，所有 skill 会自动注册为斜杠命令，直接输入 `/<skill-name>` 即可使用。

### 其他插件命令

```bash
# 更新到最新版本
/plugin update edu@adam-skills

# 查看已安装插件
/plugin list

# 查看插件详情
/plugin details edu@adam-skills
```

---

## 当前 Skill 列表

| Skill | 命令 | 说明 |
|-------|------|------|
| Edu Web PowerPoint | `/edu-web-powerpoint` | 给定教案 PDF/Word 或知识点大纲，生成教学用 16:9 网页演示（web-ppt），含实操案例 |

---

## Skill 详细介绍

### `/edu-web-powerpoint`

从教案文档（PDF / Word）或知识点 + 大纲出发，生成教学用"看起来像视频"的点击驱动 16:9 网页演示。

**适用场景：**
- "我有一个教案 PDF，帮我做成课堂演示"
- "我有知识点 + 大纲，帮我做成 web-ppt"
- 教学课件、培训材料、技术分享
- 16:9 横屏演示，大字、留白、每屏有动效
- 需要配套实操练习的教学场景

**使用方式：**

1. 进入一个空目录（或让 Claude 创建）
2. 直接输入 `/edu-web-powerpoint`，然后描述你的需求：
   - 给出教案 PDF 路径，或
   - 给出知识点 + 大纲文本
3. 按提示与 Claude 逐步对齐内容、大纲、主题风格，然后开始生成

---

## 给开发者：添加新 Skill

如果你想 fork 这个仓库来创建自己的 skill：

### 1. 创建 skill 目录

```bash
mkdir -p plugins/edu/skills/<skill-name>
```

### 2. 编写 SKILL.md

```markdown
---
name: skill-name
description: 一句话说明这个 skill 做什么、什么时候触发。
---

# Skill 名称

[具体指令、模式、参考材料……]
```

### 3. 规范

- **一个 skill，一个领域** — 每个 skill 只解决一类问题
- **命名规范** — 全小写，用连字符分隔，如 `css-animations`、`smart-search`
- **description 很重要** — Claude 根据这个字段判断何时自动选中该 skill
- **自包含** — skill 会被独立展开到对话中，所有必要上下文都要写进去

### 4. 测试

在 Claude Code 中输入 `/<skill-name>` 测试效果。

---

## License

[MIT](LICENSE) &copy; Yan Pan
