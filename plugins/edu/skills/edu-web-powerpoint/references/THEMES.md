# 主题系统

每个演示从头到尾跑**一个主题**。

主题 = 一组 CSS 设计 token + 一个 `theme.json` 元数据。

**章节对 token 的消费分两层**：

1. **必须用 token 的** —— 颜色 + 字体家族
2. **章节自由发挥的** —— 字号 / 间距 / 动画时长 / 缓动 / 边框宽度 / 圆角 / 字距

---

## 内置主题

12 套教学主题，每套都有**独立的设计 DNA**。

| id | 性格 | 适合场景 |
|---|---|---|
| `academic-blue` | 经典学术蓝。白底 + 深蓝 accent + 衬线标题。严谨、正式、可信赖。 | 大学授课、正式培训、学术报告 |
| `chalkboard` | 黑板粉笔风。深绿黑板 + 白粉笔字 + 手写体。传统教学的温暖感。 | 数学、物理、传统理科教学 |
| `clean-lecture` | 现代简洁白底。净白 + 单色 accent + 无衬线。干净、专业、不干扰。 | 企业培训、技术分享、产品介绍 |
| `code-terminal` | 暗色终端风。深黑 + 绿色等宽字 + 扫描线。程序员的课堂。 | 编程课程、CS 教育、技术教程 |
| `geometric-bold` | 粗黑几何。白底 + 黑色粗体 + 几何装饰。设计感强。 | 设计课程、视觉教学、创意分享 |
| `handwritten` | 暖色手写风。米纸 + 手写字 + 彩色标注。亲切、轻松。 | 非正式教学、辅导、少儿教育 |
| `ink-wash` | 水墨风。宣纸白 + 墨色 + 淡雅。东方美学。 | 文学、历史、文化、中文教学 |
| `light-board` | 光板蓝底。深蓝底 + 白色线稿 + 荧光色标注。工程感。 | 工程、建筑、物理、数学 |
| `magazine` | 编辑杂志风。奶油底 + 衬线标题 + 强对比。有格调。 | 新闻、传媒、社会科学 |
| `notebook` | 笔记本纸风。横线纸 + 手写标注 + 彩色便签。学习感。 | 学习笔记、复习、总结 |
| `science-paper` | 学术论文风。白底 + 细线 + 等宽标注。严谨、精确。 | 理科、研究展示、论文讲解 |
| `warm-education` | 暖色友好。柔暖底 + 圆角 + 柔和色彩。亲切、包容。 | K-12、入门教育、软技能 |

---

## 完整 token 契约

### 必填（主题必须定义）

#### 表面色（4 个）

| token | 作用 |
|---|---|
| `--shell` | 舞台外的页面背景 |
| `--surface` | 舞台主背景 |
| `--surface-2` | 凸起 —— 卡片、代码块 |
| `--surface-3` | 最里层 |

#### 文字（4 个）

| token | 作用 |
|---|---|
| `--text` | 主 |
| `--text-2` | 次 |
| `--text-mute` | 静音 —— 标签 / 元数据 |
| `--text-faint` | 三级 |

#### 线条（1 个）

| token | 作用 |
|---|---|
| `--rule` | 发丝分割线颜色 |

#### Accent（3 个）

| token | 作用 |
|---|---|
| `--accent` | accent 本体 |
| `--accent-soft` | 低透明度叠层 |
| `--accent-glow` | 中透明度叠层 |

#### 字型家族（4 个）

| token | 作用 |
|---|---|
| `--font-display-cn` | 中文显示家族 |
| `--font-display-en` | 拉丁显示家族 |
| `--font-body` | 正文家族 |
| `--font-mono` | 等宽家族 |

### 可选的性格覆盖

| token | base 默认 | 作用 |
|---|---|---|
| `--font-features` | `"tnum","ss01"` | OpenType 特性 |
| `--r-card` | `--r-md` | 卡片圆角 |
| `--r-stage` | `0` | 舞台圆角 |
| `--rule-w` | `1px` | rule 粗细 |
| `--rule-style` | `solid` | rule 样式 |
| `--hero-num-font` | `--font-display-en` | hero 数字字体 |
| `--hero-num-style` | `italic` | hero 数字风格 |
| `--hero-num-weight` | `400` | hero 数字字重 |
| `--hero-num-track` | `--track-tight` | hero 数字字距 |
| `--stage-pad-x` | `96px` | 舞台横向内边距 |
| `--stage-pad-y` | `80px` | 舞台纵向内边距 |
| `--card-shadow` | none | 卡片阴影 |
| `--shadow-stage` | dark drop | 舞台阴影 |
| `--stage-border` | `none` | 舞台边框 |

### 可选的装饰层

| token | 作用 |
|---|---|
| `--surface-pattern` | 叠在舞台上的背景图案 |
| `--surface-pattern-size` | 配套的 background-size |
| `--surface-pattern-blend` | mix-blend-mode |
| `--surface-pattern-opacity` | 透明度 |
| `--surface-vignette` | vignette 叠层 |
| `--text-shadow` | 文字阴影 |

---

## 创作新主题

### 1. 复制一个最接近的作为起点

```bash
cd <path-to-edu-web-powerpoint>/themes
cp -r clean-lecture my-theme
```

### 2. 改 `my-theme/tokens.css`

按契约自上而下走一遍：调色板 → 字体 → 性格旋钮 → 阴影 → 装饰。

**规则**：
- 深色主题 `--shell` 比 `--surface` 更深
- 浅色主题 `--shell` 比 `--surface` 略灰
- 维持 `--text` 与 `--surface` 至少 4.5:1 对比度
- `--accent` 是唯一的饱和色
- 挑一个设计签名重重发力

### 3. 改 `my-theme/theme.json`

```json
{
  "id": "my-theme",
  "name": "My Theme",
  "nameZh": "我的主题",
  "description": "一句英文描述。",
  "descriptionZh": "一句中文描述。",
  "mood": ["clean", "professional"],
  "bestFor": ["企业培训", "技术分享"],
  "preview": {
    "shell": "#f5f5f5",
    "surface": "#ffffff",
    "text": "#1a1a1a",
    "accent": "#2563eb"
  }
}
```

### 4. 测试

```bash
bash scripts/scaffold.sh /tmp/test-theme --theme=my-theme
cd /tmp/test-theme
npm run dev
```

把 demo 每一步点完。检查主题效果。

### 5. 加到文档里

在本文件顶部"内置主题"表里追加一行。

---

## 反模式

- **章节 CSS 硬编码 hex 颜色 / 字体名**
- **演示中途切换主题**
- **第二个 accent 色**
- **在组件层 override 主题 token**
- **依赖主题的 TSX 条件分支**
