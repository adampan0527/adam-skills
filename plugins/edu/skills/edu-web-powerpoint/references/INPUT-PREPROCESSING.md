# 文档预处理：教案 → knowledge.md

教学场景中，教案通常以 PDF 或 Word 文档形式提供。ewp 使用
[markitdown](https://github.com/microsoft/markitdown)（微软开源）将文档转成
markdown，再由 agent 整理成结构化的 `knowledge.md`。

---

## 支持的输入格式

| 格式 | markitdown 支持 | 说明 |
|---|---|---|
| **PDF**（.pdf） | ✓ | 最常见的教案格式 |
| **Word**（.docx） | ✓ | 教师备课文档 |
| **PowerPoint**（.pptx） | ✓ | 已有课件 |
| **Markdown**（.md） | — | 无需转换，直接使用 |
| **纯文本**（.txt） | — | 无需转换，直接使用 |
| **HTML**（.html） | ✓ | 网页内容 |
| **Excel**（.xlsx） | ✓ | 数据表格 |

> 如果用户直接给出 markdown 或纯文本，跳过 Phase 0，直接进 Phase 1。

---

## 安装 markitdown

**必须在 uv 虚拟环境中安装**（参见 SKILL.md「Python 环境约定」）：

```bash
# 创建并激活虚拟环境
uv venv
# Windows:
.venv\Scripts\activate
# macOS / Linux:
source .venv/bin/activate

# 安装 markitdown
uv pip install markitdown
```

如需处理图片中的文字（OCR）：

```bash
uv pip install markitdown[all]
```

**验证安装**：

```bash
markitdown --help
```

---

## 转换流程

### Step 1：文档 → markdown

```bash
# PDF 转 markdown
markitdown 教案.pdf -o 教案.md

# Word 转 markdown
markitdown 教案.docx -o 教案.md

# 也可以不指定 -o，输出到 stdout
markitdown 教案.pdf
```

**Python API**（agent 可在代码中调用）：

```python
from markitdown import MarkItDown

md = MarkItDown()
result = md.convert("教案.pdf")
markdown_text = result.text_content

# 写入文件
with open("教案.md", "w", encoding="utf-8") as f:
    f.write(markdown_text)
```

### Step 2：审查转换结果

markitdown 转出的 markdown **可能有瑕疵**，agent 必须审查：

| 常见问题 | 处理方式 |
|---|---|
| 表格格式错位 | 手动修正 markdown 表格 |
| 图片丢失 | 标注"此处原有图片：XXX"，后续在 web-ppt 中用视觉实现替代 |
| 公式渲染异常 | 保留原始 LaTeX，整理时标注 |
| 页眉页脚混入 | 删除无关内容 |
| 目录 / 页码混入 | 删除 |
| 中文断行 | 合并断行 |

### Step 3：整理成 knowledge.md

agent 阅读转换后的 markdown，整理成结构化的 `knowledge.md`：

```markdown
# <知识点标题>

## 概述
<一句话概括这个知识点>

## 核心概念
### <概念 1>
<概念说明 + 关键公式 + 重要性质>

### <概念 2>
...

## 案例
### <案例 1 名称>
<案例描述 + 输入 + 预期输出>

### <案例 2 名称>
...

## 关键公式 / 定理
- <公式 1>：<说明>
- <公式 2>：<说明>

## 常见误区
- <误区 1>：<正确理解>
- <误区 2>：<正确理解>

## 扩展资料
- <补充内容，供 agent 做信息池用>
```

**整理原则**：

1. **信息保留度 = 100%** —— knowledge.md 是最详尽的版本，
   不做任何删减。压缩在 teach-script 阶段做。
2. **结构化** —— 把教案的叙述体转成结构化条目。
3. **补全** —— 教案中省略但教学需要的内容（如背景知识）要补上。
4. **标注来源** —— 每个知识点标注在教案中的位置（页码 / 章节）。

---

## 完整流程示例

```
用户提供：教案.pdf（30 页，包含 5 个知识点 + 3 个案例）
   │
   ▼ Phase 0
   markitdown 教案.pdf -o 教案.md
   │
   agent 审查 + 修正格式瑕疵
   │
   agent 整理成 knowledge.md（结构化知识点 + 案例）
   │
   ▼ Phase 1
   读 knowledge.md → 产出 teach-script.md + outline.md
   │
   ▼ 正常流程...
```

---

## 注意事项

### 大文件处理

- 超过 50 页的 PDF：建议先确认哪些章节要做成 web-ppt，
  只转换相关部分
- markitdown 对扫描版 PDF（纯图片）的支持有限，
   需要 OCR 时用 `pip install markitdown[all]`

### 加密 / 受保护文档

- markitdown 不能处理加密 PDF 或有密码保护的 Word
- 遇到加密文档时提示用户先解密

### 格式复杂文档

- 嵌套表格、复杂排版的文档转出效果可能较差
- agent 应优先保证内容完整性，格式后续手动修正

### 多文件输入

- 用户可能一次给多个文档（如：教案.pdf + 习题.pdf + 参考答案.docx）
- 分别转换，合并整理成一个 `knowledge.md`
- 在 `knowledge.md` 中标注每个部分的来源文件
