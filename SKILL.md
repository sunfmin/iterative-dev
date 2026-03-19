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
│   │   ├── feature_list.json
│   │   ├── progress.txt
│   │   ├── screenshots/
│   │   └── refinements/
│   └── video-editor/
│       ├── spec.md
│       ├── feature_list.json
│       ├── progress.txt
│       ├── screenshots/
│       └── refinements/
├── .active-scope
├── spec.md              # Symlink to active scope
├── feature_list.json    # Symlink to active scope
├── progress.txt         # Symlink to active scope
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
   mkdir -p specs/auth/{screenshots,refinements}
   # Create specs/auth/spec.md with specification
   ```

3. **Switch to scope**
   ```bash
   echo "auth" > .active-scope
   ln -sf specs/auth/spec.md spec.md
   ln -sf specs/auth/feature_list.json feature_list.json
   ln -sf specs/auth/progress.txt progress.txt
   ```

4. **Determine project type** — based on how users interact with the deliverable:
   - What does the user interact with? **Browser** → `web`. **Terminal** → `cli`. **Import/call** → `library`. **HTTP requests** → `api`. **Phone/tablet** → `mobile`. **Data outputs** → `data`.
   - Confirm by examining the codebase structure (e.g., frontend frameworks suggest `web`, CLI entry points suggest `cli`, no main entry point suggests `library`)
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

   **CRITICAL — Self-Contained Features (NON-NEGOTIABLE):**
   Every feature MUST include its own test and verification steps. NEVER create separate "testing" or "verification" features (e.g., "Write integration tests", "Add E2E tests for all pages"). Each feature's `steps` array must contain both implementation AND verification steps so the feature can be independently verified when completed. See `references/core/feature-list-format.md` for the "Self-Contained Features" rule and examples.

   **CRITICAL — Verification Steps for UI Features (web/mobile — NON-NEGOTIABLE):**
   For `web` and `mobile` project types, every feature that produces or modifies UI MUST include **interaction test and screenshot** steps in its `steps` array. These are NOT optional and MUST NOT be deferred to a separate feature.

   **Outcome-proving tests (interaction, integration, unit) are the PRIMARY verification.** Tests must perform real user actions and verify observable outcomes — they prove the feature actually works. **Screenshots are SECONDARY** — they verify visual quality and catch layout/styling issues that interaction tests cannot detect. Both are required.

   Every UI feature's `steps` array MUST end with these steps (adapted to the feature):
   ```
   "Write interaction tests: Playwright tests that perform user actions (click, fill, submit, navigate) and verify outcomes (data appears, page navigates, state changes)",
   "Capture screenshots: add fullPage screenshots at key states (list view, empty state, form, after action)",
   "Run Playwright tests and verify all pass and screenshots are generated in specs/{scope}/screenshots/",
   "Visually review each screenshot: verify layout, spacing, hierarchy, loading/empty/error states, data display, and overall polish",
   "Fix any issues found (broken behavior or visual problems) and re-run until quality is acceptable"
   ```

   **How to determine if a feature is a UI feature:** If the feature creates or modifies files in `src/routes/`, `src/components/`, `src/features/`, or any file that renders user-visible HTML/JSX, it is a UI feature and MUST have screenshot steps. Backend-only features (services, models, API endpoints without frontend) do NOT need screenshot steps.

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
    4. Launch a REFINEMENT SUBAGENT to polish the feature (see Refinement Phase below)
    5. features_completed_this_session++
    6. If features_completed_this_session % 5 == 0: run STANDARDS AUDIT (see below)
    7. CONTINUE to next feature — do NOT stop
END WHILE

Run FINAL STANDARDS AUDIT before ending session
```

### Launching Feature Subagents (Claude Code)

For each feature, use the **Agent tool** to launch a subagent. This keeps each feature's work isolated and prevents context window overflow.

**IMPORTANT — Reference doc paths:** The `references/` directory lives inside this skill's install directory, NOT in the project. When building subagent prompts, you MUST resolve paths to absolute paths. Use: `{skill_base_dir}/references/...` where `{skill_base_dir}` is the "Base directory for this skill" shown at the top of this prompt. For example, if the skill base is `/Users/alice/.claude/skills/iterative-dev`, then the path is `/Users/alice/.claude/skills/iterative-dev/references/core/code-quality.md`.

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
- {skill_base_dir}/references/core/code-quality.md — Code organization, testability, unit testing rules
- {skill_base_dir}/references/core/gitignore-standards.md — Files that must never be committed
- {skill_base_dir}/references/verification/{type}-verification.md — Verification strategy for this project type
{IF type == "web" or type == "mobile":}
- {skill_base_dir}/references/web/ux-standards.md — UX quality requirements (loading/empty/error states, responsive, accessibility)
- {skill_base_dir}/references/web/frontend-design.md — Visual design principles (typography, color, composition)
{END IF}

