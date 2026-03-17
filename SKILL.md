---
name: iterative-dev
description: Manage long-running AI agent development projects with incremental progress, scoped features, and verification. Works with any project type — web, API, CLI, library, data pipeline, mobile. Use this skill when working on multi-session projects, implementing features incrementally, running tests, initializing project scopes, or continuing work from previous sessions. Triggers on phrases like "continue working", "pick up where I left off", "next feature", "run tests", "verify", "initialize scope", "switch scope", "feature list", "incremental progress", or any multi-session development workflow.
---

# Iterative Development Workflow

This skill provides a complete workflow for AI agents working on long-running development projects across multiple sessions. It ensures **incremental, reliable progress** with proper handoffs between sessions. It works with any project type — web apps, APIs, CLI tools, libraries, data pipelines, and mobile apps.

## Core Principles

1. **Incremental progress** — Work on ONE feature at a time. Finish, test, and commit before moving on.
2. **Feature list is sacred** — `feature_list.json` is the single source of truth. See `references/core/feature-list-format.md` for rules.
3. **Git discipline** — Commit after every completed feature. Never leave uncommitted work.
4. **Clean handoffs** — Every session ends meeting `references/core/session-handoff-standards.md`.
5. **Test before build** — Verify existing features work before implementing new ones.
6. **Autonomous execution** — Make all decisions yourself. Never stop to ask the human. The human may be asleep.
7. **Subagent per feature** — Each feature is implemented in its own subagent for isolation and parallelism safety.
8. **Refactor and unit test** — Actively extract logic into testable modules. See `references/core/code-quality.md`.
9. **Verification is non-negotiable** — Every feature MUST be verified using the strategy for its project type. See `references/verification/`.
10. **Standards are auditable** — Quality standards live in reference docs and are systematically verified, not just aspirational checklists.

## Project Types

The skill adapts its verification strategy and applicable standards based on project type. The type is declared in `feature_list.json` or auto-detected during scope init.

| Type | Verification Strategy | Extra Standards |
|------|----------------------|-----------------|
| **web** | E2E screenshots + visual review (Playwright) | `web/ux-standards.md`, `web/frontend-design.md` |
| **api** | Integration tests, endpoint validation, response schemas | — |
| **cli** | Command execution tests, output validation, exit codes | — |
| **library** | Unit tests, public API validation, type checking | — |
| **data** | Transformation tests, schema validation, data quality checks | — |
| **mobile** | E2E screenshots + visual review (Detox/XCTest/Flutter) | `web/ux-standards.md` (adapted) |

## Standards Documents

All verifiable quality standards are extracted into reference docs. These are used both as guidance during implementation and as audit targets for systematic verification.

### Core Standards (all project types)

| Document | What it covers |
|----------|---------------|
| `references/core/code-quality.md` | File organization, testable architecture, unit testing, no duplication |
| `references/core/gitignore-standards.md` | Files that must never be committed |
| `references/core/feature-list-format.md` | Feature list structure, critical rules, priority order |
| `references/core/session-handoff-standards.md` | Clean codebase, git state, progress tracking — verified at session end |

### Web-Specific Standards (type: web, mobile)

| Document | What it covers |
|----------|---------------|
| `references/web/ux-standards.md` | Loading/empty/error states, responsive design, accessibility, forms, tables, navigation |
| `references/web/frontend-design.md` | Typography, color, spatial composition, micro-interactions, anti-patterns |

### Verification Strategies (one per project type)

| Document | For type |
|----------|----------|
| `references/verification/web-verification.md` | web |
| `references/verification/api-verification.md` | api |
| `references/verification/cli-verification.md` | cli |
| `references/verification/library-verification.md` | library |
| `references/verification/data-verification.md` | data |
| `references/verification/mobile-verification.md` | mobile |

## When to Use Each Workflow

| Workflow | Use When |
|----------|----------|
| **init-scope** | Starting a new scope, switching scopes, or setting up project structure |
| **continue** | Every session after init — picking up work, implementing ALL remaining features, and verifying each |

---

## Workflow: Initialize Scope

Use this to create a new development scope or switch between existing scopes.

### Concepts

- **Scope**: A focused set of features (e.g., "auth", "video-editor", "phase-2")
- **Active Scope**: Currently active scope stored in `.active-scope`
- **Scope Files**: `specs/{scope}/spec.md` and `specs/{scope}/feature_list.json`
- **Project Type**: Declared in `feature_list.json` — determines verification strategy and applicable standards

### Directory Structure

