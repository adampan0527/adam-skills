# Adam's Skills

A personal skill library for [Claude Code](https://claude.ai/code), packaged as a plugin marketplace. Each skill is a self-contained markdown file that provides domain-specific instructions, invoked as slash commands during Claude Code sessions.

## What Are Skills?

Skills are `SKILL.md` files that expand into prompts when triggered via `/<skill-name>` in Claude Code. They encapsulate reusable patterns, workflows, and domain knowledge — from animation frameworks to CLI adapters to search utilities.

## Repository Structure

```
adam-skills/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace catalog
├── plugins/
│   └── adam-skills/
│       ├── .claude-plugin/
│       │   └── plugin.json      # Plugin manifest
│       └── skills/
│           └── <skill-name>/
│               └── SKILL.md     # Skill definition
├── skills/                      # Development copies of skills
├── CLAUDE.md
├── LICENSE
├── README.md
└── README_CN.md
```

## Installation

### Via Claude Code Plugin Marketplace (Recommended)

**Step 1 — Add the marketplace source:**

```
/plugin marketplace add adampan0527/adam-skills
```

This clones the repository and registers it as a known marketplace.

**Step 2 — Install the plugin:**

```
/plugin install adam-skills@adam-skills
```

Claude Code reads `.claude-plugin/marketplace.json`, finds the plugin entry, and registers all skills under `plugins/adam-skills/skills/`.

**Step 3 — Use skills:**

```
/<skill-name>
```

#### Other Plugin Commands

```bash
# Update to the latest version
/plugin update adam-skills@adam-skills

# List installed plugins
/plugin list

# View plugin details
/plugin details adam-skills@adam-skills
```

### Manual Setup

Clone the repository and symlink or copy individual skill files into your Claude Code skill directory:

```bash
git clone https://github.com/adampan0527/adam-skills.git
```

## Creating a New Skill

1. Create the skill directory:

   ```bash
   mkdir -p plugins/adam-skills/skills/<skill-name>
   ```

2. Create `SKILL.md` with the required frontmatter:

   ```markdown
   ---
   name: skill-name
   description: Short description of when and why to use this skill.
   ---

   # Skill Name

   [Instructions, patterns, and reference material go here.]
   ```

3. Test by invoking `/<skill-name>` in Claude Code.

### Guidelines

- **One skill, one domain** — keep each skill focused on a single task or pattern.
- **Lowercase, hyphenated names** — e.g. `css-animations`, `smart-search`.
- **Clear trigger description** — the `description` field determines when Claude Code selects this skill.
- **Self-contained** — include all necessary context; skills are expanded into the conversation independently.

## Skill Categories

| Category       | Description                              |
| -------------- | ---------------------------------------- |
| `animation`    | Animation framework adapters (GSAP, Anime.js, CSS, WAAPI, Three.js) |
| `video`        | Video composition and production workflows |
| `dev-tools`    | CLI adapters, development utilities      |
| `search`       | Web search and information retrieval     |

Categories will expand as new skills are added.

## License

[MIT](LICENSE) &copy; Yan Pan
