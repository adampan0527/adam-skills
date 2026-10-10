# agent-docs

Auto-scaffolds a **progressive-disclosure** agent documentation entry point in any project that lacks one.

## What it does

On every `SessionStart`, the hook checks the project root for `_AGENTS.md`. If it is missing, it creates:

```
<project>/
├── _AGENTS.md      # single source of truth: basic facts + index table + the rules
├── AGENTS.md       # thin pointer to _AGENTS.md  (auto-loaded by Codex)
├── CLAUDE.md       # thin pointer to _AGENTS.md  (auto-loaded by Claude Code)
└── docs/           # the 7 documents referenced by the table in _AGENTS.md
    ├── architecture.md
    ├── conventions.md
    ├── development-workflow.md
    ├── testing.md
    ├── domain-model.md
    ├── operations.md
    └── troubleshooting.md
```

The hook is **idempotent**: once `_AGENTS.md` exists it exits silently and never touches the project again.

It then injects a `[project-init]` note into the session telling the agent to fill the scaffold
with real project knowledge — instead of dumping the whole repository into context.

## Why the split

`AGENTS.md` and `CLAUDE.md` are auto-loaded into context on **every** session, so they must stay tiny.
They hold nothing but a pointer. All substance lives in `_AGENTS.md`, and everything longer than a
screen lives in `docs/`. The agent reads exactly one doc, chosen by matching its situation against
the first column of the table.

## Install

Claude Code:

```
/plugin marketplace add adampan0527/adam-skills
/plugin install agent-docs@adam-skills
```

Codex:

```bash
codex plugin marketplace add adampan0527/adam-skills
codex plugin add agent-docs@adam-skills
```

## Opting out

Set `AGENT_DOCS_DISABLE=1` in the environment to disable the hook entirely.

## Requirements

bash 3.2+ and standard POSIX userland (`mktemp`, `sed`, `pwd`). No node, jq, or python.