## Instructions

### Phase 1: Implement
1. Read the relevant source files to understand the current codebase
2. Read the spec.md file for full project context
3. Read the standards documents listed above (use the ABSOLUTE paths provided)
4. Implement the feature following existing code patterns and the standards
5. Make sure the implementation is complete and production-quality

### Phase 2: Refactor & Unit Test
Follow {skill_base_dir}/references/core/code-quality.md:
6. Extract pure functions out of components and handlers
7. Move business logic into testable utility/service modules
8. Eliminate duplication — reuse existing helpers or extract new shared ones
9. Write unit tests for all extracted logic. Run them until green.

### Phase 3: Verification
Follow {skill_base_dir}/references/verification/{type}-verification.md:
10. Execute the verification strategy defined for {type} projects
11. Run all relevant tests — fix until green
12. MANDATORY: Perform the verification checks specified in the doc
    Fix and re-run until all pass.

{IF type == "web" or type == "mobile":}
### Phase 3b: Screenshot Capture (NON-NEGOTIABLE for web/mobile)

Interaction tests (Phase 3) are the PRIMARY verification that features work. Screenshots are SECONDARY but MANDATORY — they verify visual quality and catch layout/styling issues that interaction tests cannot detect. A feature without both interaction tests and screenshots is NOT fully verified.

**Screenshot directory:** `{screenshots_dir}` (provided by parent agent — this is `{pwd}/specs/{scope}/screenshots/`, the scope-specific directory for all visual artifacts).

13. Write or update a Playwright test file that captures screenshots at key states:
    - Use `page.screenshot({ path: '{screenshots_dir}/feature-{id}-step{N}-{description}.png', fullPage: true })`
    - Capture BEFORE action, AFTER action, error states, and empty states
    - Every test MUST have at least one `page.screenshot()` call

14. Run the Playwright tests:
    ```bash
    npx playwright test
    ```

15. Verify screenshots were generated:
    ```bash
    ls {screenshots_dir}/feature-{id}-*.png
    ```
    If no screenshots exist, the verification has FAILED. Fix and re-run.

16. Use the Read tool to open and visually review EVERY screenshot. Check:
    - Layout: content fits, no overflow/clipping, proper alignment
    - Spacing: consistent padding/margins (4/8/16/24/32px scale)
    - Visual hierarchy: important actions obvious, proper text size hierarchy
    - States: loading skeleton/spinner, empty state (icon + message + CTA), error state
    - Aesthetics: polished and intentional, cohesive colors, proper shadows/depth
    - Data display: real data shown, numbers right-aligned in tables, status badges colored

17. If screenshots reveal problems, fix the UI and re-capture until quality is acceptable.

**Screenshot naming convention:** `feature-{id}-step{N}-{description}.png` (scope is encoded in the directory path `specs/{scope}/screenshots/`)
Examples: `feature-9-step1-product-list.png`, `feature-9-step2-empty-state.png`
{END IF}

### Phase 4: Gitignore Review
Follow {skill_base_dir}/references/core/gitignore-standards.md:
18. Run `git status --short` and check every file against gitignore patterns
19. Add any missing patterns to `.gitignore`, remove from tracking if needed

### Phase 5: Commit
20. Update feature_list.json — change "passes": false to "passes": true
21. Update progress.txt with what was done and current feature pass count
22. Commit all changes:
    git add -A && git commit -m "feat: [description] — Implemented feature #[id]: [description]"

