---
name: iterative-dev
description: Manage long-running AI agent development projects with incremental progress, scoped features, and verification. Works with any project type — web, API, CLI, library, data pipeline, mobile. Use this skill when working on multi-session projects, implementing features incrementally, running tests, initializing project scopes, or continuing work from previous sessions. Triggers on phrases like "continue working", "pick up where I left off", "next feature", "run tests", "verify", "initialize scope", "switch scope", "feature list", "incremental progress", or any multi-session development workflow.
---

# Iterative Development Workflow

Autonomous, incremental development with quality gates. One feature at a time. Implement → verify → refine → next.

## Core Loop

```
FOR each feature (highest priority first):
    1. IMPLEMENT  — launch subagent to build, test, and commit
    2. VERIFY     — parent checks: commit exists, screenshots exist (web), tests prove outcomes
    3. REFINE     — launch subagent to polish UX + code quality, write report, commit
    4. NEXT       — immediately proceed to next feature
```

**All three steps are mandatory. Skipping refinement is as wrong as skipping verification.**

## Principles

1. ONE feature at a time — finish, test, commit before moving on
2. `feature_list.json` is the single source of truth — see `references/core/feature-list-format.md`
3. Git commit after every feature and every refinement
4. Autonomous execution — never stop to ask the human, the human may be asleep
5. Subagent per feature — isolation prevents context overflow
6. Verification is non-negotiable — every feature proven working per project type
7. Refinement is non-negotiable — every feature polished for delight, not just function
8. Standards are auditable — quality lives in reference docs, verified systematically

## Project Types

| Type | Verification | Extra Standards |
|------|-------------|-----------------|
| **web** | Playwright E2E + screenshots | `web/ux-standards.md`, `web/frontend-design.md` |
| **api** | Integration tests + endpoint validation | — |
| **cli** | Command execution + output validation | — |
| **library** | Unit tests + public API validation | — |
| **data** | Transformation tests + data quality | — |
| **mobile** | Mobile E2E + screenshots | `web/ux-standards.md` (adapted) |

---

## Workflow: Initialize Scope

### Directory Structure
```
project-root/
├── specs/{scope}/
│   ├── spec.md, feature_list.json, progress.txt
│   ├── screenshots/
│   └── refinements/
├── .active-scope
├── spec.md → specs/{scope}/spec.md        (symlink)
├── feature_list.json → specs/{scope}/...  (symlink)
├── progress.txt → specs/{scope}/...       (symlink)
└── init.sh
```

### Steps

1. **Check state**: `ls specs/ && cat .active-scope`
2. **Create scope**: `mkdir -p specs/{scope}/{screenshots,refinements}`, write `spec.md`
3. **Switch**: `echo "{scope}" > .active-scope`, create symlinks
4. **Determine project type**: Browser→web, Terminal→cli, Import→library, HTTP→api, Phone→mobile, Data→data
5. **Create feature list** — two methods:
   - **New features**: Follow `references/core/feature-list-format.md`
   - **Constitution/standards alignment**: Follow `references/core/constitution-audit.md`

   **Critical rules for features:**
   - Outcome-oriented (what user can DO, not what components exist)
   - Full-stack vertical slices (backend + frontend together) — see feature-list-format.md
   - Self-contained (each feature includes its own tests — no separate "testing" features)
   - UI features MUST include screenshot + interaction test steps
   - Include `"type"` field in feature_list.json
6. **Create init.sh** — see `references/core/init-script-template.md`
7. **Commit**

---

## Workflow: Continue Session

### Startup

```bash
pwd && cat progress.txt && cat feature_list.json && git log --oneline -20
bash init.sh
```

Verify existing features work before implementing new ones.

### Feature Loop (NON-STOP until all features pass)

**Never stop to report progress. Never ask the human. Keep going until done.**

For each incomplete feature (highest priority first):

#### Step 1: IMPLEMENT

Read `references/templates/feature-subagent.md` for the full prompt template. Launch via Agent tool.

**Reference doc paths**: The `references/` directory is in THIS SKILL's install directory, not the project. Resolve to absolute paths using `{skill_base_dir}` shown at top of this prompt.

#### Step 2: VERIFY (parent agent — mandatory gates)

