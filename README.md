# Adam's Skills

A personal skill library for [Claude Code](https://claude.ai/code) and [Codex](https://openai.com/codex/), distributed as a plugin marketplace. Each skill is a `SKILL.md` file that the harness auto-selects by its `description`, injecting domain-specific workflows and knowledge.

[中文说明](README_CN.md)

## Installation

This marketplace works on both Claude Code and Codex. Pick your harness below.

### Claude Code

**Step 1 — Add the marketplace source (one-time):**

```
/plugin marketplace add adampan0527/adam-skills
```

**Step 2 — Install the plugin:**

```
/plugin install edu@adam-skills
```

**Step 3 — Restart Claude Code to load the new plugin.**

Once installed, all skills are registered as slash commands. Type `/<skill-name>` to use any skill.

Other plugin commands:

```bash
# Update to the latest version
/plugin update edu@adam-skills

# List installed plugins
/plugin list

# View plugin details
/plugin details edu@adam-skills
```

### Codex

**Step 1 — Add the marketplace source (one-time):**

```bash
codex plugin marketplace add adampan0527/adam-skills
```

**Step 2 — Install the plugin:**

```bash
codex plugin add edu@adam-skills
```

**Step 3 — Restart Codex to load the new plugin.**

Skills are selected automatically from their `description` — no slash command needed. Just ask for what you want, or name the skill directly.

Other plugin commands:

```bash
# List available plugins
codex plugin list

# Refresh a Git marketplace snapshot
codex plugin marketplace upgrade
```

---

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Edu Web PowerPoint | `/edu-web-powerpoint` | From a lesson PDF/Word or an outline of key points, generate a click-driven 16:9 web presentation (web-ppt) with hands-on exercises |

### Other plugins

| Plugin | Description |
|--------|-------------|
| `agent-docs` | On `SessionStart`, creates only `AGENTS.md` with a project overview and documentation index when missing; `docs/*.md` are created on demand. See its own [README](plugins/agent-docs/README.md). |

Install it alongside `edu` with `/plugin install agent-docs@adam-skills` (Claude Code)
or `codex plugin add agent-docs@adam-skills` (Codex).

---

## Skill Details

### `/edu-web-powerpoint`

From a lesson document (PDF / Word) or a key-points outline, generate a "looks like a video" click-driven 16:9 web presentation for teaching.

**Use cases:**
- "I have a lesson PDF, make it into a classroom presentation"
- "I have key points + an outline, make it into a web-ppt"
- Lecture slides, training materials, tech talks
- 16:9 landscape, large text, generous spacing, per-slide animations
- Teaching scenarios that need companion hands-on exercises

**How to use:**

1. Enter an empty directory (or let the assistant create one)
2. Type `/edu-web-powerpoint`, then describe what you need:
   - Provide a path to a lesson PDF, or
   - Provide key points + outline text
3. Follow the prompts to align content, outline, theme style, then start generating

---

## For Developers: Adding a New Skill

If you want to fork this repo to create your own skills:

### 0. Pick the plugin — plugins are domains, not collections

A plugin is a **domain**, and its name is that domain. Don't build a grab bag.

| Plugin | Domain | Put here |
|--------|--------|----------|
| `edu` | Education / teaching | Everything teaching-related |
| `agent-docs` | Agent plumbing | Session hooks, doc scaffolding |

If your skill's audience doesn't match an existing plugin, **create a new plugin**
rather than filing it under the wrong one. Adding a plugin means adding a directory
with both manifests plus a `marketplace.json` entry — see
[docs/conventions.md](docs/conventions.md).

### 1. Create the skill directory

```bash
mkdir -p plugins/<plugin>/skills/<skill-name>
```

### 2. Write SKILL.md

```markdown
---
name: skill-name
description: One sentence explaining what this skill does and when to trigger it.
---

# Skill Name

[Instructions, patterns, and reference material go here.]
```

### 3. Guidelines

- **One skill, one domain** — keep each skill focused on a single task or pattern.
- **Naming** — lowercase, hyphen-separated, e.g. `css-animations`, `smart-search`.
- **Description matters** — both Claude Code and Codex use this field to decide when to auto-select the skill.
- **Description is recall, not documentation** — say what it does and when to use it, not the whole pipeline. Both harnesses inject this field into every session, so keep it under ~300 bytes; execution detail belongs in the body.
- **Self-contained** — skills are expanded into the conversation independently; include all necessary context.

### 4. Test

Type `/<skill-name>` in Claude Code to test, or ask for the skill by name in Codex.

---

## License

[MIT](LICENSE) &copy; Yan Pan