## Key Rules
- Follow existing code patterns and the standards documents
- Keep changes focused on this feature only
- Do not break other features
- Make all decisions yourself, never ask for human input
- EVERY feature must be verified per the verification strategy — no exceptions
- BEFORE committing, review ALL files for .gitignore candidates
{IF type == "web" or type == "mobile":}
- SCREENSHOTS ARE NON-NEGOTIABLE — do not skip or defer them
- If the app/server is not running for screenshots, start it (check init.sh or start manually)
{END IF}
{IF feature connects frontend to real backend API (replaces mocks, changes fetch config):}
### Full-Stack Integration Verification (NON-NEGOTIABLE)
This feature connects the frontend to a real backend. You MUST verify the connection works end-to-end:
1. **Start both servers** — backend with a real database, frontend with VITE_API_BASE_URL pointing to backend
2. **Verify route prefix** — `curl` the backend API at the URL the frontend will use (e.g., `/api/v1/...`). If 404, the route prefix is wrong. Code generators often omit the OpenAPI `servers.url` prefix — mount the handler under the correct prefix.
3. **Verify CORS** — `curl -I -X OPTIONS` with an `Origin` header matching the frontend port. If no `Access-Control-Allow-Origin` header, add CORS middleware. This is the #1 reason frontends silently fail to load data.
4. **Seed data and screenshot** — Seed 2-3 records, take Playwright screenshots of all pages, and verify they show REAL DATA (not loading skeletons or empty states).
5. **Check browser console** — Run Playwright with console error capture. Any CORS or fetch errors mean the integration is broken.
Do NOT mark this feature as passing based only on `tsc --noEmit`. TypeScript cannot catch CORS or route mismatches.
{END IF}
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
3. **Verify output quality (NON-NEGOTIABLE GATE)** — type-specific checks. You MUST run these checks. Do NOT skip them even if the subagent reported success.

   **For `web` and `mobile` projects — SCREENSHOT GATE (NON-NEGOTIABLE):**

   This gate MUST be executed for EVERY UI feature. It is the primary quality control for visual output. Skipping this gate means the feature is NOT verified.

   **Determine `{screenshots_dir}`:** Screenshots are stored per-scope: `{pwd}/specs/{scope}/screenshots/`
   - Read the active scope from `.active-scope`
   - Resolve to absolute path: `{pwd}/specs/{scope}/screenshots/`
   - You MUST pass this resolved absolute path as `{screenshots_dir}` when building subagent prompts.

   a. **CHECK screenshots exist:**
      ```bash
      ls {screenshots_dir}/feature-{id}-*.png 2>/dev/null | wc -l
      ```
   b. **If count is 0: BLOCK.** The feature is NOT complete. Launch a follow-up subagent specifically to capture screenshots:
      ```
      Prompt: "You need to add screenshot capture for feature #{id} ({description}).
      The feature is already implemented and committed. Your ONLY job is:
      1. Start the dev server if not running (check with lsof, start with init.sh if needed)
      2. Write/update a Playwright test that navigates to the feature and captures screenshots
      3. Screenshots MUST be saved to: {screenshots_dir}/feature-{id}-step{N}-{description}.png
      4. Run the test: npx playwright test
      5. Verify screenshots exist: ls {screenshots_dir}/feature-{id}-*.png
      6. Use the Read tool to visually review each screenshot
      7. Commit the screenshots and test file"
      ```
   c. **If count > 0: SPOT-CHECK.** Use the Read tool to open one screenshot. Evaluate:
      - Layout correct? Content fits, no overflow?
      - Real data shown, not empty/broken?
      - Polished appearance, not prototype-level?
      - If quality is poor, launch a **polish subagent** to fix UI issues and recapture.
   d. **OUTCOME VERIFICATION CHECK:** Verify the subagent wrote tests that **prove the feature works from the user's perspective** — not just screenshot-only tests. Tests must perform user actions (click, fill, submit, navigate) and verify outcomes (data appears, page navigates, state changes). If the feature has interactive elements and the only tests are screenshots, the feature is NOT verified. Launch a follow-up subagent to add interaction tests. See `references/verification/web-verification.md` Step 2.

   **For `web` full-stack projects — INTEGRATION SMOKE TEST GATE (NON-NEGOTIABLE):**

   This gate MUST be executed for ANY feature that connects the frontend to a real backend API (replacing mocks, changing fetch config, modifying backend routes/middleware). This is the **#1 source of silent failures** — TypeScript compiles clean but the app shows loading spinners forever because of CORS or route prefix issues.

   After the subagent commits, the parent agent MUST:

   a. **Start both servers** (backend with real database, frontend pointing to backend)
   b. **Verify backend routes respond** (not 404):
      ```bash
      curl -s http://localhost:{backend_port}/api/v1/{any_resource} | head -3
      ```
      If 404: route prefix mismatch. Code generators (ogen, openapi-generator) often register routes without the OpenAPI `servers.url` prefix. Fix by mounting the generated handler under `/api/v1` with `http.StripPrefix` or equivalent.
   c. **Verify CORS headers**:
      ```bash
      curl -s -I -X OPTIONS http://localhost:{backend_port}/api/v1/{any_resource} \
        -H 'Origin: http://localhost:{frontend_port}' | grep -i 'access-control'
      ```
      If missing: add CORS middleware to the backend. Without it, browsers silently block all frontend API requests.
   d. **Seed test data** via API (at least 2-3 records)
   e. **Run Playwright screenshots** against all major pages
   f. **Verify screenshots show REAL DATA** — not loading skeletons, not empty states. If data is missing, diagnose using the common root causes table in `references/verification/web-verification.md`.

   If any check fails, launch a fix subagent before moving to the next feature.

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
5. **Launch REFINEMENT SUBAGENT** — See "Refinement Phase" below. This polishes the feature's UX and code quality before moving on.
6. **Loop back IMMEDIATELY** — pick the next incomplete feature and launch a new subagent RIGHT NOW. Do NOT stop, do NOT report to the user, do NOT wait for instructions. KEEP GOING until ALL features pass.

