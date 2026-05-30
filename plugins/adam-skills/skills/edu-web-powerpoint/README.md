# Edu Web PowerPoint Skill

**A method-driven agent skill for turning knowledge points and outlines into click-driven 16:9 educational web presentations with hands-on exercise cases.**

[中文文档](./README.zh-CN.md)

---

## What Is This?

`edu-web-powerpoint` (ewp) helps an agent build a Vite + React + TypeScript presentation designed for educational use. Each click advances one teaching beat, each step owns the whole 1920×1080 stage, and the progress UI stays hidden unless hovered.

It is designed for:

- Turning a lesson plan PDF / Word document into a classroom-ready web presentation
- Turning a knowledge point + outline into a classroom-ready web presentation
- Creating training materials, tech talks, and courseware
- Managing case studies: embedded demos in the presentation + standalone hands-on exercises
- Building "dynamic PPT, but not PPT" experiences with strong motion and pacing

The skill is primarily a **methodology and collaboration workflow**. The scaffold supplies reusable tokens, stage primitives, themes, and examples, but each project should still choose a visual language that fits the topic.

---

## Core Ideas

- **Fixed 16:9 stage** — content authored in a stable 1920×1080 coordinate system.
- **One global step cursor** — click or keyboard advances `(chapter, step)`.
- **One step, one idea** — every beat gets a focused full-screen scene.
- **Teaching beats drive structure** — teaching rhythm maps directly to visual steps.
- **Hidden chrome** — progress controls are hover-only.
- **Motion first** — each scene needs a moving visual anchor.
- **Theme tokens** — visual decisions flow through semantic tokens.
- **Case management** — cases from the outline are split into embedded demos and hands-on exercises.
- **Hard checkpoints** — the agent pauses for user alignment at key stages.

---

## Workflow

```text
Phase 0    Document preprocessing (optional)
           PDF / Word → markitdown → markdown → knowledge.md
   |
Phase 1.1  Identify input (knowledge point + outline)
Phase 1.2  One-shot: teach-script.md + outline.md
   |
Checkpoint Plan  Content / outline / theme / cases / dev mode
   |
Phase 2    Build the Vite / React / TS presentation
   |
Phase 3    Generate hands-on case folder
   |
Phase 4    Delivery
```

---

## What It Ships

```text
skills/edu-web-powerpoint/
├── SKILL.md
├── README.md / README.zh-CN.md
├── manifest.json
├── references/
│   ├── PRINCIPLES.md
│   ├── CHAPTER-CRAFT.md
│   ├── OUTLINE-FORMAT.md
│   ├── SCRIPT-STYLE.md
│   ├── INPUT-PREPROCESSING.md
│   ├── CASES.md
│   ├── THEMES.md
│   └── EXAMPLES/
├── scripts/
│   └── scaffold.sh
├── templates/
│   ├── index.html
│   ├── vite.config.ts
│   ├── case/
│   │   └── README.md
│   └── src/
└── themes/                    # 12 educational themes
    ├── academic-blue/
    ├── chalkboard/
    ├── clean-lecture/
    └── ...
```

---

## Quick Start

Copy the skill into the directory your agent scans, then ask it to turn a knowledge point and outline into an educational web-ppt.

To scaffold manually:

```bash
bash skills/edu-web-powerpoint/scripts/scaffold.sh ./presentation --theme=academic-blue
```

List available themes:

```bash
bash skills/edu-web-powerpoint/scripts/scaffold.sh --list-themes
```

---

## Built-In Themes

The skill ships **12 themes** for educational use:

| id | Style | Best For |
|---|---|---|
| `academic-blue` | Classic academic blue | University lectures, formal training |
| `chalkboard` | Chalk on blackboard | Math, physics, traditional teaching |
| `clean-lecture` | Clean modern white | Corporate training, tech talks |
| `code-terminal` | Dark terminal green | Programming courses, CS education |
| `geometric-bold` | Bold geometric | Design courses, visual teaching |
| `handwritten` | Warm handwritten | Informal teaching, tutoring |
| `ink-wash` | Chinese ink wash | Literature, history, culture |
| `light-board` | Light board blue | Engineering, architecture |
| `magazine` | Editorial magazine | Journalism, media studies |
| `notebook` | Paper notebook | Study notes, review sessions |
| `science-paper` | Academic paper | Science courses, research presentations |
| `warm-education` | Warm and friendly | K-12, onboarding, soft skills |

See [THEMES.md](./references/THEMES.md) for the full token contract and how to derive new themes.

---

## Reference Map

- [INPUT-PREPROCESSING.md](./references/INPUT-PREPROCESSING.md) — PDF / Word lesson plan preprocessing via markitdown
- [PRINCIPLES.md](./references/PRINCIPLES.md) — core rules for educational web presentations
- [CHAPTER-CRAFT.md](./references/CHAPTER-CRAFT.md) — chapter implementation rules and visual checklist
- [OUTLINE-FORMAT.md](./references/OUTLINE-FORMAT.md) — required outline structure with case list
- [SCRIPT-STYLE.md](./references/SCRIPT-STYLE.md) — knowledge-to-teaching-script guidance
- [CASES.md](./references/CASES.md) — case management system (embedded demos + hands-on exercises)
- [THEMES.md](./references/THEMES.md) — theme token contract and built-in themes
