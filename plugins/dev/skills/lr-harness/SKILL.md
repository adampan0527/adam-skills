---
name: lr-harness
description: Bootstrap a long-running agent harness into a target project. Use when a user wants to scaffold a new project for multi-session AI agent work, or wants to apply Anthropic's effective-harnesses-for-long-running-agents pattern to an existing project. The skill writes eleven files (CLAUDE.md, AGENT.md, _AGENT.md, HARNESS.md, CODE_STYLE.md, INITIALIZER_PROMPT.md, CODING_AGENT_PROMPT.md, init.sh, feature_list.json, tools/feature_list.py, claude-progress.txt), initializes git, and tells the user what to fill in. It does NOT decide tech stack, feature contents, or implementation details — those stay as placeholders the user fills in.
---

# lr-harness

This skill scaffolds a **long-running agent harness** into a target project —
the two-agent architecture (Initializer + Coding Agent) from Anthropic's
[Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

The skill's job is **rule-making, not code generation**. It produces an empty
harness skeleton and a rule book. The user fills in everything project-specific.

The scaffold has three layers:

- **Document layer** (agent-agnostic): `_AGENT.md` (index) → `HARNESS.md` + `CODE_STYLE.md`
- **Agent entry points** (per-agent): `CLAUDE.md` (Claude Code) + `AGENT.md` (other agents)
- **Workflow files**: `INITIALIZER_PROMPT.md`, `CODING_AGENT_PROMPT.md`, `init.sh`, `feature_list.json`, `claude-progress.txt`, `tools/feature_list.py`

Every agent entry point is one line: "read `_AGENT.md`". `_AGENT.md` then routes
agents to the right document for their current task. Adding new rule documents
later only requires editing `_AGENT.md` — agent entry points stay untouched.

## When to invoke

Invoke when the user wants any of:

- "Set up a long-running agent harness for this project"
- "Bootstrap a multi-session coding agent workflow"
- "Apply the Anthropic long-running harness pattern"
- "/lr-harness" with a target path

Do **not** invoke for one-off coding tasks, single-session features, or when
the user wants concrete feature brainstorming — this skill only scaffolds.

## Inputs

Before writing files, ask the user for **exactly one** thing:

- **Target directory (absolute path)** — where the harness files will be written.
  The skill must NOT proceed without this.

Do **not** ask about tech stack, feature list, project description, language
preference, or anything else. All such fields stay as placeholders. The user
fills them in after scaffolding.

If the target directory already contains any of `_AGENT.md`, `HARNESS.md`, or
`CODING_AGENT_PROMPT.md`, **stop and warn the user** — overwriting an existing
harness is destructive. Ask them to confirm before proceeding.

## Outputs

Write these eleven files into the target directory using the **exact contents**
provided in the file blocks below. Do not read any other files — every file's
content is fully specified inline here.

After writing files:

1. Run `git init` in the target directory (skip if `.git` already exists).
2. `git add .` then `git commit -m "Initial commit: scaffold long-running agent harness"` (skip the commit if the repo already has commits).
3. Print the **completion summary** at the end of this file.

---

### File 1: `_AGENT.md`

```markdown
# _AGENT.md — Document Index

This is the **document index** for the project. Every agent that enters this
project — regardless of which agent it is — should read this file first to
discover which documents govern its work.

## How to use this index

1. Identify **what you are about to do**.
2. Read the matching document from the table below.
3. Follow the rules in that document for the duration of your task.
4. When you switch tasks, return to this index and re-select.

This indirection means agent entry points (`CLAUDE.md`, `AGENT.md`) stay tiny:
they only point here. New rule documents can be added without touching any
agent entry point — just add a row below.

## Documents

| You are about to... | Read this document |
|---------------------|--------------------|
| Understand the harness workflow or how to use any harness file | [`HARNESS.md`](./HARNESS.md) |
| Write or modify source code | [`CODE_STYLE.md`](./CODE_STYLE.md) |

Add more rows here as the project grows — e.g. testing, deployment, security.

## Maintenance

When you add a new rule document to this project:

1. Create the new `.md` file at the project root.
2. Add a row to the **Documents** table above describing when to read it.
3. Do NOT modify `CLAUDE.md` or `AGENT.md` — they already point here.

When you remove a rule document:

1. Remove the file.
2. Remove the matching row from the **Documents** table above.
3. Update any cross-references in the remaining documents.
```

---

### File 2: `CLAUDE.md`

```markdown
# CLAUDE.md

If you are an AI agent (specifically Claude Code) entering this project, **read [`_AGENT.md`](./_AGENT.md) first**.

`_AGENT.md` is the document index. It tells you which other documents in this
project apply to your current task (harness workflow, code style, etc.).

Do not duplicate rule content here — `_AGENT.md` and the documents it indexes
are the single source of truth.
```

---

### File 3: `AGENT.md`

```markdown
# AGENT.md

If you are an AI agent entering this project and you are NOT Claude Code, **read [`_AGENT.md`](./_AGENT.md) first**.

`_AGENT.md` is the document index. It tells you which other documents in this
project apply to your current task (harness workflow, code style, etc.).

Do not duplicate rule content here — `_AGENT.md` and the documents it indexes
are the single source of truth.
```

---

### File 4: `HARNESS.md`

```markdown
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
```

---

### File 5: `CODE_STYLE.md`

```markdown
# CODE_STYLE.md

> Code style and conventions for this project.
>
> **Two kinds of rules live here:**
> 1. **Hard rules** — universal values. Apply to every project regardless of
>    tech stack. These are non-negotiable. Do not modify.
> 2. **Fill-in rules** — project-specific choices (formatter, linter, etc.).
>    Replace every `[fill-in]` with the project's chosen convention before
>    any coding agent starts work.
>
> Every agent (Initializer or Coding Agent) must read this file before writing
> or modifying source code. See [`_AGENT.md`](./_AGENT.md).

---

## Part 1 — Hard rules (universal values)

These exist to keep code **clean**, **directory layout clear**, **files small**,
and to **avoid "屎山"** (dumpster-fire codebases — large files, tangled
dependencies, hidden side effects, magic values, god components).

### Clean code

- **One responsibility per file.** If you have to use "and" to describe a
  file's purpose, split it. A file should be answerable to "what does this
  file do?" with one short sentence.
- **Short functions.** Aim for ≤ 40 lines per function. If a function grows
  past ~60 lines, extract sub-functions or move logic to a helper module.
- **Short files.** Aim for ≤ 200 lines per file excluding comments and
  blank lines. Above that, the file is doing too much — split by
  responsibility.
- **Names express intent.** Prefer `validateEmailFormat` over `check`. Prefer
  `UserRepository` over `Manager`. No abbreviations unless they are domain
  standard.
- **No magic numbers.** Use named constants. `MAX_RETRIES = 3`, not `3`.
- **No hidden side effects.** A function called `getUser` should not also
  send an email. If two things must happen, call two functions.
- **Comments explain *why*, not *what*.** The code shows what. Comments
  justify non-obvious decisions.
- **No dead code.** Delete unused branches, commented-out blocks, unreferenced
  exports. Git keeps history; the working tree does not.

### Clear directory layout

- **Top-level directories describe layers or domains**, not features. Prefer
  `routes/`, `components/`, `services/`, `data/`, `config/` over
  `stuff/`, `utils/`, `misc/`.
- **Domain logic is colocated.** Code that changes together lives together.
  Do not scatter one feature across five top-level folders.
- **Public vs internal is obvious.** Use a public entry point file
  (`index.ts`, `mod.rs`, `__init__.py`) per directory. Internal modules
  start with `_` or live in a clearly-marked subfolder.
- **Tests mirror source layout.** `src/foo/bar.ts` → `tests/foo/bar.test.ts`
  (or `src/foo/bar.test.ts` co-located — choose per project, document the
  choice).

### Many small files, not few large ones

- **Split by responsibility, not by size target.** Do not artificially chop
  a 100-line file into two 50-liners. Split when a file actually has two
  distinct concerns.
- **One component / one module per file.** A React component + its tests +
  its styles go in three files, not one mega `UserPage.tsx`.
- **Configuration files belong in `config/`, not at the root mixed with
  source.** `config/database.ts`, not `db.ts` at the repo root.
- **No "utils" dumping ground.** If a file accumulates unrelated helpers,
  rename it by what it actually does, or split by topic
  (`time.ts`, `validation.ts`).

### Avoid 屎山

- **No circular dependencies.** `A → B → A` is a refactor trigger, not a
  fact of life.
- **No god objects / god components.** A class or component > ~300 lines,
  or one that "knows everything", must be decomposed.
- **No global mutable state.** Singletons and module-level mutable variables
  are red flags. Inject dependencies instead.
- **No copy-paste.** If two files share logic, extract a shared module.
  Two near-identical blocks are a refactor trigger.
- **No premature abstraction.** Do not introduce a base class, factory,
  or generic for a single use case. Wait for the second occurrence.
- **No silent failures.** No empty `catch`, no `return null` without a
  documented reason. Errors propagate or get logged with context.

### Data integrity via scripts

Some data files are easy to corrupt by hand-editing — JSON configs, schema
files, the harness's `feature_list.json`, etc. These MUST go through a
script:

- **Every fragile data file has a dedicated script in `tools/`** that
  enforces invariants (id uniqueness, type checks, schema validation).
- **Direct edits to those data files are forbidden** — even one-line
  changes. If a script subcommand is missing, add it to the script.
- A direct edit is a code-review blocker, the same way merging without
  a passing CI is.
- Examples in this harness: `tools/feature_list.py` for `feature_list.json`.

This is not bureaucracy — the script catches things humans forget (the
`metadata` counter, the `last_updated` stamp, the `category` whitelist).
Forcing edits through the script is what makes those invariants survive
across dozens of sessions.

### Refactor triggers (when to stop adding, start splitting)

| Trigger | Action |
|---------|--------|
| File > 200 lines (excluding comments) | Split by responsibility |
| Function > 60 lines | Extract helper |
| File needs `and` in its purpose statement | Split into two files |
| Module imports from sibling too deeply | Move shared logic up one layer |
| A "utils" / "helpers" file passes 20 entries | Rename or split by topic |
| You copy-pasted a 5-line block twice | Extract shared function |
| A test file is bigger than the code it tests | Tests are doing too much |

---

## Part 2 — Fill-in rules (project-specific)

Complete every `[fill-in]` below before any coding agent starts work.

### Language and toolchain

- **Primary language:** `[fill-in]` (e.g. TypeScript, Python, Go, Rust)
- **Formatter:** `[fill-in]` (e.g. prettier, black, gofmt, rustfmt)
- **Linter:** `[fill-in]` (e.g. eslint, ruff, golangci-lint, clippy)
- **Type checker:** `[fill-in]` (e.g. tsc, mypy, go build, cargo check)
- **Package manager:** `[fill-in]` (e.g. npm, pnpm, poetry, cargo)

### Directory layout (project-specific)

- **Source root:** `[fill-in]` (e.g. `src/`, `app/`, `lib/`)
- **Entry point:** `[fill-in]` (e.g. `src/index.ts`, `app/main.py`)
- **Top-level directories and their meaning:**
  - `[fill-in: e.g. routes/ — HTTP handlers]`
  - `[fill-in: e.g. services/ — business logic]`
  - `[fill-in: e.g. data/ — persistence and models]`
  - `[fill-in: add more as needed]`
- **Test location:** `[fill-in: e.g. co-located *.test.ts OR tests/ mirror]`

### Naming conventions

- **Files:** `[fill-in]` (e.g. `kebab-case.ts`, `snake_case.py`, `PascalCase.tsx`)
- **Classes / components:** `[fill-in]` (e.g. `PascalCase`)
- **Functions / methods:** `[fill-in]` (e.g. `camelCase`, `snake_case`)
- **Constants:** `[fill-in]` (e.g. `SCREAMING_SNAKE_CASE`)
- **Test files:** `[fill-in]` (e.g. `*.test.ts`, `test_*.py`)

### Testing conventions

- **Framework:** `[fill-in]` (e.g. vitest, jest, pytest, go test)
- **Coverage threshold (line):** `[fill-in]` (e.g. 80%)
- **Test file naming:** `[fill-in]`
- **What *must* be tested:** `[fill-in]` (e.g. all public APIs, all error paths)

### Commit conventions

- **Format:** `[fill-in]` (e.g. Conventional Commits, free-form sentence)
- **Branch naming:** `[fill-in]` (e.g. `feat/...`, `fix/...`)
- **Max commit size:** `[fill-in]` (e.g. one feature per commit)

### Project-specific hard rules

Add any additional non-negotiable rules for THIS project (in addition to Part 1):

- `[fill-in: e.g. "no `any` in TypeScript", "all exports must be explicitly typed"]`

---

## How to enforce

- **Formatter + linter + type checker must pass before commit.** Pick a hook
  (`pre-commit`, `husky`, `lefthook`) that runs all three. If the project
  cannot run all three yet, defer commits until it can.
- **CI must run the same checks.** A failing CI is the only ground truth
  for "code is clean enough".
- **Refactor triggers (Part 1) are review-time checks.** A reviewer who
  sees a 300-line file says "split first", not "ship it".

---

Once Part 2 is filled in, every agent must read **both parts** before writing
or modifying source code. Part 1 never changes; Part 2 changes with the
project. See [`_AGENT.md`](./_AGENT.md).
```

---

### File 6: `INITIALIZER_PROMPT.md`

```markdown
# Initializer Agent Instructions

You are the **Initializer Agent** for a long-running AI agent system. Your task is to set up the initial environment that will enable future coding agents to work effectively across multiple context windows.

## Your Responsibilities

1. **Set up the project structure** with all necessary files for the target application
2. **Create an `init.sh` script** that can run the development server and perform basic end-to-end testing
3. **Create a comprehensive feature list** (`feature_list.json`) that expands on the user's initial prompt with detailed, testable features
4. **Initialize a git repository** and make an initial commit
5. **Create a `claude-progress.txt` file** to log what has been accomplished

## Step-by-Step Instructions

### 1. Understand the User's Request

Read and understand the high-level prompt for what needs to be built (e.g., "build a clone of claude.ai").

### 2. Set Up the Project Structure

Create all necessary files for a working application:
- Package.json (if Node.js), requirements.txt (if Python), etc.
- Source code structure
- Dependencies
- Configuration files

### 3. Create the Feature List File (`feature_list.json`)

Create a JSON file with a comprehensive list of features. Each feature should be detailed enough to be testable end-to-end. Initially, mark all features as `"passes": false`.

Example feature entry:
```json
{
  "category": "functional",
  "description": "New chat button creates a fresh conversation",
  "steps": [
    "Navigate to main interface",
    "Click the 'New Chat' button",
    "Verify a new conversation is created",
    "Check that chat area shows welcome state",
    "Verify conversation appears in sidebar"
  ],
  "passes": false
}
```

Include 200+ features for complex projects. Categorize them as:
- `functional`: Core user-facing features
- `ui`: Visual and layout features
- `error-handling`: Error state handling
- `accessibility`: A11y compliance
- `performance`: Performance-related features

### 4. Create the `init.sh` Script

Write a shell script that:
- Installs dependencies if needed
- Starts the development server
- Performs a basic end-to-end test
- Has appropriate error handling

Example structure:
```bash
#!/bin/bash

# Install dependencies
npm install

# Start development server in background
npm run dev &
SERVER_PID=$!

# Wait for server to be ready
sleep 5

# Run basic test
echo "Running basic test..."
# Add test commands here

# Cleanup
kill $SERVER_PID
```

### 5. Initialize Git Repository

```bash
git init
git add .
git commit -m "Initial commit: Set up project structure and environment"
```

### 6. Create `claude-progress.txt`

Write a file documenting what has been accomplished:
```
PROJECT PROGRESS LOG
====================

Session 1 - Initializer Agent
- Set up project structure
- Created feature_list.json with XX features
- Created init.sh for development server and testing
- Initialized git repository
- Made initial commit

Next Steps:
- Coding agents should start working on the highest-priority failing features
- Run init.sh before implementing new features
- Test thoroughly before marking features as passing
```

## Important Guidelines

1. **Do not try to implement all features at once** - Your job is environment setup only
2. **Make the feature list comprehensive** - Include all features required for a production-ready application
3. **Use JSON for the feature list** - This makes it harder for agents to accidentally modify the structure
4. **Write clear, testable feature steps** - Each step should be something a user can verify
5. **Document everything** - Future agents should be able to understand the setup quickly

## Completion Checklist

- [ ] Project structure is set up with all necessary files
- [ ] `init.sh` script exists and can start the development server
- [ ] `feature_list.json` exists with comprehensive features (all marked as failing)
- [ ] Git repository is initialized with initial commit
- [ ] `claude-progress.txt` documents what was accomplished
- [ ] Application can run (even if with minimal functionality)

Once you have completed all these tasks, you are done. Do NOT proceed to implement features - that is the job of the coding agent in subsequent sessions.
```

---

### File 7: `CODING_AGENT_PROMPT.md`

```markdown
# Coding Agent Instructions

You are a **Coding Agent** working on a long-running project. Your task is to make incremental progress on features, leaving the environment in a clean state for the next agent session.

## Your Responsibilities

1. **Make incremental progress** - Work on one feature at a time
2. **Test thoroughly** - Verify features work end-to-end before marking as complete
3. **Leave the environment clean** - No major bugs, code is well-documented
4. **Document your progress** - Update git commits and the progress file

## Session Startup Procedure

Every session must start with these steps:

### 1. Get Your Bearings

```bash
pwd
```
Verify the directory you're working in. You can only edit files in this directory.

### 2. Read Progress Documentation

Read the `claude-progress.txt` file to understand what has been accomplished and what the current state is.

### 3. Check Git History

```bash
git log --oneline -20
```
Review recent commits to understand what was recently worked on.

### 4. Read the Feature List

Read `feature_list.json` to understand what features need to be implemented.

### 5. Start the Development Server

Run the `init.sh` script to start the development server:
```bash
bash init.sh
```

If `init.sh` doesn't start the server (it might just test), you'll need to start the development server manually based on what you learn from `init.sh`.

### 6. Verify Basic Functionality

Before implementing new features, verify that existing features still work:
- Navigate to the application
- Run a basic end-to-end test
- Check for any broken functionality

If you find bugs, fix them BEFORE implementing new features.

## Feature Implementation Procedure

### 1. Choose a Feature

From `feature_list.json`, choose:
- A feature that is marked as `"passes": false`
- Prefer higher priority features (order may be implied by position)
- Prefer features that build on already-working functionality

### 2. Implement the Feature

Write the code needed to make the feature work. Follow best practices:
- Write clean, maintainable code
- Add comments where logic isn't self-evident
- Follow existing code patterns and style

### 3. Test Thoroughly

**This is critical.** Do NOT mark a feature as passing until you have tested it end-to-end:

1. **Read the feature steps** from `feature_list.json`
2. **Follow each step** as a user would
3. **Verify the feature works** at each step
4. **Test edge cases** where applicable

For web applications, use browser automation tools to:
- Navigate to the application
- Interact with UI elements as a human would
- Verify expected behavior
- Take screenshots if helpful for debugging

### 4. Mark Feature as Complete

Only after thorough testing, run the project's mandatory feature-list script
to mark the feature as passing. Direct editing of `feature_list.json` is
forbidden by `CODE_STYLE.md` Hard Rules.

```bash
python tools/feature_list.py mark-passing <feature_id>
```

If you do not yet know the feature's `id`, run `python tools/feature_list.py list` first.

**IMPORTANT:** Do NOT remove or edit features. Only `mark-passing` (and other
script subcommands) may change `feature_list.json`. Removing or rewriting a
feature by hand to "mark it done" is unacceptable — it could lead to missing
or buggy functionality.

### 5. Commit Your Changes

Make a git commit with a descriptive message:
```bash
git add .
git commit -m "Implement: [feature description]"
```

Example: `git commit -m "Implement: New chat button creates a fresh conversation"`

### 6. Update Progress File

Update `claude-progress.txt` with what you accomplished:

```
Session N - Coding Agent
- Worked on: [feature description]
- Status: Implemented and tested
- Features now passing: [count]

Changes made:
- [Brief description of code changes]

Next session should:
- [Suggestion for what to work on next]
```

## Important Guidelines

### Incremental Progress
- Work on ONE feature at a time
- Do NOT try to implement multiple features in one session
- If you finish one feature early and have context left, you may start a second feature, but test and commit each one separately

### Testing
- Always test before marking features as passing
- Test as a human user would, not just as a developer
- Use browser automation tools for web applications
- If you find bugs during testing, fix them before moving on

### Clean State
- Leave the code in a state that could be merged to main
- No major bugs
- Code is orderly and well-documented
- A developer could easily begin work on a new feature

### Error Recovery
- If you break something, use git to revert: `git revert` or `git reset`
- Always verify basic functionality before implementing new features
- If the app is broken, fix it before implementing new features

## Common Failure Modes and How to Avoid Them

| Problem | How to Avoid |
|---------|--------------|
| Marking features as done prematurely | Test thoroughly end-to-end before changing `passes` to `true` |
| Leaving the environment broken | Always run basic tests before implementing new features |
| Trying to do too much at once | Work on one feature at a time |
| Not documenting progress | Always commit with descriptive messages and update `claude-progress.txt` |
| Removing or editing features | Only change the `passes` field in `feature_list.json` |

## Completion Checklist for Each Session

- [ ] Read and understood progress documentation
- [ ] Reviewed git history
- [ ] Started development server
- [ ] Verified basic functionality works
- [ ] Chose one feature to implement
- [ ] Implemented the feature
- [ ] Tested the feature end-to-end
- [ ] Marked feature as passing in `feature_list.json`
- [ ] Committed changes with descriptive message
- [ ] Updated `claude-progress.txt`

## When to Stop

You should stop when:
- You have successfully implemented and tested at least one feature
- The code is in a clean, working state
- Your progress is committed and documented

Even if you have context remaining, it's better to leave the environment clean for the next session than to push too far and potentially break something.
```

---

### File 8: `init.sh`

```bash
#!/bin/bash

# init.sh - Development server startup and testing script
# This script should be customized based on your specific project

set -e  # Exit on error

echo "=========================================="
echo "Starting Development Environment"
echo "=========================================="

# Navigate to the script's directory (in case it's called from elsewhere)
cd "$(dirname "$0")"

# INSTALL DEPENDENCIES (if needed)
echo "Checking dependencies..."
# Uncomment and adjust for your project:
# npm install
# pip install -r requirements.txt
# cargo build
echo "Dependencies are ready."

# START DEVELOPMENT SERVER
echo "Starting development server..."

# For Node.js projects:
# npm run dev &
# SERVER_PID=$!

# For Python projects:
# python manage.py runserver &
# SERVER_PID=$!

# For other projects, adjust accordingly

echo "Waiting for server to be ready..."
sleep 5

# BASIC END-TO-END TEST
echo ""
echo "=========================================="
echo "Running Basic End-to-End Test"
echo "=========================================="

# Add your basic testing commands here

# Example for web applications:
# echo "1. Checking if server is responding..."
# curl -f http://localhost:3000 || exit 1
#
# echo "2. Testing basic functionality..."
# curl -X POST http://localhost:3000/api/test || exit 1

echo "✓ Basic test passed!"

# CLEANUP
echo ""
echo "=========================================="
echo "Development environment is ready!"
echo "=========================================="
echo "Server PID: $SERVER_PID"
echo "Press Ctrl+C to stop the server"

# Keep the server running
wait $SERVER_PID
```

---

### File 9: `feature_list.json`

A fragile data file. **Never edit it directly** — all mutations go through
`tools/feature_list.py` (file 11). Writing this file with the Edit/Write tool
is forbidden by CODE_STYLE.md Hard Rules.

```json
{
  "project_name": "Your Project Name",
  "description": "Brief description of the project",
  "features": [
    {
      "id": "feat-001",
      "category": "functional",
      "description": "Example feature description",
      "steps": [
        "Step 1: Navigate to the main interface",
        "Step 2: Perform the action",
        "Step 3: Verify the expected result"
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

---

### File 10: `tools/feature_list.py`

The mandatory interface to `feature_list.json`. Create the `tools/` directory
if it does not exist, then write this Python script into it. The script
ships as-is from the harness — do not modify it during scaffold.

```python
#!/usr/bin/env python3
"""feature_list.py — the only way to mutate feature_list.json.

This script is the mandatory interface for any operation on
feature_list.json: listing features, marking them passing, adding new
features, and updating metadata. Direct editing of feature_list.json
(scripts, sed, manual) is a Hard Rule violation in CODE_STYLE.md.

All commands are read-modify-write on the same JSON file and keep the
file's formatting (2-space indent). The script exits non-zero on errors
so coding agents can detect failures.

Usage:
    python tools/feature_list.py <command> [args]

Commands:
    list
        Print every feature as one line (id, category, passes, priority,
        description). Useful for agents or humans to scan.

    mark-passing <feature_id>
        Set the feature's "passes" to true. Recomputes metadata
        (total_features / passing / failing / last_updated). Refuses
        if the id does not exist or the feature already passes.

    add <feature_id> <category> <description>
        Append a new feature with the given id, category, and a
        single-line description. Generates empty steps[] and sets
        passes=false. Refuses on duplicate id.

    update-metadata
        Recompute total_features / passing / failing from the current
        features[] and stamp last_updated to today. Use this after any
        manual repair (rare) or to force a freshness update.

Categories: functional, ui, error-handling, accessibility, performance.
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date
from pathlib import Path
from typing import Any

FEATURE_LIST_PATH = Path("feature_list.json")
VALID_CATEGORIES = {"functional", "ui", "error-handling", "accessibility", "performance"}
INDENT = 2


# ---------- I/O helpers ----------

def load_features() -> dict[str, Any]:
    """Read feature_list.json. Exits with a clear error if missing or malformed."""
    if not FEATURE_LIST_PATH.exists():
        fail(f"{FEATURE_LIST_PATH} not found. Are you in the project root?")
    try:
        with FEATURE_LIST_PATH.open("r", encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        fail(f"{FEATURE_LIST_PATH} is not valid JSON: {e}")
    if "features" not in data or not isinstance(data["features"], list):
        fail(f"{FEATURE_LIST_PATH} must contain a 'features' array.")
    return data


def save_features(data: dict[str, Any]) -> None:
    """Write feature_list.json with stable formatting."""
    with FEATURE_LIST_PATH.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=INDENT, ensure_ascii=False)
        f.write("\n")


def recompute_metadata(data: dict[str, Any]) -> None:
    """Recompute aggregate counters and stamp last_updated."""
    features = data["features"]
    data["metadata"] = {
        "total_features": len(features),
        "passing": sum(1 for f in features if f.get("passes") is True),
        "failing": sum(1 for f in features if f.get("passes") is False),
        "last_updated": date.today().isoformat(),
    }


# ---------- commands ----------

def cmd_list(_: argparse.Namespace) -> None:
    data = load_features()
    if not data["features"]:
        print("(no features yet)")
        return
    for f in data["features"]:
        marker = "x" if f.get("passes") else " "
        print(
            f"[{marker}] {f.get('id', '???'):<12} "
            f"{f.get('category', '???'):<16} "
            f"pri={f.get('priority', '-'):<6} {f.get('description', '')}"
        )


def cmd_mark_passing(args: argparse.Namespace) -> None:
    data = load_features()
    target_id = args.feature_id
    for f in data["features"]:
        if f.get("id") == target_id:
            if f.get("passes") is True:
                fail(f"feature {target_id!r} already passes.")
            f["passes"] = True
            recompute_metadata(data)
            save_features(data)
            print(
                f"marked {target_id} passing "
                f"({data['metadata']['passing']}/{data['metadata']['total_features']} now passing)"
            )
            return
    fail(f"feature id {target_id!r} not found.")


def cmd_add(args: argparse.Namespace) -> None:
    data = load_features()
    new_id = args.feature_id
    category = args.category
    if category not in VALID_CATEGORIES:
        fail(f"invalid category {category!r}. Choose one of: {sorted(VALID_CATEGORIES)}")
    if any(f.get("id") == new_id for f in data["features"]):
        fail(f"feature id {new_id!r} already exists.")
    data["features"].append({
        "id": new_id,
        "category": category,
        "description": args.description,
        "steps": [],
        "passes": False,
        "priority": args.priority or "medium",
    })
    recompute_metadata(data)
    save_features(data)
    print(f"added feature {new_id} ({category})")


def cmd_update_metadata(_: argparse.Namespace) -> None:
    data = load_features()
    recompute_metadata(data)
    save_features(data)
    print(f"metadata updated: {data['metadata']}")


# ---------- entry point ----------

def fail(msg: str) -> None:
    """Print an error to stderr and exit with a non-zero status."""
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="feature_list.py",
        description="Mandatory interface to feature_list.json. "
                    "Direct edits are forbidden by CODE_STYLE.md.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list", help="Print all features.")
    p_list.set_defaults(func=cmd_list)

    p_pass = sub.add_parser("mark-passing", help="Mark a feature passes=true.")
    p_pass.add_argument("feature_id")
    p_pass.set_defaults(func=cmd_mark_passing)

    p_add = sub.add_parser("add", help="Append a new feature.")
    p_add.add_argument("feature_id")
    p_add.add_argument("category", choices=sorted(VALID_CATEGORIES))
    p_add.add_argument("description")
    p_add.add_argument("--priority", choices=["high", "medium", "low"],
                       help="Default: medium")
    p_add.set_defaults(func=cmd_add)

    p_meta = sub.add_parser("update-metadata",
                            help="Recompute metadata (use after manual edits).")
    p_meta.set_defaults(func=cmd_update_metadata)

    return parser


def main(argv: list[str] | None = None) -> int:
    argv = argv if argv is not None else sys.argv[1:]
    if not argv:
        fail("no command given. Try: list / mark-passing / add / update-metadata")
    parser = build_parser()
    args = parser.parse_args(argv)
    args.func(args)
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

After writing the script, run `python tools/feature_list.py list` once to confirm
the script works against the freshly written `feature_list.json`. The output
should list exactly one feature (the example `feat-001`) with a blank
`[ ]` marker.

---

### File 11: `claude-progress.txt`

```
PROJECT PROGRESS LOG
====================

Project: [Project Name]
Started: [Date]

SESSION 0 - Initializer Agent
-----------------------------
Date: [Date]
Accomplishments:
- Set up project structure
- Created feature_list.json with [count] features
- Created init.sh for development server and testing
- Initialized git repository
- Made initial commit

Feature Status:
- Total features: [count]
- Passing: 0
- Failing: [count]

Next Steps:
- Coding agents should start working on the highest-priority failing features
- Run init.sh before implementing new features
- Test thoroughly before marking features as passing

---

SESSION N - Coding Agent
-----------------------
Date: [Date]
Worked on: [Feature description]
Status: [Implemented / Fixed / Tested]
Features now passing: [count]

Changes made:
- [Brief description]

Next session should:
- [Suggestion]

---

SUMMARY
-------
Total Sessions: N
Features Completed: X / Y
```

---

### Completion summary

After scaffolding, output this checklist to the user:

```
Harness scaffolded at <target-path>.

Eleven files written:
  Document layer (agent-agnostic):
    - _AGENT.md                  (document index — start here)
    - HARNESS.md                 (harness workflow rules + per-file usage)
    - CODE_STYLE.md              (code style — Part 1 hard rules + Part 2 fill-in)
  Agent entry points:
    - CLAUDE.md                  (entry point for Claude Code)
    - AGENT.md                   (entry point for other agents)
  Workflow files:
    - INITIALIZER_PROMPT.md      (give to the FIRST agent session)
    - CODING_AGENT_PROMPT.md     (give to SUBSEQUENT agent sessions)
    - init.sh                    (template — fill in your startup commands)
    - feature_list.json          (empty — add your features, all "passes": false)
    - tools/feature_list.py      (mandatory script — never edit feature_list.json by hand)
    - claude-progress.txt        (progress log — update each session)

Git initialized with initial commit.

Now YOU (the user) need to:
  1. Read HARNESS.md end-to-end — it explains every file's role and the rules.
  2. Read CODE_STYLE.md Part 1 (hard rules) and fill in Part 2 ([fill-in] placeholders)
     with your project's rules BEFORE any coding agent starts work.
  3. Edit init.sh: uncomment / fill in the startup commands for YOUR tech stack.
  4. Edit feature_list.json (or run `python tools/feature_list.py add ...`) to
     list your features with detailed testable steps. Every feature starts
     with "passes": false. NEVER remove features.
  5. Edit claude-progress.txt "Project:" and "Started:" fields.
  6. Run `python tools/feature_list.py list` once to confirm the script works.
  7. Run `bash init.sh` once to confirm your startup commands work.

Then start your first coding session by giving the agent
CODING_AGENT_PROMPT.md along with the project requirements.

RULES THE USER (AND EVERY AGENT) MUST FOLLOW:
  - Every agent must read _AGENT.md before doing anything. _AGENT.md routes
    you to HARNESS.md (for harness workflow) or CODE_STYLE.md (for coding).
  - Work on ONE feature per session.
  - Test end-to-end before marking a feature passing.
  - Never edit feature_list.json by hand. Always go through
    `python tools/feature_list.py <subcommand>`. The script enforces id
    uniqueness, category whitelist, and metadata consistency.
  - Update claude-progress.txt at the end of each session.
  - Commit with descriptive messages; one commit per feature.
```

---

## What this skill does NOT do

- Does NOT pick a tech stack, language, or framework.
- Does NOT generate feature ideas or a feature list.
- Does NOT implement any code beyond the ten scaffolding files.
- Does NOT modify the user's existing application code.
- Does NOT install dependencies or run the user's app.
- Does NOT make decisions about test tools, lint config, or build systems.

## Failure modes to avoid

| Symptom | Cause | Prevention |
|---------|-------|------------|
| Skill invents features | Misread "rule-making" as "code generation" | Hard rule: `features: []` is the only valid initial state. |
| Skill picks a tech stack | Misread scaffolding as setup | Hard rule: only ask for target directory; everything else is placeholder. |
| Skill overwrites existing harness | Confused new scaffold with re-scaffold | Always check for any of `_AGENT.md`, `HARNESS.md`, `CODING_AGENT_PROMPT.md`; warn before overwriting. |
| Skill runs `git init` in user's home dir | Forgot to verify target path is sane | Confirm target path with user before any write or shell command. |