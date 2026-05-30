# Adam's Skills

A personal skill library for [Claude Code](https://claude.ai/code). Each skill is a self-contained markdown file that provides domain-specific instructions, invoked as slash commands during Claude Code sessions.

## What Are Skills?

Skills are markdown files (`.md`) that expand into prompts when triggered via `/<skill-name>` in Claude Code. They encapsulate reusable patterns, workflows, and domain knowledge — from animation frameworks to CLI adapters to search utilities.

## Repository Structure

```
adam-skills/
├── CLAUDE.md            # Claude Code project guidance
├── LICENSE              # MIT License
├── README.md
├── README_CN.md         # Chinese version of this file
└── skills/
    ├── <category>/      # e.g. animation, dev-tools, search
    │   ├── skill-a.md
    │   └── skill-b.md
    └── ...
```

## Installation

### Via Claude Code Marketplace (Recommended)

Install directly from within a Claude Code session using the `/plugin` command:

```
/plugin install adampan0527/adam-skills
```

Claude Code will fetch the repository and register all skills under `skills/` automatically. Once installed, the skills are available immediately via slash commands.

To update to the latest version:

```
/plugin update adampan0527/adam-skills
```

To list installed plugins:

```
/plugin list
```

### As a Global Skill Source (CLI)

Add this repository as a skill source via the command line:

```bash
claude skill add https://github.com/adampan0527/adam-skills.git
```

### Manual Setup

Clone the repository and symlink or copy individual skill files into your Claude Code skill directory:

```bash
git clone https://github.com/adampan0527/adam-skills.git
```

## Usage

Once installed, invoke any skill with its slash command in a Claude Code session:

```
/<skill-name>
```

For example, if you have a skill named `gsap` under `skills/animation/`:

```
/gsap
```

## Creating a New Skill

1. Choose or create a category directory under `skills/`:

   ```bash
   mkdir -p skills/<category>
   ```

2. Create a new markdown file with the skill name:

   ```bash
   touch skills/<category>/<skill-name>.md
   ```

3. Add the required frontmatter and content:

   ```markdown
   ---
   name: skill-name
   description: Short description of when and why to use this skill.
   ---

   # Skill Name

   [Instructions, patterns, and reference material go here.]
   ```

4. Test by invoking `/<skill-name>` in Claude Code.

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
