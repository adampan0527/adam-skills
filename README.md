# Adam's Skills

A personal skill library for [Claude Code](https://claude.ai/code), distributed as a plugin marketplace. Each skill is a `SKILL.md` file triggered via `/<skill-name>` in Claude Code sessions, injecting domain-specific workflows and knowledge.

[中文说明](README_CN.md)

## Installation

**Step 1 — Add the marketplace source (one-time):**

In Claude Code, run:

```
/plugin marketplace add adampan0527/adam-skills
```

**Step 2 — Install the plugin:**

```
/plugin install edu@adam-skills
```

**Step 3 — Restart Claude Code to load the new plugin.**

Once installed, all skills are registered as slash commands. Type `/<skill-name>` to use any skill.

### Other Plugin Commands

```bash
# Update to the latest version
/plugin update edu@adam-skills

# List installed plugins
/plugin list

# View plugin details
/plugin details edu@adam-skills
```

---

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Edu Web PowerPoint | `/edu-web-powerpoint` | From a lesson PDF/Word or an outline of key points, generate a click-driven 16:9 web presentation (web-ppt) with hands-on exercises |

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

1. Enter an empty directory (or let Claude create one)
2. Type `/edu-web-powerpoint`, then describe what you need:
   - Provide a path to a lesson PDF, or
   - Provide key points + outline text
3. Follow the prompts to align content, outline, theme style, then start generating

---

## For Developers: Adding a New Skill

If you want to fork this repo to create your own skills:

### 1. Create the skill directory

```bash
mkdir -p plugins/edu/skills/<skill-name>
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
- **Description matters** — Claude uses this field to decide when to auto-select the skill.
- **Self-contained** — skills are expanded into the conversation independently; include all necessary context.

### 4. Test

Type `/<skill-name>` in Claude Code to test.

---

## License

[MIT](LICENSE) &copy; Yan Pan
