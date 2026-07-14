# Long-Running Agent Harness

A system for enabling AI agents to work effectively across multiple context windows on complex, long-running projects.

## Overview

This harness implements the architecture described in Anthropic's article [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).

### Key Components

1. **Initializer Agent** - Sets up the initial environment on the first run
2. **Coding Agent** - Makes incremental progress in every session
3. **Environment Management** - Structured files for tracking progress and requirements

## Architecture

### Two-Part Solution

The system addresses the challenge of long-running agents with two agent types:

#### 1. Initializer Agent
- Runs once at project start
- Sets up the project structure
- Creates `init.sh` script for development and testing
- Creates comprehensive `feature_list.json` with all requirements
- Initializes git repository
- Creates `claude-progress.txt` for documentation

#### 2. Coding Agent
- Runs in subsequent sessions
- Starts each session by reading progress files and git history
- Starts development server and verifies basic functionality
- Works on ONE feature at a time
- Tests features end-to-end before marking as complete
- Commits changes and updates progress file

## File Structure

```
your-project/
├── INITIALIZER_PROMPT.md      # Instructions for the first agent session
├── CODING_AGENT_PROMPT.md     # Instructions for subsequent sessions
├── init.sh                    # Development server and testing script
├── claude-progress.txt        # Progress log updated each session
├── feature_list.json          # Comprehensive feature requirements
├── CLAUDE.md                  # Project-specific documentation
└── [project files]
```

## How to Use

### First Session (Initializer)

1. Give the agent the prompt from `INITIALIZER_PROMPT.md`
2. Provide the high-level project requirements
3. The agent will set up:
   - Project structure
   - `init.sh` script
   - `feature_list.json` with all features marked as failing
   - Git repository with initial commit
   - `claude-progress.txt` with initial documentation

### Subsequent Sessions (Coding Agent)

1. Give the agent the prompt from `CODING_AGENT_PROMPT.md`
2. The agent will:
   - Read progress files and git history
   - Start the development server
   - Verify basic functionality
   - Choose and implement one feature
   - Test thoroughly
   - Commit changes and update progress file

## Key Principles

### Incremental Progress
- Work on one feature at a time
- Make small, verifiable changes
- Leave environment in a clean state

### Testing
- Always test end-to-end before marking features as complete
- Test as a human user would
- Use browser automation for web applications

### Documentation
- Commit changes with descriptive messages
- Update `claude-progress.txt` each session
- Maintain clear git history

### Error Recovery
- Use git to revert bad changes
- Always verify basic functionality before implementing new features
- Fix existing bugs before adding new features

## Templates

This repository includes template files that should be customized:

- `template_init.sh` - Template for the development server script
- `template_feature_list.json` - Template for the feature list
- `template_claude-progress.txt` - Template for the progress log

## Common Agent Failure Modes and Solutions

| Problem | Initializer Solution | Coding Agent Solution |
|---------|---------------------|---------------------|
| Declares victory too early | Set up feature list with all requirements | Read feature list, work on one feature at a time |
| Leaves environment broken | Set up git repo and progress notes | Read progress notes, test before new features |
| Marks features done prematurely | Set up feature list | Self-verify thoroughly before marking passing |
| Wastes time figuring out how to run app | Write `init.sh` script | Read `init.sh` at session start |

## References

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) - Anthropic Engineering Blog
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk) - SDK for building agents

## License

MIT
