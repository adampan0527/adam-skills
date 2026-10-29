# _AGENTS.md — 本项目唯一的 Agent 提示词入口

> **状态：基础说明已填。** 本文件是本项目唯一的 Agent 提示词内容源。
> 2026-10-10：原根目录 `CLAUDE.md` 的正文已按内容性质拆入
> `docs/architecture.md`（结构）与 `docs/conventions.md`（规范），`CLAUDE.md` 改为纯指针。
> 尚未沉淀的事实（如测试策略、运维、疑难排查）仍保持 `待填充`，等真遇到时再写。

---

## 1. 基础说明

| 项目 | 内容 |
| --- | --- |
| 项目名称 | `adam-skills`（Claude Code / Codex 插件市场） |
| 一句话定位 | 把个人 skill 打包成插件分发的市场仓库 |
| 主要语言 / 运行时 | Markdown + JSON + Shell（Hook）+ TSX/CSS（模板） |
| 主要入口 | `.claude-plugin/marketplace.json` |
| 包管理器 / 构建命令 | 无（仓库根目录无 `package.json`，不需构建） |
| 测试命令 | 无自动化测试；校验跑 `bash scripts/check.sh`，skill 靠 harness 内触发人工验证 |
| 代码规范来源 | 人工约定，见 [docs/conventions.md](docs/conventions.md) |
| 当前对外发布 | 市场 `adam-skills` v1.0.0；插件 `agent-docs` v1.2.0、`edu` v1.1.0 |
| 文档目录 | `docs/`（按需创建，当前仅 2 份已填实） |

**填写规则**：每一行都只写「查得到的事实」，一行不超过 30 字；写不出来就保持 `待填写`，不要编造。

## 2. 什么时候看哪份文档

下表是本项目的**文档索引**。遇到左边的情况时，**只**阅读右边这一份文档，读完再继续干活。

| 遇见的情况 | 应该看哪个文档 |
| --- | --- |
| 第一次进入项目，想知道整体结构、模块划分与依赖关系 | [docs/architecture.md](docs/architecture.md) |
| 要写代码或提 PR，想知道命名/风格/目录约定 | [docs/conventions.md](docs/conventions.md) |
| 上表都没覆盖的新情况 | 先回到本文件新增一行「情况 → 文档」，再补写那份文档 |

所有被引用的文档都放在项目根目录的 `docs/` 文件夹里。

`docs/` 下的文档**按需创建，不预先占位**：只有真的写下了可复用的内容才建文件，并同时在上表加一行。
（旧版脚手架曾预生成 5 份全是 `待填写` 的空文档，现已删除——索引指向空文档只会让 agent 白读一轮。）

## 3. 渐进式披露原则（Progressive Disclosure）

本项目所有 Agent 上下文遵循三条硬规则：

1. **入口最小化**：`_AGENTS.md` 只允许放「基础说明」+「索引表格」+「硬性红线」，正文一律外链。
   任何一节超过 20 行，就说明它该搬进 `docs/` 了。
2. **按需加载**：判断该读哪份文档的标准是**上表的「情况」列**，不是「文件好不好看」。
   没匹配到就不读；匹配到就读，且**只读这一份**。
3. **写进哪里由「是否会被复用」决定**：
   - 一次性的、只跟当前任务有关的 → 写在当次回复或 issue 里，**不要**进仓库；
   - 下次还会用到的 → 写进对应的 `docs/*.md`，并**同时在第 2 节表格里加一行**指向它；
   - 会反复触发的硬性约束（禁止操作、必须先做的检查）→ 提级写进本文件第 4 节。

## 4. 硬性红线

- **禁止**在 `marketplace.json` / `plugin.json` 中加入 `$schema` 字段（会导致插件加载失败）。
- **禁止**让 `.claude-plugin/plugin.json` 与 `.codex-plugin/plugin.json` 的 `name` / `version` / `description` 不一致（双 harness 靠这两份清单，改一处必须改两处）。
- **禁止**在 marketplace 里声明 `plugins/<name>/` 下不存在的插件，或两边 `version` 不一致。
- **禁止**把 SKILL.md 放到 `plugins/<plugin>/skills/<name>/SKILL.md` 以外的位置。
- **禁止**往 `AGENTS.md` / `CLAUDE.md` 写正文——它们只能是指针。
- **禁止**在 `plugins/*/skills/*/templates/` 里增删依赖或跑构建：那是复制给终端用户的脚手架，不是本仓库的代码。
- **禁止**把一个领域的 skill 塞进领域不符的插件（插件按领域划分，见 `docs/conventions.md`）。
- **禁止**编造基础说明里的事实：查不到就写 `待填写`。

## 5. 维护本文件

- 修改本项目约定时，**改 `docs/` 下的正文**，本文件只维护索引。
- 新增文档 = 在 `docs/` 建文件 + 在第 2 节表格加一行，两件事必须同时做完。
- `AGENTS.md` 与 `CLAUDE.md` 只是指针，**永远不要往里面写正文**。
