# Continue Workflow — Full Details

This is the primary workflow for every session after initialization. It runs **autonomously until ALL features are complete**.

**CRITICAL: Do NOT stop after implementing one feature. Keep looping until every feature in `feature_list.json` has `"passes": true`. The human may be asleep — make all decisions yourself.**

## Session Startup Sequence

Every coding session should start by:

1. `pwd` — Confirm working directory
2. Read `progress.txt` — Understand what previous sessions did
3. Read `feature_list.json` — See current feature status and project type
4. `git log --oneline -20` — See recent commits
5. Run `bash init.sh` — Start the dev environment
6. Quick verification — Make sure existing features work

## Step-by-Step Process

### Step 1: Get Your Bearings

```bash
pwd
cat progress.txt
cat feature_list.json
git log --oneline -20
```

Note the `"type"` field in feature_list.json — this determines which verification strategy and standards apply.

### Step 2: Start the Development Environment

```bash
bash init.sh
```

If `init.sh` doesn't exist or fails, check the project README or build files for how to start. Fix `init.sh` if needed.

**Ensure all required services are running** (varies by project type):

- **web**: Frontend dev server, backend server, database
- **api**: API server, database, any external service mocks
- **cli**: Build the tool binary
- **library**: No services needed — just ensure build works
- **data**: Database, data stores, pipeline dependencies
- **mobile**: Emulator/simulator, backend server

### Step 3: Verify Existing Features (Regression Check)

Before implementing anything new, **verify that existing passing features still work**. To save time, only run what's needed:

1. **Run all unit tests** (fast):
   ```bash
   # Use the project's test command
   npm test       # Node.js
   go test ./...  # Go
   pytest tests/  # Python
   cargo test     # Rust
   ```

2. **Run verification tests only for features already passing** from previous sessions. Do NOT run tests for features that haven't been implemented yet.

3. If anything is broken, **fix it first**

### Step 4: Enter the Autonomous Feature Loop

**This is the core loop. Do NOT exit until all features pass.**

```
WHILE there are features with "passes": false in feature_list.json:
    1. Read feature_list.json
    2. Find the highest-priority feature with "passes": false
    3. Launch a SUBAGENT to implement, test, verify, and commit
    4. After subagent completes: VERIFY output quality (Step 4c)
    5. If quality fails: launch fix/polish subagent
    6. LOOP BACK to step 1
END WHILE
```

#### 4a: Pick the Next Feature

From `feature_list.json`, find the **highest-priority feature** that has `"passes": false`.

- Work on features in order of priority (high -> medium -> low)
- Within the same priority, work in the order they appear in the file
- If a feature is blocked, skip it and come back later

#### 4b: Launch a Subagent for the Feature

Use the **Agent tool** (Claude Code) to launch a subagent for each feature. The subagent handles the **full lifecycle**: implement, test, verify, and commit. This isolates each feature's work and prevents context window overflow.

Use the subagent prompt template from SKILL.md. The template adapts based on project type — it includes the correct verification strategy and only includes web-specific standards for web/mobile projects.

#### 4c: Verify Subagent Output (MANDATORY)

After the subagent completes, the parent agent MUST verify:

1. **Confirm commit** — `git log --oneline -1`
2. **Confirm feature_list.json** — feature has `"passes": true`
3. **Type-specific verification** — see SKILL.md "After Each Subagent Completes" section
4. If the subagent failed to complete, launch another subagent to fix and finish.
5. **Loop back** — pick the next incomplete feature and repeat.

**Do NOT stop. Keep looping until all features pass.**

### Step 8: Final Verification (When ALL Features Pass)

Only when every feature has `"passes": true`:

1. **Run all unit tests**
2. **Run verification tests for features completed in previous sessions** (regression check)
3. **Verify clean git status**
   ```bash
   git status
   ```
4. **Update progress.txt** with final session summary:
   ```
   ## Session Complete — [DATE]
   ### Summary:
   - All [N] features implemented and passing
   - Unit tests and regression tests green
   - All features verified per {type} verification strategy
   - Codebase clean and production-ready
   ```
5. **Final commit** if needed

## Decision Making (Autonomous Mode)

Since the human may be asleep, follow these rules:

| Situation | Decision |
|-----------|----------|
| Ambiguous spec | Choose the simplest reasonable interpretation |
| Multiple approaches | Pick the one matching existing patterns |
| Flaky test | Add proper waits/retries, don't skip |
| Feature too large | Break into sub-tasks within the subagent |
| Dependency conflict | Use version compatible with existing packages |
| Build error | Read error, fix it, rebuild |
| Port conflict | Kill conflicting process, restart |
| Database issue | Reset/reseed the database |
| Feature blocked | Skip to next, come back later |
| Missing dependency | Install it |
| Unclear file structure | Follow existing project conventions |
| **Web/mobile:** Unclear UI design | Follow references/web/frontend-design.md |
| **Web/mobile:** UI looks generic | Add visual polish per references/web/ux-standards.md |
| **API:** Unclear response format | Follow existing endpoint patterns |
| **CLI:** Unclear output format | Match existing command output style |
| **Library:** Unclear public API | Keep it minimal |

## What NOT To Do

- Don't stop after one feature — keep going until ALL pass
- Don't ask the human what to do — decide yourself
- Don't try to one-shot the entire app
- Don't declare the project "done" prematurely — check feature_list.json
- Don't leave the codebase in a broken state
- Don't skip testing — verify features per the project's verification strategy
- Don't modify feature descriptions or test steps in feature_list.json
- Don't implement features out of priority order without good reason
- Don't wait for human approval between features
- Don't skip verification — it is MANDATORY for every feature