### Refinement Phase (After Each Feature)

After a feature passes verification and is committed, launch a **refinement subagent** to polish it. This is a separate subagent so it evaluates the feature with fresh context — a "second pair of eyes" pass.

The refinement subagent writes its analysis to `specs/{scope}/refinements/feature-{id}-refinement.md` so the thinking process is traceable across sessions.

**Refinement subagent prompt template:**

```
You are refining a recently completed feature. The feature is already implemented, tested, verified, and committed. Your job is to polish and improve it — both the user experience and the code quality.

## Project Context
- Working directory: {pwd}
- Active scope: {scope}
- Project type: {type}
- Feature just completed: #{id} — {description}
- Screenshots directory: {screenshots_dir}
- Refinement output: {pwd}/specs/{scope}/refinements/feature-{id}-refinement.md

## Standards Documents
Read these before starting:
- {skill_base_dir}/references/core/code-quality.md
{IF type == "web" or type == "mobile":}
- {skill_base_dir}/references/web/ux-standards.md
- {skill_base_dir}/references/web/frontend-design.md
{END IF}

## What Was Done
Review the most recent commit to understand what was implemented:
git log --oneline -1
git diff HEAD~1 --name-only

{IF type == "web" or type == "mobile":}
## Part 1: UX/Visual Refinement

Think divergently about how to make users LOVE this interface. Don't just check for bugs — imagine better ways to present the information and interactions.

1. Use the Read tool to review ALL screenshots in {screenshots_dir}/ for this feature
2. For each screen, evaluate from a first-time user's perspective:
   - Is the purpose of this screen immediately obvious?
   - Can the user figure out what to do without instructions?
   - Does the visual hierarchy guide the eye to the most important action?
   - Are transitions and state changes smooth and predictable?
3. Think divergently about improvements — consider alternatives you haven't tried:
   - Could the layout be reorganized for better flow or scannability?
   - Would micro-interactions (hover effects, transitions, focus states) make it feel more responsive and alive?
   - Is whitespace being used effectively to create breathing room and group related elements?
   - Could typography be more expressive — size contrasts, weight variations, line heights?
   - Are colors creating the right emotional tone? Could accent colors highlight key actions better?
   - Are empty states, loading states, and error states not just functional but helpful and encouraging?
   - Could icons, illustrations, or subtle visual cues improve comprehension?
4. Research: look at how the standards documents suggest handling similar UI patterns. Are there recommendations you missed?
5. Implement the most impactful improvements — prioritize changes that make the biggest difference to user understanding and delight
6. Re-run Playwright tests and re-capture screenshots
7. Visually verify the improvements look better than before
{END IF}

## Part 2: Code Quality Refinement

Re-read all generated code with fresh eyes, looking for opportunities to make it more maintainable and testable.

1. Read ALL files changed in the most recent commit: `git diff HEAD~1 --name-only`
2. For each file, evaluate:
   - **Abstraction**: Are there functions doing too many things? Should logic be extracted?
   - **Testability**: Is business logic separated from framework/UI code? Could someone write a unit test for the core logic without setting up the whole framework?
   - **Readability**: Would a new developer understand this code without extensive context? Are names clear and descriptive?
   - **Duplication**: Is there repeated logic that should be a shared utility?
   - **Simplicity**: Are there overly complex control flows that could be simplified? Deep nesting that could be flattened?
3. Make concrete improvements — refactor, rename, extract, simplify
4. Run all unit tests — ensure they still pass
5. If you extracted new logic, write unit tests for it

## Part 3: Write Refinement Report

Write your analysis to `{pwd}/specs/{scope}/refinements/feature-{id}-refinement.md` with this structure:

```markdown
# Feature #{id} Refinement: {description}

