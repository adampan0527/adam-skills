# HARNESS.md

> **The complete operating manual for this project.**
>
> This file describes the long-running agent harness that this project uses.
> It serves two audiences:
>
> - **Humans** reading the project to understand how the harness works.
> - **AI agents** working in the project. Every agent must read this file
>   before implementing features. It is the single source of truth for
>   harness workflow rules and per-file usage.
>
> If you are an AI agent entering this project, also read
> [`_AGENT.md`](./_AGENT.md) for the document index.

---

## Table of contents

- [Architecture](#architecture)
- [File-by-file usage](#file-by-file-usage)
  - [`_AGENT.md`](#_agentmd)
  - [`CLAUDE.md`](#claudemd)
  - [`AGENT.md`](#agentmd)
  - [`CODE_STYLE.md`](#code_stylemd)
  - [`INITIALIZER_PROMPT.md`](#initializer_promptmd)
  - [`CODING_AGENT_PROMPT.md`](#coding_agent_promptmd)
  - [`init.sh`](#initsh)
  - [`feature_list.json`](#feature_listjson)
  - [`claude-progress.txt`](#claude-progresstxt)
  - [`HARNESS.md` (this file)](#harnessmd-this-file)
- [Workflow rules](#workflow-rules)
- [Common failure modes](#common-failure-modes)
- [When to stop a session](#when-to-stop-a-session)

---

## Architecture

This project uses the two-agent architecture from Anthropic's
[Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

### 1. Initializer Agent

Runs **once** at project start. Sets up:

- The project structure and the rest of the harness files
- `init.sh` for development and testing
- `feature_list.json` with comprehensive feature requirements (all `"passes": false`)
- Git repository with initial commit
- `claude-progress.txt` documenting initial state

### 2. Coding Agent

Runs in **every subsequent session**. Each session:

1. Reads progress files and git history at startup
2. Starts the development server and verifies basic functionality
3. Works on **ONE** feature at a time
4. Tests thoroughly end-to-end before marking features as complete
5. Commits changes and updates the progress file

---

## File-by-file usage

Every file in this harness has a single, well-defined role. Never mix roles.

### `_AGENT.md`

**Role:** Document index for all agents.

**Created by:** Initializer (or by `lr-harness` skill).

**Read by:** Every agent, every session, before anything else.

**Updated by:** Humans only — when adding/removing rule documents.

**Usage:** When you start a session, read `_AGENT.md` first. It tells you which
other documents apply to your current task. Do not duplicate rule content
inside `_AGENT.md` — point to the document that holds the rule.

**Rules:**

- Do NOT remove or rename rows in the **Documents** table without updating
  the corresponding file.
- Do NOT add rules directly to `_AGENT.md` — add them to a dedicated document
  and link it from the table.

### `CLAUDE.md`

**Role:** Agent entry point for **Claude Code**.

**Created by:** Initializer.

**Read by:** Claude Code (specifically).

**Updated by:** Humans only.

**Usage:** This file's content is fixed: it tells Claude Code to read
`_AGENT.md`. Do not add project-specific rules here.

**Rules:**

- Do NOT add project documentation here — that belongs in `HARNESS.md` or
  `CODE_STYLE.md`.
- Do NOT remove the `read _AGENT.md` instruction.

### `AGENT.md`

**Role:** Agent entry point for **non-Claude-Code agents** (Cursor, Aider,
Codex, generic agent harnesses, etc.).

**Created by:** Initializer.

**Read by:** Any agent that is not Claude Code.

**Updated by:** Humans only.

**Usage:** Mirror of `CLAUDE.md` for other agents. Same fixed content.

**Rules:**

- Same as `CLAUDE.md` — keep it a one-line pointer to `_AGENT.md`.
- If a project introduces a new agent (e.g. `CURSOR.md`), create that file
  next to `CLAUDE.md` and `AGENT.md` with the same "read `_AGENT.md`" body.
  Do NOT consolidate them.

### `CODE_STYLE.md`

**Role:** Code style and conventions for this project.

**Created by:** Initializer (as a `[fill-in]` template).

**Read by:** Every agent **before writing or modifying source code**.

**Updated by:** Humans, on project start. Agents should propose changes via
PR rather than editing directly.

**Usage:** Two sections — Part 1 (Hard rules, universal values) and
Part 2 (Fill-in, project-specific). Fill in Part 2 before any agent starts
coding.

**Rules:**

- Part 1 (Hard rules) is non-negotiable. Never modify, weaken, or skip them.
- Every `[fill-in]` in Part 2 must be filled in before the first coding
  session. An empty `[fill-in]` is a blocking state.
- If a coding rule is universal (clean code, no magic numbers, etc.),
  it belongs in Part 1. If it is project-specific (formatter choice,
  test framework), it belongs in Part 2.

### `INITIALIZER_PROMPT.md`

**Role:** Instructions for the **first** agent session on a project.

**Created by:** Initializer. Only created once per project.

**Read by:** The agent on its first session.

**Updated by:** Humans only. Once initialization is done, this file is
**frozen**.

**Usage:** Copy this file's content into the agent's first system prompt,
along with the project's high-level requirements. The agent will then set
up the rest of the harness (project structure, feature list, git, etc.).

**Rules:**

- This file is created **exactly once**. If you see `INITIALIZER_PROMPT.md`
  on a project that already has features, the project has been initialized
  — do not re-run it.
- After initialization, this file is read-only.

### `CODING_AGENT_PROMPT.md`

**Role:** Instructions for **every subsequent** agent session.

**Created by:** Initializer. Used throughout the project's life.

**Read by:** Every coding agent, every session.

**Updated by:** Humans only. Refine the workflow if the project evolves, but
do not change it casually.

**Usage:** Copy this file's content into the agent's system prompt at the
start of each coding session, along with the latest `claude-progress.txt`
output.

**Rules:**

- Every coding session starts with this prompt + the current progress log.
- Do not skip the "verify basic functionality" step at the start of the
  session — broken environments waste more time than feature work.
- Do not add "extras" to this file. If a project needs extra agent
  behavior, add a separate document and link it from `_AGENT.md`.

### `init.sh`

**Role:** Project setup / start / smoke-test script.

**Created by:** Initializer (as a template, filled in by humans).

**Read by:** Every coding agent at session start.

**Updated by:** Humans when the project's startup commands change.
Coding agents should not modify `init.sh`.

**Usage:**

```bash
bash init.sh
```

This script must:

1. Install dependencies if needed.
2. Start the development server in the background.
3. Run a basic end-to-end smoke test.
4. Leave the server running for the agent to interact with.

The agent reads this script at session start to learn how the project runs.
A clear `init.sh` saves a coding agent a lot of orientation time.

**Rules:**

- `init.sh` is the source of truth for "how do I run this project".
  Do not bury startup commands in `README.md` only — put them here.
- If the project has multiple run modes (dev, test, build), prefer one
  `init.sh` per mode (`init.sh`, `test.sh`, `build.sh`) over a single
  `init.sh` with subcommands.
- If `init.sh` cannot start the server (e.g. project is library-only),
  document that in the script's header comment.

### `tools/feature_list.py`

**Role:** The mandatory interface to `feature_list.json`.

**Created by:** Initializer (shipped as-is from the harness; users do not customize it).

**Read by:** Every coding agent, every session.

**Updated by:** No one. If this script needs a new subcommand or a bug
fix, edit the source and re-run — do not edit `feature_list.json` instead.

**Usage:**

```bash
python tools/feature_list.py list
python tools/feature_list.py mark-passing <feature_id>
python tools/feature_list.py add <feature_id> <category> <description> [--priority high|medium|low]
python tools/feature_list.py update-metadata
```

The script reads and rewrites `feature_list.json` in place with stable
2-space indentation. `mark-passing` and `add` automatically recompute
`metadata` (total / passing / failing / last_updated).

**Rules:**

- This script is the **only** sanctioned way to mutate `feature_list.json`.
  Editing `feature_list.json` directly (Write tool, Edit tool, sed, manual)
  is forbidden by `CODE_STYLE.md` Hard Rules.
- The script uses only the Python standard library — no `pip install`
  required. If a subcommand is missing, extend the script; do not bypass
  it.
- Run `python tools/feature_list.py list` at the start of every coding
  session to see what's still failing.

### `feature_list.json`

**Role:** The authoritative list of features for this project.

**Created by:** Initializer (with empty `features: []`), then **filled in by
humans** before the first coding session.

**Read by:** Every coding agent, every session.

**Updated by:** Only via [`tools/feature_list.py`](#toolsfeature_listpy).
Humans can call `python tools/feature_list.py add <id> <category> <desc>`
during the initializer phase, or to add features mid-project. Coding agents
call `mark-passing` after end-to-end testing.

**Usage:**

```json
{
  "project_name": "Your Project Name",
  "description": "Brief description",
  "features": [
    {
      "id": "feat-001",
      "category": "functional",
      "description": "Clear, testable description",
      "steps": [
        "Step 1: Navigate to...",
        "Step 2: Perform action",
        "Step 3: Verify result"
      ],
      "passes": false,
      "priority": "high"
    }
  ],
  "metadata": {
    "total_features": 0,
    "passing": 0,
    "failing": 0,
    "last_updated": "YYYY-MM-DD"
  }
}
```

**Category values:** `functional`, `ui`, `error-handling`, `accessibility`,
`performance`.

**Priority values:** `high`, `medium`, `low`.

**Rules:**

- **CRITICAL:** Never edit `feature_list.json` directly. All mutations
  go through `python tools/feature_list.py` (subcommands: `list`,
  `mark-passing`, `add`, `update-metadata`). The script enforces id
  uniqueness, category whitelist, and metadata consistency — direct edits
  bypass those guarantees.
- **NEVER** remove or rewrite features. Removing a feature to "mark it
  done" hides unfinished work. To defer a feature, set its `priority` to
  `low` or leave it in place with `passes: false`.
- Every feature's `steps` array must be detailed enough that a human or
  another agent can follow them to verify the feature works.
- Aim for **comprehensive coverage** — include UI, error-handling,
  accessibility, and performance features, not only `functional`.
- Update `metadata.total_features` / `passing` / `failing` /
  `last_updated` whenever you change any feature.
- Coding agents choose features in priority order, but may choose a
  medium-priority feature if it unblocks multiple high-priority ones.

### `claude-progress.txt`

**Role:** Free-form progress log, written by humans and agents.

**Created by:** Initializer (as a template, filled in with project name and
start date).

**Read by:** Every coding agent, every session, at startup.

**Updated by:** Coding agents at the end of every session. Humans as needed.

**Usage:** Each session appends a `SESSION N - Coding Agent` block:

```
SESSION N - Coding Agent
-----------------------
Date: YYYY-MM-DD
Worked on: [feature description]
Status: [Implemented / Fixed / Tested]
Features now passing: [count]

Changes made:
- [brief description of code changes]

Next session should:
- [suggestion for what to work on next]

---
```

A `SUMMARY` block at the bottom tracks totals across sessions.

**Rules:**

- Always append, never overwrite earlier entries. The progress log is a
  history, not a status snapshot.
- Update the SUMMARY block at the end of every session.
- If a session is interrupted or fails, log that. "I tried X and it broke,
  here's the error" is more useful than silence.
- This file is plain text on purpose — it must be diffable in git and
  readable in any editor.

### `HARNESS.md` (this file)

**Role:** The complete operating manual. Source of truth for harness workflow
and per-file usage.

**Created by:** Initializer.

**Read by:** Every agent, every session (after `_AGENT.md` routes here).

**Updated by:** Humans, when the harness workflow itself evolves (rarely).

**Usage:** Read this file at the start of every session to refresh on the
rules. When in doubt about any other file's role, return here.

**Rules:**

- This file should change **rarely** — it documents the harness, not the
  project. If you find yourself editing it often, the harness workflow
  itself is wrong.
- When adding a new file to the harness, update the
  [File-by-file usage](#file-by-file-usage) section.
- When changing how any file is used, update its entry here. Do not let
  the docs drift from the practice.

---

## Workflow rules

### Incremental progress

- Work on **one** feature at a time.
- Do NOT implement multiple features in one session.
- If you finish one feature and have context left, you may start a second,
  but **test and commit each one separately**.
- Leave the environment in a clean, working state at the end of every
  session.

### Testing

- Always test end-to-end before marking features as passing (`"passes": true`).
- Test as a human user would, not as a developer.
- For web applications, use browser automation (Puppeteer MCP, Chrome
  DevTools MCP, etc.) to navigate and verify.
- Test edge cases where applicable — empty inputs, error paths, slow
  networks.

### Documentation

- Commit changes with descriptive messages (`Implement: ...`, `Fix: ...`).
- Update `claude-progress.txt` at the end of every session.
- Maintain clear git history — one commit per feature, atomic and reversible.

### Error recovery

- Use git to revert bad changes (`git revert`, `git reset`).
- Always verify basic functionality **before** implementing new features.
- Fix existing bugs before adding new features.
- If the environment is broken, fix it first. Do not implement features
  on a broken base.

### Code style

- Read [`CODE_STYLE.md`](./CODE_STYLE.md) before writing any source code.
- Part 1 (Hard rules) is non-negotiable.
- Part 2 (Fill-in) is project-specific. Fill it in on day one.

---

## Common failure modes

| Problem | Solution |
|---------|----------|
| Declares victory too early | Always read `feature_list.json` and work on one feature at a time |
| Leaves environment broken | Read `claude-progress.txt` and run `bash init.sh` before new features |
| Marks features done prematurely | Test thoroughly end-to-end before changing `"passes"` to `true` |
| Wastes time figuring out how to run app | `init.sh` must contain all startup commands; read it at session start |
| Removes features from `feature_list.json` | NEVER do this. To defer, lower its `priority`; only `tools/feature_list.py mark-passing` flips `passes` |
| Edits `feature_list.json` directly | Forbidden by CODE_STYLE.md. Always go through `python tools/feature_list.py <subcommand>` |
| Edits `CODE_STYLE.md` Part 1 | Don't. Part 1 is universal and non-negotiable |
| Skips reading `_AGENT.md` | Always read it first; it routes you to the right documents |

---

## Testing best practices

For web applications, use browser automation to:

- Navigate to the application
- Interact with UI elements as a human would
- Verify expected behavior
- Take screenshots for debugging if needed

For backend / library projects:

- Run unit tests via `init.sh` or the equivalent test script.
- Verify the smoke test passes before moving on.
- Add regression tests for any bug fixed in this session.

Always follow the steps listed in each feature's `steps` array.

---

## When to stop a session

Stop when:

- You have successfully implemented and tested at least one feature.
- The code is in a clean, working state (no broken tests, no debug code).
- Your progress is committed with a descriptive message.
- `claude-progress.txt` is updated.

Even if context remains, it is better to leave the environment clean than
to push too far and potentially break something. The next session can pick
up where you left off by reading `claude-progress.txt` and `feature_list.json`.