After the implementation subagent completes:

a. **Commit gate**: `git log --oneline -1` — confirm `feat:` commit exists
b. **Feature list gate**: confirm `"passes": true` in feature_list.json
c. **Type-specific gate**:

| Type | Gate |
|------|------|
| web/mobile | **Screenshot gate**: `ls specs/{scope}/screenshots/feature-{id}-*.png \| wc -l` — if 0, BLOCK and launch screenshot subagent. If >0, spot-check one with Read tool. **Outcome test gate**: verify tests perform user actions (not just screenshots). |
| web full-stack | **Integration smoke test**: verify backend responds (not 404), verify CORS headers, verify screenshots show real data (not loading spinners). See `references/verification/web-verification.md`. |
| api | Verify integration tests exist and cover error cases |
| cli | Smoke test: `./bin/{tool} --help` |
| library | All tests pass including race detection |
| data | Transformation tests cover edge cases |

d. If any gate fails, launch a fix subagent before proceeding.

#### Step 3: REFINE (mandatory — not optional)

Read `references/templates/refinement-subagent.md` for the full prompt template. Launch via Agent tool.

**Why refinement exists**: Implementation subagents build features that *work*. Refinement subagents make features *delightful*. Without refinement, UX issues (spacing, hierarchy, micro-interactions) and code smells (duplication, naming, complexity) ship uncaught. It's the quality difference between "functional" and "users love it".

**Refinement gate** (parent must verify after subagent completes):
```bash
# Report must exist
ls specs/{scope}/refinements/feature-{id}-refinement.md
# Commit must exist
git log --oneline -1 | grep "refine:"
```
If either is missing, launch the refinement subagent again. Do NOT proceed without refinement.

#### Step 4: NEXT

Loop back immediately to the next incomplete feature. No pausing, no reporting.

### Periodic Standards Audit

**When**: Every 5 features AND at session end.

For each applicable standards doc, launch audit subagent (see `references/templates/audit-subagent.md`). Fix violations before proceeding.

Applicable standards by type:
- **All**: `core/code-quality.md`, `core/gitignore-standards.md`, `core/session-handoff-standards.md`
- **web/mobile**: also `web/ux-standards.md`, `web/frontend-design.md`

### Session End

Only end when ALL features have `"passes": true` and all refinements are committed, or a truly unrecoverable error occurs.

Before ending: final standards audit, run all tests, verify `references/core/session-handoff-standards.md`.

---

## Decision Making (autonomous — human may be asleep)

| Situation | Decision |
|-----------|----------|
| Ambiguous spec | Simplest reasonable interpretation |
| Multiple approaches | Match existing patterns |
| Test is flaky | Fix with proper waits, don't skip |
| Feature too large | Break into sub-tasks within subagent |
| Build/dependency error | Read error, fix, rebuild |
| Port conflict | Kill conflicting process, restart |
| Feature blocked | Skip to next, come back later |
| Tempted to skip refinement | NEVER skip — launch it |
| Web: frontend loads forever | Check CORS + route prefix |
| Web: curl works, browser doesn't | CORS middleware missing |
| Web: backend 404 on /api/v1/ | Mount handler under correct prefix |

---

## Reference Files

### Templates (subagent prompts)
- `references/templates/feature-subagent.md` — Implementation subagent prompt
- `references/templates/refinement-subagent.md` — Refinement subagent prompt
- `references/templates/audit-subagent.md` — Standards audit subagent prompt

### Core Standards (all types)
- `references/core/code-quality.md` — File organization, testability, unit testing
- `references/core/gitignore-standards.md` — Files that must never be committed
- `references/core/feature-list-format.md` — Feature list structure and rules
- `references/core/session-handoff-standards.md` — Clean state at session end
- `references/core/init-script-template.md` — init.sh templates by project type
- `references/core/constitution-audit.md` — Audit workflow for compliance scopes

### Web Standards (web/mobile)
- `references/web/ux-standards.md` — Loading/empty/error states, responsive, accessibility
- `references/web/frontend-design.md` — Typography, color, composition

### Verification (one per type)
- `references/verification/{web,api,cli,library,data,mobile}-verification.md`
