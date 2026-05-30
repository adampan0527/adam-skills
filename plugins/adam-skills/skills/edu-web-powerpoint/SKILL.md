---
name: edu-web-powerpoint
description: 给定教案 PDF / Word 文档 或 知识点 + 大纲，生成教学用点击驱动 16:9 网页演示（web-ppt）。流程：文档 → markitdown 预处理 → knowledge.md → 一次产出教学 script + outline 开发计划 → 用户一次对齐 5 件事（内容 / outline / 主题 / 案例选择 / 开发模式）→ 网页开发（逐章 / 顺序 / 并行）→ 实操案例文件夹发放。大纲中的案例分为两类：嵌入 web-ppt 的演示案例 + 独立文件夹的实操练习。若大纲无案例，ewp 自动生成。本 Skill 沉淀的是教学演示的设计方法论 + 协作流程，不绑定特定样式 / 字体 / 颜色。
---

# Edu Web PowerPoint (ewp)

给定知识点 + 大纲，一步步生成教学用的"看起来像视频"的点击驱动
16:9 网页演示（web-ppt），含实操案例文件夹。产出物 = Vite + React +
TS 项目 + 实操案例文件夹。

## 适用场景

- "我有一个教案 PDF，帮我做成课堂演示"
- "我有知识点 + 大纲，帮我做成 web-ppt"
- 教学课件、培训材料、技术分享
- 16:9 横屏演示，大字、留白、每屏有动效
- 需要配套实操练习的教学场景

本 Skill **以方法论 + 协作流程为核心**。脚手架模板提供 token 和原语，
但每个美学决策（配色、字型、动效气质）都应该针对你的主题重新设计。

---

## 工作流总览

```
Phase 0   文档预处理（可选）
   0.1  若用户输入为 PDF / Word 等文档 → 用 markitdown 转成 markdown
   0.2  整理成 knowledge.md
   ▼
Phase 1   内容编写
   1.1  识别用户输入（知识点 + 大纲）
   1.2  一次产出 teach-script.md + outline.md
        （教学文案 + 开发计划 + 案例清单）
   ▼
[Checkpoint Plan]      ← 硬节点 ① 案例选定（用户必须明确确认）
                         硬节点 ② 主题 / 内容 / 开发模式对齐
   ▼
Phase 2   网页开发
   2.1  脚手架（按选定主题）
   2.2  第 1 章 = 主线程 + 完整版本（强制 anchor）
        ▼
        [硬节点] 用户验收第 1 章 ← 不可跳过
        ▼
   2.3  第 2~N 章（按选定模式：A 逐章 / B 顺序 / C 并行）
   ▼
Phase 3   实操案例文件夹生成（按 Checkpoint ① 选定的案例）
   ▼
Phase 4   交付
```

工作目录约定（agent 在用户当前目录下创建 / 编辑）：

```
my-lesson/
├── 教案.pdf            # 原始教案（可选，用户传入的 PDF / Word）
├── knowledge.md        # 知识点原文（用户给 或 从文档转换 + agent 整理）
├── teach-script.md     # 必有：教学文案（决定节拍）
├── outline.md          # 必有：开发计划（章节切分 + 每步内容 + 信息池 + 案例清单）
├── presentation/       # 脚手架产出的 Vite + React + TS 项目
│   ├── src/chapters/<NN>-<id>/
│   │   ├── <Chapter>.tsx     # 视觉实现
│   │   ├── <Chapter>.css
│   │   └── narrations.ts     # ★ step 数 + 每步教学文本的唯一真相源
│   └── ...
└── case-exercise/      # 实操案例文件夹（独立发放给学生）
    ├── README.md       # 操作说明
    ├── main.html       # 或 main.py / index.js（案例入口）
    └── ...             # 案例所需资源
```

> **关键**：`narrations.ts` 是 step 数的**唯一真相源**。
> 章节 `.tsx` 里的 `if (step === N)` 出现的最大 N + 1 必须等于
> `narrations.length`。这保证 4 处地方（teach-script / outline / 章节代码 /
> chapters.ts）永远不会漂。

---

## 案例管理系统

大纲中通常包含若干个案例。ewp 对案例的处理分两种：

| 案例类型 | 说明 | 去向 |
|---|---|---|
| **演示案例** | 适合在 web-ppt 中展示的案例 | 做进 web-ppt 对应章节 |
| **实操案例** | 适合学生动手练习的案例 | 放入 `case-exercise/` 文件夹 |

