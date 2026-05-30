# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a multi-skill repository for Claude Code. Each skill is a markdown file (`.md`) that provides domain-specific instructions invoked via slash commands in Claude Code. Skills are organized by topic in subdirectories under `skills/`.

## Repository Structure

```
adam-skills/
├── CLAUDE.md
├── skills/
│   ├── <category>/
│   │   ├── <skill-name>.md
│   │   └── ...
│   └── ...
└── ...
```

## Skill File Conventions

- Each skill lives in `skills/<category>/<skill-name>.md`
- Category names are lowercase, hyphenated (e.g., `video`, `animation`, `dev-tools`)
- Skill filenames are lowercase, hyphenated, matching the slash command name
- Each skill file must start with a YAML frontmatter block containing `name` and `description`
- Skill content is written in Markdown and should be self-contained — it will be expanded and injected into the conversation when invoked

## Skill File Template

```markdown
---
name: skill-name
description: Short description of what this skill does and when to use it.
---

# Skill Name

[Instructions for the skill go here.]
```

## Adding a New Skill

1. Choose or create a category under `skills/`
2. Create the `.md` file using the template above
3. Ensure the `description` field clearly states when the skill should be triggered
4. Test by invoking the skill with `/<skill-name>` in Claude Code

## Notes

- Skills should be concise and actionable — avoid verbose explanations
- Keep each skill focused on a single domain or task pattern
- If a skill depends on external tools or APIs, document prerequisites at the top of the file
