# iterative-dev

An AI skill for iterative development with AI agents. Works with **any project type** — web apps, APIs, CLI tools, libraries, data pipelines, and mobile apps. Supports **Claude Code** (with subagents) and **Windsurf**.

## Installation

```bash
npx skills add https://github.com/sunfmin/iterative-web-dev
```

## Overview

This skill provides a complete workflow for AI agents working on long-running development projects across multiple sessions. It ensures **incremental, reliable progress** with proper handoffs between sessions.

### Supported Project Types

| Type | Verification Strategy |
|------|----------------------|
| **web** | Playwright E2E tests + screenshot visual review |
| **api** | Integration tests + endpoint/response validation |
| **cli** | Command execution tests + output/exit code validation |
| **library** | Unit tests + public API surface validation |
| **data** | Transformation tests + schema/data quality checks |
| **mobile** | Mobile E2E tests (Detox/XCTest/Flutter) + screenshot review |

### Claude Code Features

- **Subagent per feature** — Each feature is implemented in its own subagent using the Agent tool, keeping context clean and isolated
- **Autonomous loop** — The agent keeps working through ALL features without stopping, even if the human is away
- **Self-directed decisions** — Handles ambiguity, errors, and blockers autonomously using decision-making guidelines
- **Commit after each feature** — Every completed feature is committed independently for clean git history
- **Type-aware verification** — Automatically uses the right verification strategy for your project type

## Core Principles

1. **Incremental progress** — Work on ONE feature at a time. Finish, test, and commit before moving on.
2. **Feature list is sacred** — `feature_list.json` is the single source of truth.
3. **Git discipline** — Commit after every completed feature.
4. **Clean handoffs** — Every session ends with committed work and updated progress notes.
5. **Test before build** — Verify existing features work before implementing new ones.
6. **Autonomous execution** — Make all decisions yourself. Never stop to ask the human.
7. **Subagent isolation** — Each feature runs in its own subagent for clean context.

## Workflows

| Workflow | Use When |
|----------|----------|
| **init-scope** | Starting a new scope, switching scopes, or setting up project structure |
| **continue** | Every session after init — implements ALL remaining features with verification built in |

## Key Files

- `spec.md` — Project specification (symlink to active scope)
- `feature_list.json` — Feature tracking with pass/fail status and project type
- `progress.txt` — Session progress log
- `init.sh` — Development environment setup script

## How It Works (Claude Code)

1. Agent reads `feature_list.json` to find incomplete features and project type
2. For each feature, launches a **subagent** (via Agent tool) with full context
3. Subagent implements the feature, runs type-appropriate verification, and commits
4. Parent agent confirms completion, then **loops back** to pick the next feature
5. Only stops when ALL features have `"passes": true`

## Project Structure

```
references/
├── core/                    # All project types
│   ├── code-quality.md
│   ├── gitignore-standards.md
│   ├── feature-list-format.md
│   ├── session-handoff-standards.md
│   ├── constitution-audit.md
│   ├── init-script-template.md
│   └── continue-workflow.md
├── web/                     # Web and mobile projects
│   ├── ux-standards.md
│   └── frontend-design.md
└── verification/            # One per project type
    ├── web-verification.md
    ├── api-verification.md
    ├── cli-verification.md
    ├── library-verification.md
    ├── data-verification.md
    └── mobile-verification.md
```

## License

MIT
