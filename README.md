# iterative-dev

An AI skill for iterative development with AI agents. Works with **any project type** — web apps, APIs, CLI tools, libraries, data pipelines, and mobile apps. Supports **Claude Code** (with subagents) and **Windsurf**.

## Installation

```bash
npx skills add https://github.com/theplant/iterative-dev
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
- `progress.txt` — Session progress log (symlink to active scope)
- `init.sh` — Development environment setup script

## How It Works (Claude Code)

1. Agent reads `feature_list.json` to find incomplete features and project type
2. For each feature, launches a **subagent** (via Agent tool) with full context
3. Subagent implements the feature, runs type-appropriate verification, and commits
4. Parent agent confirms completion, then **loops back** to pick the next feature
5. Only stops when ALL features have `"passes": true`

## How to Use

### Case 1: Write spec.md yourself, then initialize

Best when you have a clear vision of what to build. Write the spec first, then let the agent set up the scope and generate the feature list.

**Step 1 — Write your spec:**

Create `specs/auth/spec.md` (or any scope name) with your project specification:

```markdown
# Auth System

Build a JWT-based authentication system with:
- User registration with email/password
- Login endpoint returning JWT tokens
- Password reset via email
- Role-based access control (admin, user)
- Rate limiting on auth endpoints
```

**Step 2 — Initialize the scope:**

```
> Initialize scope "auth" using the spec I wrote in specs/auth/spec.md
```

The agent will read your spec, detect the project type, generate `feature_list.json`, create `init.sh`, and commit.

**Step 3 — Continue (every subsequent session):**

```
> Continue working
```

The agent picks up where it left off and implements all remaining features autonomously.

---

### Case 2: Describe what you want, let the agent generate spec.md

Best for brainstorming or when you want the agent to help shape the spec. Just describe your idea in the prompt.

```
> Initialize a new scope called "dashboard". I want a real-time analytics dashboard
> with charts for user signups, revenue, and API usage. It should have date range
> filters, CSV export, and a dark mode toggle. Use React + Recharts.
```

The agent will:
1. Create `specs/dashboard/spec.md` from your description
2. Detect project type (web)
3. Generate `feature_list.json` with prioritized features
4. Create `init.sh` with the right dev environment setup
5. Commit everything

Then continue in subsequent sessions:

```
> Continue working
```

---

### Case 3: Switch between existing scopes

When you have multiple scopes and want to switch context:

```
> Switch to scope "video-editor"
```

The agent updates `.active-scope` and symlinks `spec.md` / `feature_list.json` to the selected scope.

---

### Case 4: Compliance / standards alignment scope

When your scope is about aligning code with a reference document (not building new features):

```
> Initialize a new scope called "standards-alignment" to align our codebase
> with the requirements in AGENTS.md
```

The agent uses the **Constitution Audit Workflow** — it systematically extracts every requirement from the reference document, verifies each against your code, and generates features only from verified violations.

---

### Case 5: Continue a multi-session project

Every session after the first, just say:

```
> Continue working
> Pick up where I left off
> Next feature
```

The agent reads `feature_list.json` and `progress.txt`, runs regression tests, then implements all remaining features in a loop — committing after each one. It won't stop until everything passes.

---

### Typical workflow timeline

```
Session 1:  "Initialize scope 'my-app' — here's what I want to build: ..."
            → Agent creates spec.md, feature_list.json, init.sh

Session 2:  "Continue working"
            → Agent implements features #1–#5, commits each

Session 3:  "Continue working"
            → Agent implements features #6–#12, all pass, scope complete
```

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