**实操案例的选择标准**：
- 可以用纯本地文件运行（HTML / Python / JS 等）
- 学生能独立完成，不需要额外服务
- 有明确的输入 → 输出，方便验证结果
- 难度适中，5~15 分钟可完成

**若大纲中没有案例**：ewp 必须设立专门的案例生成步骤，根据知识点
自动创建 2~4 个案例，再走正常的选择流程。

详见 [`references/CASES.md`](references/CASES.md)。

---

## 硬性自检协议（贯穿整个 Skill）

下面三个产出，每一个**完成后必须走自检 → 修复 → 再汇报 / 推进**：

| 产出 | 自检清单出处 |
|---|---|
| `teach-script.md` | [`SCRIPT-STYLE.md`](references/SCRIPT-STYLE.md) 三层自检 |
| `outline.md` | [`OUTLINE-FORMAT.md`](references/OUTLINE-FORMAT.md) 自检 |
| 单章实现完成 | [`CHAPTER-CRAFT.md`](references/CHAPTER-CRAFT.md) 完工自检 |

**执行方式**（按能力降级，**优先用更隔离的方式**）：

1. **Agent Teams（最优）**：开一个独立的 reviewer agent。
2. **subAgent（次优）**：用 subagent 走同样流程。
3. **自检（兜底）**：自己严格逐项核查。

**铁律**：拿到结论后**先按 fail 项把产出改完**，再向用户汇报。

---

## 各阶段文件读取指南

| 阶段 | 必读（每次都看） | 一次性看完 / 按需查 |
|---|---|---|
| **Phase 0 文档预处理** | `references/INPUT-PREPROCESSING.md` | —— |
| Phase 1.1-1.2 内容编写 | `references/SCRIPT-STYLE.md` + `references/OUTLINE-FORMAT.md` + `knowledge.md` | —— |
| **Checkpoint Plan 选主题** | —— | `themes/*/theme.json`（动态读全部）；`references/THEMES.md` |
| Phase 2.1 脚手架 | —— | SKILL.md 本节看一次 |
| **Phase 2.4 实现单章** | **`references/CHAPTER-CRAFT.md`** 单一入口 + 当前主题 `theme.json` + outline.md 段落 + knowledge.md 对应段落 | `references/EXAMPLES/`；`references/THEMES.md` |
| Phase 3 实操案例 | `references/CASES.md` | —— |

---

## Phase 0 —— 文档预处理（当用户输入为教案文档时）

教案（教案 PDF、Word 文档等）是教学场景最常见的输入形式。
当用户提供的不是 markdown 文本而是文档文件时，必须先走预处理流程。

详细步骤见 [`references/INPUT-PREPROCESSING.md`](references/INPUT-PREPROCESSING.md)。

**简要流程**：

1. **安装 markitdown**（若未安装）：`pip install markitdown`
2. **转换文档**：`markitdown 教案.pdf -o 教案.md`（支持 PDF / Word / PPT 等）
3. **整理成 knowledge.md**：agent 阅读转换结果，整理成结构化的知识点文档
4. **进入 Phase 1**

> **关键**：markitdown 转出的 markdown 可能有格式瑕疵（表格错位、图片丢失等），
> agent 必须人工审查并修正后再进入 Phase 1。

---

## Phase 1 —— 内容编写（一次产出）

### 1.1 识别用户输入

| 用户给的东西 | 该做的 |
|---|---|
| 教案 PDF / Word 文档 | **Phase 0**：markitdown 转换 → 整理成 knowledge.md → 进 Phase 1.2 |
| 知识点 + 完整大纲 | 一次产出 `teach-script.md` + `outline.md`（1.2），过 Checkpoint Plan |
| 只有知识点，没有大纲 | **反问**：让用户提供大纲，或 agent 根据知识点生成大纲草案后确认 |
| 只有大纲 | 确认知识点范围，一次产出（1.2） |

### 1.2 一次产出 teach-script.md + outline.md

**两份产出物在一次思考中完成**：

1. **生成 `teach-script.md`**：按 [`references/SCRIPT-STYLE.md`](references/SCRIPT-STYLE.md)
   的规则把知识点 + 大纲转成教学文案。保持专业但易懂。
2. **生成 `outline.md`**：按 [`references/OUTLINE-FORMAT.md`](references/OUTLINE-FORMAT.md)
   规则切章节 + 切 step + 每章首段抽**信息池** + **案例清单**。

**outline 的边界**（关键）：