## UX Analysis (web/mobile only)
- **Screenshots reviewed**: [list of screenshots]
- **Issues found**: [what problems or opportunities were identified]
- **Alternatives considered**: [what other approaches were thought about]
- **Changes made**: [what was actually improved and why]
- **Changes deferred**: [ideas noted for future consideration, if any]

## Code Quality Analysis
- **Files reviewed**: [list of files]
- **Issues found**: [code smells, abstraction opportunities, naming issues]
- **Refactoring done**: [what was changed and why]
- **Test coverage**: [new tests added, if any]

## Summary
[1-2 sentence summary of the refinement pass]
```

## Commit
If you made code or UI changes:
git add -A && git commit -m "refine: polish feature #{id} — [summary of improvements]"

If no code changes were warranted, still commit the refinement report:
git add specs/{scope}/refinements/ && git commit -m "refine: review feature #{id} — no changes needed"

## Rules
- This is a POLISH pass — do NOT add new functionality
- Do NOT break existing tests
- Keep changes focused on improving what exists
- Think creatively about UX — the goal is to make users enjoy and understand the interface
- Think critically about code — the goal is to make the codebase a pleasure to maintain
- ALWAYS write the refinement report, even if no changes are made
```

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
| **Web full-stack:** Frontend shows loading forever | Check CORS headers and route prefix — see `references/verification/web-verification.md` Integration Smoke Test |
| **Web full-stack:** curl works but browser doesn't | CORS issue — add `Access-Control-Allow-Origin` middleware to backend |
| **Web full-stack:** Backend returns 404 for /api/v1/... | Code generator omitted server URL prefix — mount handler under `/api/v1` |
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
- All quality standards live in `references/` docs within this skill's base directory — subagents MUST read them using absolute paths
- **CRITICAL**: Reference doc paths are relative to THIS SKILL's install directory (shown as "Base directory for this skill" at the top of this prompt), NOT the project working directory. Always resolve to absolute paths before passing to subagents.
- Standards are verified both during implementation (by subagent) AND periodically (by audit)
- Audit violations MUST be fixed before session ends

### Verification Enforcement (web/mobile projects — NON-NEGOTIABLE)
- **Interaction tests proving user outcomes are PRIMARY verification** — every UI feature MUST have tests that perform user actions and verify results
- Every UI feature MUST also have screenshots in `{screenshots_dir}/feature-{id}-*.png` — screenshots are SECONDARY for visual quality
- `{screenshots_dir}` is `{pwd}/specs/{scope}/screenshots/` — screenshots are stored per-scope alongside other scope artifacts.
- The parent agent MUST check for both interaction tests AND screenshots after EVERY subagent that implements a UI feature
- If either is missing, the parent MUST launch a follow-up subagent — the feature is NOT done
- The subagent prompt template includes inlined verification instructions so subagents know what to do without needing to find external docs

### Autonomous Operation (NON-NEGOTIABLE)
- NEVER stop to ask the human a question
- NEVER wait for human approval
- NEVER stop to "report progress" or "check in" — the user can see commits in git log
- NEVER output a summary and wait — immediately launch the next subagent
- After each subagent completes: verify → refine → launch next subagent. That's it. No pausing.
- Make reasonable decisions based on existing patterns
- If blocked, try alternative approaches before giving up
- Keep working until ALL features are complete
- The continue workflow is a LOOP, not a single step. You are the loop controller.

### Refinement Enforcement
- Every completed feature MUST go through the refinement phase before moving to the next feature
- The refinement subagent is separate from the implementation subagent — fresh context enables better evaluation
- Refinement MUST NOT add new functionality — it only improves what exists
- The refinement report (`specs/{scope}/refinements/feature-{id}-refinement.md`) MUST always be written, even if no code changes are made
- Refinement commits use the prefix `refine:` not `feat:`
- For web/mobile: UX refinement should think divergently — not just check for bugs, but imagine better ways to present information
- For all types: code refinement should focus on abstraction, testability, and maintainability

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
