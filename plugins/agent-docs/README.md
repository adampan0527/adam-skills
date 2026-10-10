# agent-docs

Auto-scaffolds a **progressive-disclosure** agent documentation entry point in any project that lacks one.

## What it does

On every `SessionStart`, the hook checks the project root for `_AGENTS.md`. If it is missing, it creates:

```
<project>/
├── _AGENTS.md      # single source of truth: basic facts + index table + the rules
├── AGENTS.md       # thin pointer to _AGENTS.md  (auto-loaded by Codex)
└── CLAUDE.md       # thin pointer to _AGENTS.md  (auto-loaded by Claude Code)
```

Three files, not ten. `docs/*.md` are **not** pre-created — the generated
`_AGENTS.md` tells the agent to create a document only once it has real
content to put in it, and to add the index row in the same breath. A stub
document that every session's index points at is pure wasted context.

The hook is **idempotent**: once `_AGENTS.md` exists it exits silently and never touches the project again.

## When it stays quiet

The hook runs four guards before writing anything, and exits silently if any
of them trips:

| Guard | Effect |
| --- | --- |
| `AGENT_DOCS_DISABLE=1` in the environment | Opts out of every project at once |
| `<project>/.agent-docs-disable` exists | Opts out of that one project, permanently |
| Root is `$HOME` or a system directory | Never touches system paths |
| Root has no project marker | Skips scratch dirs and random folders |

A "project marker" is any of `.git`, `package.json`, `pyproject.toml`,
`requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`,
`composer.json`, `Gemfile`, `Makefile`, `CMakeLists.txt`, `.hg`, `.svn`, `.project`,
or an existing `AGENTS.md` / `CLAUDE.md` / `docs/`.

It then injects a `[project-init]` note into the session telling the agent to fill the scaffold
with real project knowledge — instead of dumping the whole repository into context.

Works on both harnesses: Claude Code and Codex read the same `hooks.json` shape, both export
`PLUGIN_ROOT` for the command string, and both pass the session directory on stdin as `cwd`
(the script also falls back to `CODEX_PROJECT_ROOT` / `CLAUDE_PROJECT_DIR`, then to `pwd`).

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

Two ways, depending on how wide you want it:

```bash
# Globally — every project
export AGENT_DOCS_DISABLE=1
```

```bash
# Per project — drop an empty file in the project root
touch .agent-docs-disable
```

## Requirements

bash 3.2+ and standard POSIX userland (`mktemp`, `sed`, `cut`, `tr`, `pwd`). No node, jq, or python.

## Windows

Supported, with one prerequisite: **Git for Windows (Git Bash) must be installed and `bash` must be
on `PATH`** — the hook command is `bash "${PLUGIN_ROOT}/hooks/ensure_agent_docs.sh"`, and the script
relies on a POSIX userland. This is the same requirement Claude Code and Codex already have on
Windows, so if your harness runs at all, this works.

What the script handles for you:

- Harnesses on Windows report a native `cwd` (`C:\Users\me\project` or `C:/Users/me/project`).
  The script converts it to the MSYS form (`/c/Users/me/project`) before `cd`, and falls back to the
  original spelling if that fails.
- `C:\Windows`, `C:\Program Files`, and `C:\ProgramData` are excluded alongside the macOS
  system paths, so it never scaffolds into them.
- An unset `HOME` is tolerated rather than making every directory look like `$HOME`.

Not supported: a pure `cmd.exe` / PowerShell environment with no bash. If `bash` is missing the
hook fails silently and no files are written — nothing is corrupted, the scaffold just never appears.
To use the plugin there, run it manually from Git Bash:

```bash
bash /path/to/plugins/agent-docs/hooks/ensure_agent_docs.sh
```

The repo's own `scripts/check.sh` has the same requirement — run it from Git Bash on Windows.