```
project-root/
├── specs/
│   ├── auth/
│   │   ├── spec.md
│   │   └── feature_list.json
│   └── video-editor/
│       ├── spec.md
│       └── feature_list.json
├── .active-scope
├── spec.md              # Symlink to active scope
├── feature_list.json        # Symlink to active scope
├── progress.txt
└── init.sh
```

### Steps

1. **Check current state**
   ```bash
   ls -la specs/ 2>/dev/null || echo "No scopes yet"
   cat .active-scope 2>/dev/null || echo "No active scope"
   ```

2. **Create new scope** (if needed)
   ```bash
   mkdir -p specs/auth
   # Create specs/auth/spec.md with specification
   ```

3. **Switch to scope**
   ```bash
   echo "auth" > .active-scope
   ln -sf specs/auth/spec.md spec.md
   ln -sf specs/auth/feature_list.json feature_list.json
   ```

4. **Determine project type** — detect or ask:
   - Look at the codebase: Does it have a `src/` with React/Vue/Svelte? → `web`
   - Is it a REST/GraphQL API with no frontend? → `api`
   - Does it have a `main` with CLI arg parsing (cobra, clap, argparse, commander)? → `cli`
   - Is it a package/module with no main entry point? → `library`
   - Does it have ETL/pipeline code (pandas, spark, dbt, airflow)? → `data`
   - Does it have React Native, Flutter, SwiftUI, or Kotlin/Android? → `mobile`
   - If unclear, default to the most fitting type based on spec.md

5. **Create feature list** — choose the right method:

   **If scope references a constitution / standards document** (e.g., "align with AGENTS.md", "refactor to follow standards"):
   Use the **Constitution Audit Workflow** from `references/core/constitution-audit.md`. This is a multi-subagent process:
   - Split the reference document into sections (~200 lines each)
   - Launch parallel subagents to extract EVERY requirement from each section (read actual text, not summaries)
   - Launch parallel subagents to verify each requirement against the actual codebase
   - Generate features ONLY from verified violations
   - This is NON-NEGOTIABLE for compliance scopes — ad-hoc auditing misses requirements

   **If scope is new feature development** (e.g., "build a PIM system", "add auth"):
   Use the standard process from `references/core/feature-list-format.md`

   **Important:** Include the `"type"` field in feature_list.json (see feature-list-format.md).

6. **Create/update init.sh** — see `references/core/init-script-template.md`

7. **Commit and update progress log**

---

## Workflow: Continue Session (Autonomous Feature Loop)

This is the main workflow. It runs ALL remaining features to completion without stopping.

**⚠️ CRITICAL NON-STOP RULE (NON-NEGOTIABLE) ⚠️**

**You MUST keep looping until EVERY feature in `feature_list.json` has `"passes": true`. Do NOT stop after one feature. Do NOT stop after two features. Do NOT stop to report progress to the user. Do NOT ask the human what to do next. The human may be asleep.**

**After EACH subagent completes, you MUST immediately launch the NEXT subagent for the next incomplete feature. The ONLY acceptable reasons to stop are:**
1. **ALL features have `"passes": true`**
2. **A truly unrecoverable error** (hardware failure, missing credentials that cannot be worked around)

**Stopping to "report back" or "check in" with the user is a VIOLATION of this workflow. The user explicitly chose autonomous execution. KEEP GOING.**

### Session Startup Sequence

1. **Get bearings**
   ```bash
   pwd
   cat progress.txt
   cat feature_list.json
   git log --oneline -20
   ```

2. **Determine project type** — read the `"type"` field from `feature_list.json`

3. **Start environment**
   ```bash
   bash init.sh
   ```

