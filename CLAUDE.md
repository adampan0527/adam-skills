# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin marketplace containing Adam's personal skill collection. The repo follows the official Claude Code plugin structure and can be installed via `/plugin marketplace add`.

## Repository Structure

```
adam-skills/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace catalog (required for /plugin)
├── plugins/
│   └── adam-skills/
│       ├── .claude-plugin/
│       │   └── plugin.json      # Plugin manifest (required)
│       └── skills/
│           └── <skill-name>/
│               └── SKILL.md     # Skill definition with YAML frontmatter
├── skills/                      # Source/development copies of skills (not used by plugin system)
├── CLAUDE.md
├── LICENSE
├── README.md
└── README_CN.md
```

## Key Conventions

### Plugin System Files

- `.claude-plugin/marketplace.json` — marketplace index, lists all plugins with their `source` paths
- `.claude-plugin/plugin.json` — per-plugin manifest (name, version, description)
- Skills must be placed under `plugins/<plugin>/skills/<name>/SKILL.md` to be recognized by the plugin system

### Skill Files (SKILL.md)

- Each skill lives in `plugins/adam-skills/skills/<skill-name>/SKILL.md`
- Skill directory names are lowercase, hyphenated (e.g., `css-animations`, `smart-search`)
- Each SKILL.md must start with YAML frontmatter containing `name` and `description`
- The `description` field controls when Claude Code auto-selects the skill

### Skill File Template

```markdown
---
name: skill-name
description: Short description of what this skill does and when to use it.
---

# Skill Name

[Instructions for the skill go here.]
```

## Adding a New Skill

1. Create the skill directory:
   ```bash
   mkdir -p plugins/adam-skills/skills/<skill-name>
   ```
2. Create `SKILL.md` using the template above
3. Ensure the `description` field clearly states when the skill should be triggered
4. Test by invoking `/<skill-name>` in Claude Code

## Notes

- The `skills/` directory at the repo root is for development/reference copies only; the plugin system reads from `plugins/adam-skills/skills/`
- Skills should be concise and actionable
- Keep each skill focused on a single domain or task pattern
