# Edu Web PowerPoint (ewp) Skill

**给定知识点 + 大纲，生成教学用点击驱动 16:9 网页演示的 Agent Skill。含案例管理（演示案例 + 实操练习）。**

[English](./README.md)

---

## 这是什么？

`edu-web-powerpoint`（ewp）帮 Agent 构建一种 Vite + React + TypeScript 演示：为教学设计的网页演示。每次点击推进一个教学节拍，每一步独占 1920×1080 舞台，进度 UI 平时隐藏。

它适合：

- 把教案 PDF / Word 文档做成课堂演示
- 把知识点 + 大纲做成课堂演示
- 做培训材料、技术分享、课件
- 管理案例：演示案例做进 web-ppt，实操案例做成独立文件夹发给学生
- 做"动态 PPT，但不要像 PPT"的教学体验

这个 Skill 的核心是**方法论 + 协作流程**。脚手架提供 token、舞台原语、主题和示例，但每个项目仍然应该根据主题重新选择视觉语言。

---

## 核心理念

- **固定 16:9 舞台**：内容写在稳定的 1920×1080 坐标系里。
- **一个全局 step 游标**：点击或键盘推进 `(chapter, step)`。
- **一步一个想法**：每个节拍独占整屏。
- **教学节拍驱动结构**：讲述节奏直接映射为视觉 step。
- **隐藏 chrome**：进度控制悬浮才出现。
- **动效优先**：每一步都需要一个移动的视觉锚点。
- **主题 token**：视觉属性通过语义 token 驱动。
- **案例管理**：大纲中的案例分为演示案例和实操案例。
- **硬 checkpoint**：内容 / 主题 / 案例确认前必须停下来。

---

## 工作流

```text
Phase 0    文档预处理（可选）
           教案 PDF / Word → markitdown → markdown → knowledge.md
   |
Phase 1.1  识别用户输入（知识点 + 大纲）
Phase 1.2  一次产出 teach-script.md + outline.md
   |
Checkpoint Plan  内容 / outline / 主题 / 案例 / 开发模式
   |
Phase 2    构建 Vite / React / TS 演示
   |
Phase 3    生成实操案例文件夹
   |
Phase 4    交付
```

---

## 案例管理

大纲中的案例分两种：

| 类型 | 说明 | 去向 |
|---|---|---|
| **演示案例** | 适合在 web-ppt 中展示 | 做进 web-ppt 对应章节 |
| **实操案例** | 适合学生动手练习 | 放入 `case-exercise/` 文件夹 |

若大纲中没有案例，ewp 会根据知识点自动生成 2~4 个案例。

---

## 内含内容

```text
skills/edu-web-powerpoint/
├── SKILL.md
├── README.md / README.zh-CN.md
├── manifest.json
├── references/
│   ├── PRINCIPLES.md
│   ├── CHAPTER-CRAFT.md
│   ├── OUTLINE-FORMAT.md
│   ├── SCRIPT-STYLE.md
│   ├── INPUT-PREPROCESSING.md
│   ├── CASES.md
│   ├── THEMES.md
│   └── EXAMPLES/
├── scripts/
│   └── scaffold.sh
├── templates/
│   ├── index.html
│   ├── vite.config.ts
│   ├── case/              # 实操案例模板
│   │   └── README.md
│   └── src/
└── themes/                # 12 套教学主题
    ├── academic-blue/
    ├── chalkboard/
    ├── clean-lecture/
    └── ...
```

---

## 快速上手

把这个 Skill 复制到你的 Agent 会扫描的目录，然后让 Agent 把知识点 + 大纲做成教学 web-ppt。

手动脚手架：

```bash
bash skills/edu-web-powerpoint/scripts/scaffold.sh ./presentation --theme=academic-blue
```

查看可用主题：

```bash
bash skills/edu-web-powerpoint/scripts/scaffold.sh --list-themes
```

---

## 内置主题

12 套教学主题：

| id | 风格 | 适合 |
|---|---|---|
| `academic-blue` | 经典学术蓝 | 大学授课、正式培训 |
| `chalkboard` | 黑板粉笔 | 数学、物理、传统教学 |
| `clean-lecture` | 简洁白底 | 企业培训、技术分享 |
| `code-terminal` | 暗色终端绿 | 编程课程、计算机教育 |
| `geometric-bold` | 粗黑几何 | 设计课程、视觉教学 |
| `handwritten` | 暖色手写 | 非正式教学、辅导 |
| `ink-wash` | 水墨风 | 文学、历史、文化 |
| `light-board` | 光板蓝底 | 工程、建筑 |
| `magazine` | 编辑杂志 | 新闻、传媒 |
| `notebook` | 笔记本纸 | 学习笔记、复习 |
| `science-paper` | 学术论文 | 理科、研究展示 |
| `warm-education` | 暖色友好 | K-12、入门、软技能 |

---

## Reference Map

- [INPUT-PREPROCESSING.md](./references/INPUT-PREPROCESSING.md)：教案 PDF / Word 文档预处理流程（markitdown）
- [PRINCIPLES.md](./references/PRINCIPLES.md)：教学网页演示的核心原则
- [CHAPTER-CRAFT.md](./references/CHAPTER-CRAFT.md)：章节实现规则与视觉 checklist
- [OUTLINE-FORMAT.md](./references/OUTLINE-FORMAT.md)：outline 格式（含案例清单）
- [SCRIPT-STYLE.md](./references/SCRIPT-STYLE.md)：知识点转教学文案规则
- [CASES.md](./references/CASES.md)：案例管理系统
- [THEMES.md](./references/THEMES.md)：主题 token 契约与内置主题
