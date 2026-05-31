# 实操案例模板

这个文件夹是实操案例的模板。生成实操案例时，以此为基础。

## 文件夹结构

```
case-exercise/
├── README.md          # 本文件（操作说明）
├── main.html          # 案例入口（或 main.py / index.js）
└── ...                # 案例所需资源
```

## README.md 必须包含

```markdown
# <案例名称>

## 学习目标
- <这个案例让学生练习什么>

## 环境准备
<如为 Python 案例：>
1. uv venv
2. .venv\Scripts\activate（Windows）或 source .venv/bin/activate（macOS/Linux）
3. uv pip install -r requirements.txt

## 操作步骤
1. <步骤 1>
2. <步骤 2>
3. ...

## 预期结果
- <做对了应该看到什么>

## 思考题
1. <引导学生深入思考的问题>
```

## 质量标准

- 可以纯本地运行（双击 HTML 或运行 python/js）
- 自包含（所有依赖在文件夹内或用 CDN）
- 有中文注释
- 有操作提示
- 学生能修改参数进行实验
- Python 案例必须附带 `requirements.txt`，用 `uv` 管理虚拟环境