| outline 必须写 | outline 不要写 |
|---|---|
| 章节切分 / 每章 step 数 / 估时 | 具体动画类型 |
| 每步屏幕内容（hero / 数据 / 标语 / 列表项） | CSS 实现手段 |
| 章节级**信息池** | 时长数值 |
| **案例清单**（每个案例：名称 / 类型 / 简述 / 推荐去向） | 持续微动 / 错峰量 |

**案例生成逻辑**：

- 大纲中有案例 → 提取并整理到 outline 末尾「案例清单」
- 大纲中无案例 → agent 根据知识点**自动生成 2~4 个案例**，写入案例清单
- 每个案例标注：`[演示]` 或 `[实操推荐]`
- agent 给出**推荐方案**：哪个做实操，哪些做演示，**并说明理由**

**落盘后必须先走自检再进 Checkpoint Plan**。

---

## Checkpoint Plan —— 案例选定 + 内容对齐（**硬节点**）

`teach-script.md` + `outline.md` 写完后必须停下来。

案例是**整场教学级别**的决策，不是某一章的事。选定哪个做实操、哪些做演示，
直接影响 Phase 2 的章节结构和 Phase 3 的产出。因此**案例选定是独立的硬节点**，
用户必须明确确认后才能继续。

### agent 此时要做的预备工作

1. 读所有 `themes/*/theme.json` 拿 `nameZh` / `descriptionZh` / `bestFor` / `mood`
2. 根据内容类型 / 关键词 / 语气，**主动**从主题里挑 2~3 套推荐
3. 扫一遍 `outline.md` 末尾「案例清单」部分
4. 对案例清单给出推荐方案

### 总结模板（骨架）

```
内容计划写完，产出文件：
  📄 knowledge.md    {知识点概要}
  📄 teach-script.md  {X} 字
  📄 outline.md       {N} 章 / {M} 步 + 每章信息池 + 案例清单

章节速览：
  1. <id>     <章节标题>    <S> 步
  2. ...
```

### 硬节点 ①：案例选定（**必须用户明确确认**）

Agent 列出所有案例，给出推荐，**等用户回复后才能继续**。

```
═══ 案例清单（整场教学）═══

  #  名称                    类型          简述
  1  冒泡排序可视化           [实操推荐]     学生输入数组，观察排序过程
  2  排序算法对比动画         [演示]         展示不同排序算法速度差异
  3  时间复杂度计算器         [演示]         输入代码片段，分析复杂度
  4  二分查找互动练习         [演示]         在有序数组中查找目标值

  ★ 推荐案例 1「冒泡排序可视化」作为实操练习：
    - 可以纯 HTML + JS 本地运行
    - 步骤清晰：填数据 → 点排序 → 观察过程
    - 有明确验证：排序结果是否正确
    - 难度适中：约 10 分钟
    - 直接练习本节核心算法

  其余案例（2/3/4）嵌入 web-ppt 对应章节做课堂演示。

  ▸ 你同意案例 1 做实操吗？还是选别的？
  ▸ 演示案例（2/3/4）确认 OK？
```

**铁律**：用户没有明确回复之前，不得进入下一步。

### 硬节点 ②：主题 + 开发模式

案例确认后，继续对齐剩余事项：

```
接下来对齐 3 件事：

  1. 教学文案 (teach-script.md) 要不要改？

  2. 开发计划 (outline.md) 要不要改？
     （案例分配已确认，如需调整章节结构现在改）

  3. 选哪个主题？我的推荐：
     ★ <推荐 1> — 因为 <bestFor 命中>
     ★ <推荐 2 / 推荐 3>

  4. 开发模式选哪个？
     A) 默认 · 逐章确认（推荐）
     B) 第 1 章后顺序开发
     C) 第 1 章后并行开发（subagent）
```

---

## Phase 2 —— 网页开发

### 2.1 脚手架

```bash
bash <path-to-edu-web-powerpoint>/scripts/scaffold.sh \
  ./presentation \
  --theme=<用户选的主题 id>
```

脚手架带一个 `01-example` demo。在写第一章真实内容前**删掉**：

```bash
rm -rf presentation/src/chapters/01-example
```

并把 `presentation/src/registry/chapters.ts` 里的 import 和数组项移除。

### 2.2 第 1 章 —— 主线程 + 强制验收

**核心**：第 1 章 = 完整版本一次到位。

**做完第 1 章后必须停下来**等用户验收：

```
第 1 章 <id> 做完了，dev server 在 localhost:5173 运行。

验收重点：
  □ 视觉气质对不对？
  □ 节奏对不对？
  □ 内容驱动动画是否到位？
  □ 双源原则：画面有没有"教学文案没提但知识点里有"的细节？
  □ 反 AI 味检查
```