4. **Verify existing features** — Run all unit tests (fast) and only the tests for features completed in previous sessions (not this session's new work). Skip tests for features not yet implemented.

### Autonomous Feature Loop

After startup, enter the **feature loop**. This loop runs until ALL features pass:

```
features_completed_this_session = 0

WHILE there are features with "passes": false in feature_list.json:
    1. Read feature_list.json to find next incomplete feature (highest priority first)
    2. Launch a SUBAGENT to implement, test, verify, and commit
    3. After subagent completes, VERIFY output quality (see below)
    4. features_completed_this_session++
    5. If features_completed_this_session % 5 == 0: run STANDARDS AUDIT (see below)
    6. CONTINUE to next feature — do NOT stop
END WHILE

Run FINAL STANDARDS AUDIT before ending session
```

### Launching Feature Subagents (Claude Code)

For each feature, use the **Agent tool** to launch a subagent. This keeps each feature's work isolated and prevents context window overflow.

**Subagent prompt template:**

```
You are implementing a feature for a {type} project. Work autonomously — do NOT ask questions, make your best judgment on all decisions.

## Project Context
- Working directory: {pwd}
- Active scope: {scope from .active-scope}
- Project type: {type from feature_list.json}

## Feature to Implement
- ID: {id}
- Description: {description}
- Category: {category}
- Priority: {priority}
- Test Steps:
{steps as bullet list}

## Standards Documents
Read these reference docs and follow them during implementation:
- references/core/code-quality.md — Code organization, testability, unit testing rules
- references/core/gitignore-standards.md — Files that must never be committed
- references/verification/{type}-verification.md — Verification strategy for this project type
{IF type == "web" or type == "mobile":}
- references/web/ux-standards.md — UX quality requirements (loading/empty/error states, responsive, accessibility)
- references/web/frontend-design.md — Visual design principles (typography, color, composition)
{END IF}

## Instructions

### Phase 1: Implement
1. Read the relevant source files to understand the current codebase
2. Read the spec.md file for full project context
3. Read the standards documents listed above
4. Implement the feature following existing code patterns and the standards
5. Make sure the implementation is complete and production-quality

### Phase 2: Refactor & Unit Test
Follow references/core/code-quality.md:
6. Extract pure functions out of components and handlers
7. Move business logic into testable utility/service modules
8. Eliminate duplication — reuse existing helpers or extract new shared ones
9. Write unit tests for all extracted logic. Run them until green.

### Phase 3: Verification
Follow references/verification/{type}-verification.md:
10. Execute the verification strategy defined for {type} projects
11. Run all relevant tests — fix until green
12. MANDATORY: Perform the verification checks specified in the doc
    Fix and re-run until all pass.

### Phase 4: Gitignore Review
Follow references/core/gitignore-standards.md:
13. Run `git status --short` and check every file against gitignore patterns
14. Add any missing patterns to `.gitignore`, remove from tracking if needed

### Phase 5: Commit
15. Update feature_list.json — change "passes": false to "passes": true
16. Update progress.txt with what was done and current feature pass count
17. Commit all changes:
    git add -A && git commit -m "feat: [description] — Implemented feature #[id]: [description]"

## Key Rules
- Follow existing code patterns and the standards documents
- Keep changes focused on this feature only
- Do not break other features
- Make all decisions yourself, never ask for human input
- EVERY feature must be verified per the verification strategy — no exceptions
- BEFORE committing, review ALL files for .gitignore candidates
```

**How to launch the subagent:**

Use the Agent tool with `subagent_type: "general-purpose"`. Example:

```
Agent tool call:
  description: "Implement feature #3"
  prompt: [filled template above]
```

### After Each Subagent Completes

The subagent handles implementation, testing, verification, and committing. The parent agent MUST verify:

1. **Confirm commit** — `git log --oneline -1`
2. **Confirm feature_list.json** — feature has `"passes": true`
3. **Verify output quality** — type-specific checks:

   **For `web` and `mobile` projects:**
   - VERIFY SCREENSHOTS EXIST:
     ```bash
     ls e2e/screenshots/{scope}-feature-{id}-*.png 2>/dev/null | wc -l
     ```
     If count is 0, launch a follow-up subagent to add screenshots and visual review.
   - SPOT-CHECK one screenshot — Use the Read tool to open one screenshot. Evaluate against verification criteria.
   - If quality is poor, launch a **polish subagent**.

   **For `api` projects:**
   - Verify integration tests exist and pass
   - Check that error cases are tested (not just happy paths)

   **For `cli` projects:**
   - Run a quick smoke test: `./bin/{tool} --help` or equivalent
   - Verify error cases are tested

   **For `library` projects:**
   - Verify all tests pass (including race detection if applicable)
   - Check public API surface hasn't accidentally expanded

   **For `data` projects:**
   - Verify transformation tests exist and pass
   - Check edge cases (empty, null, duplicate) are tested

4. If the subagent failed to complete, launch another subagent to fix and finish.
5. **Loop back IMMEDIATELY** — pick the next incomplete feature and launch a new subagent RIGHT NOW. Do NOT stop, do NOT report to the user, do NOT wait for instructions. KEEP GOING until ALL features pass.

### Periodic Standards Audit

**When to run:** Every 5 completed features AND at session end (before final commit).

This uses the same audit pattern as `references/core/constitution-audit.md`, but applied to the project's own standards documents. The audit catches issues that individual subagents missed — self-review has blind spots.

**Audit process:**

1. Determine which standards apply based on project type:
   - **All types:** `core/code-quality.md`, `core/gitignore-standards.md`, `core/session-handoff-standards.md`
   - **web/mobile only:** `web/ux-standards.md`, `web/frontend-design.md`

2. For EACH applicable standards document, launch a **verification subagent** that:
   - Reads the standards document
   - Reads the code/files changed since the last audit (use `git diff --name-only HEAD~5` or similar)
   - Checks each standard against the actual code
   - Reports: COMPLIANT or VIOLATION with specific file and line

3. Collect all violations across subagents

4. If violations found:
   - Group related violations into fix batches
   - Launch a **fix subagent** for each batch
   - Each fix subagent commits its changes
   - Re-verify the fixed code

5. Log audit results in `progress.txt`

**Subagent prompt template for standards audit:**

```
You are auditing recently changed code against a project standards document.

## Standards Document
{paste the full content of the standards doc}

## Files to Audit
{list of files changed since last audit}

## Instructions
1. Read each file listed above
2. For EACH standard in the document, check if the code complies
3. Report findings as:
   - COMPLIANT: {standard} — {brief evidence}
   - VIOLATION: {standard} — {file}:{line} — {what's wrong} — {fix needed}
4. Be thorough — check every standard, don't skip "obvious" ones
```

### Decision Making Guidelines

Since the human may be asleep, follow these rules for autonomous decisions:

| Situation | Decision |
|-----------|----------|
| Ambiguous spec | Choose the simplest reasonable interpretation |
| Multiple implementation approaches | Pick the one matching existing patterns |
| Test is flaky | Add proper waits/retries, don't skip the test |
| Feature seems too large | Break into sub-tasks within the subagent |
| Dependency conflict | Use the version compatible with existing packages |
| Build error | Read the error, fix it, rebuild |
| Port conflict | Kill the conflicting process and restart |
| Database issue | Reset/reseed the database |
| Feature blocked by another | Skip to next feature, come back later |
| Missing dependency | Install it |
| Unclear file structure | Follow existing project conventions |
| **Web/mobile:** Unclear UI design | Follow references/web/frontend-design.md |
| **Web/mobile:** UI looks generic/plain | Add visual polish per references/web/ux-standards.md |
| **Web/mobile:** Subagent skipped screenshots | Launch follow-up subagent to add them |
| **API:** Unclear response format | Follow existing endpoint patterns, use consistent error format |
| **CLI:** Unclear output format | Match existing command output style |
| **Library:** Unclear public API | Keep it minimal, expose only what's needed |

### Session End

Only end the session when:
- **ALL features have `"passes": true`**, OR
- A truly unrecoverable error occurs (hardware failure, missing credentials, etc.)

Before ending:
1. Run **final standards audit** (see Periodic Standards Audit above) — include `core/session-handoff-standards.md`
2. Run all unit tests
3. Run verification tests only for features completed in previous sessions (regression check)
4. Verify codebase meets `references/core/session-handoff-standards.md`
5. Commit any remaining changes

---

## Critical Rules

### Standards Enforcement
- All quality standards live in `references/` docs — subagents MUST read them
- Standards are verified both during implementation (by subagent) AND periodically (by audit)
- Audit violations MUST be fixed before session ends

### Autonomous Operation (NON-NEGOTIABLE)
- NEVER stop to ask the human a question
- NEVER wait for human approval
- NEVER stop to "report progress" or "check in" — the user can see commits in git log
- NEVER output a summary and wait — immediately launch the next subagent
- After each subagent completes: verify → launch next subagent. That's it. No pausing.
- Make reasonable decisions based on existing patterns
- If blocked, try alternative approaches before giving up
- Keep working until ALL features are complete
- The continue workflow is a LOOP, not a single step. You are the loop controller.

---

## Reference Files

All standards, templates, and detailed processes:

### Core (all project types)
- `references/core/code-quality.md` — Code organization, testability, and unit testing standards
- `references/core/gitignore-standards.md` — Gitignore patterns and review process
- `references/core/feature-list-format.md` — Feature list structure, critical rules, priority order
- `references/core/session-handoff-standards.md` — Clean codebase, git state, progress tracking
- `references/core/init-script-template.md` — init.sh template
- `references/core/continue-workflow.md` — Full continue workflow details
- `references/core/constitution-audit.md` — Systematic audit workflow for compliance/alignment scopes

### Web-specific (type: web, mobile)
- `references/web/ux-standards.md` — UX quality standards and checklist
- `references/web/frontend-design.md` — Design principles for visual quality

### Verification strategies (one per project type)
- `references/verification/web-verification.md` — Playwright E2E + screenshots
- `references/verification/api-verification.md` — Integration tests + endpoint validation
- `references/verification/cli-verification.md` — Command execution + output validation
- `references/verification/library-verification.md` — Unit tests + public API validation
- `references/verification/data-verification.md` — Transformation tests + data quality
- `references/verification/mobile-verification.md` — Mobile E2E + screenshots