### 2.3 第 2~N 章 —— 按选定模式

三模式同 web-video-presentation（A 逐章 / B 顺序 / C 并行）。

### 2.4 实现单章

详细指引见 [`references/CHAPTER-CRAFT.md`](references/CHAPTER-CRAFT.md)。

**核心要点**：
- **每章必须有 CSS / SVG / Canvas / JS 视觉演示**
- **逐步揭示**：清单 / 列表必须 1 项 = 1 step
- **双源原则**：节奏跟 teach-script，细节回 knowledge.md 抽
- **完工自检逐项过**

### 2.5 大改后 bump STORAGE_KEY

改动 `chapters.ts` 后 bump `useStepper.ts` 的 `STORAGE_KEY`。

---

## Phase 3 —— 实操案例文件夹生成

选定的实操案例 → 生成到 `case-exercise/` 文件夹：

```
case-exercise/
├── README.md          # 操作说明（目标 / 步骤 / 预期结果）
├── main.html          # 案例入口（或 main.py / index.js）
└── ...                # 案例所需资源
```

**`README.md` 必须包含**：
- 学习目标（这个案例让学生练习什么）
- 操作步骤（分步骤，每步有说明）
- 预期结果（做对了应该看到什么）
- 思考题（1~2 个引导学生深入思考的问题）

**案例质量标准**：
- 可以纯本地运行（不需要服务器 / 数据库 / 外部 API）
- 步骤清晰，学生能独立完成
- 有明确的输入 → 输出
- 难度适中（5~15 分钟）

详见 [`references/CASES.md`](references/CASES.md)。

---

## Phase 4 —— 交付

```
全部完成。产出：
  📄 teach-script.md    教学文案
  📄 outline.md         开发计划
  📁 presentation/      web-ppt（npm run dev 预览）
  📁 case-exercise/     实操案例文件夹（直接发给学生）

presentation 运行在 localhost:5173。
case-exercise/ 可以打包发给学生。
```

---

## 十条原则（一句话清单）

完整展开见 [`references/CHAPTER-CRAFT.md`](references/CHAPTER-CRAFT.md)。

| # | 原则 | 一句话 |
|---|---|---|
| 1 | 16:9 固定舞台 | 内容 1920×1080 + transform scale |
| 2 | 全局 step 计数器 | 章节是 step 的纯函数，无定时器 |
| 3 | 每步独占整屏 | `if (step === N) return <FullScene />` |
| 4 | 教学节拍 = step | 一节拍 = 一 step = 一聚焦想法 |
| 5 | 隐藏的边角控件 | 进度条 / 翻页器默认 opacity 0 |
| 6 | 舞台无 chrome | 没有 header / footer / 页码 |
| 7 | **内容驱动动画** | 先找内在动作，找不到才入场动画兜底 |
| 8 | 多点逐个揭示 | 1 项 = 1 step，禁同步 stagger |
| 9 | 整片同一主题 | 颜色 / 字体走 token |
| 10 | 双源原则 | teach-script 定节拍，knowledge.md 定画面密度 |

---

## 相关资源

| 文件 | 何时读 | 内容 |
|---|---|---|
| [`references/INPUT-PREPROCESSING.md`](references/INPUT-PREPROCESSING.md) | **Phase 0 必读** | PDF / Word 教案 → markdown 预处理流程 |
| [`references/SCRIPT-STYLE.md`](references/SCRIPT-STYLE.md) | Phase 1.2 必读 | 知识点 → 教学文案规则 |
| [`references/OUTLINE-FORMAT.md`](references/OUTLINE-FORMAT.md) | Phase 1.2 必读 | outline.md 字段 spec + 案例清单格式 |
| [`references/CASES.md`](references/CASES.md) | Phase 1.2 + Phase 3 | 案例系统完整规范 |
| [`references/CHAPTER-CRAFT.md`](references/CHAPTER-CRAFT.md) | **Phase 2.4 每章必读** | 视觉演示 + 逐步揭示 + 反 AI 味 + 代码红线 + 完工自检 |
| [`references/THEMES.md`](references/THEMES.md) | 选 / 造主题时 | 完整 token 契约 + 主题清单 |
| [`themes/`](themes) | Checkpoint Plan 时翻 | 内置主题 |
| [`scripts/scaffold.sh`](scripts/scaffold.sh) | Phase 2.1 跑一次 | 一键项目脚手架 |
