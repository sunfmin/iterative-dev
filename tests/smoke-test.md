# Skill Smoke Test

## Purpose
Verify the iterative-dev skill executes all mandatory steps: implement → verify → refine → next.

## Setup
Create a minimal test project with 2 trivial features. Run the skill. Check artifacts.

### 1. Create test project
```bash
mkdir -p /tmp/iterative-dev-test && cd /tmp/iterative-dev-test
git init
```

### 2. Create minimal scope
```bash
mkdir -p specs/test/{screenshots,refinements}
echo "test" > .active-scope
```

Create `specs/test/spec.md`:
```
# Test Project
A simple CLI tool that greets users.
```

Create `specs/test/feature_list.json`:
```json
{
  "type": "cli",
  "features": [
    {
      "id": 1,
      "category": "infrastructure",
      "priority": "high",
      "description": "Project scaffolding: create a Node.js project with a greet.js script",
      "steps": [
        "Create package.json with name 'greeter'",
        "Create greet.js that prints 'Hello, World!'",
        "Verify: node greet.js outputs 'Hello, World!'"
      ],
      "passes": false
    },
    {
      "id": 2,
      "category": "functional",
      "priority": "high",
      "description": "User can greet by name: node greet.js Alice prints 'Hello, Alice!'",
      "steps": [
        "Modify greet.js to accept a name argument",
        "Default to 'World' if no name provided",
        "Write test: node greet.js Alice outputs 'Hello, Alice!'",
        "Write test: node greet.js (no args) outputs 'Hello, World!'"
      ],
      "passes": false
    }
  ]
}
```

Create symlinks and init:
```bash
ln -sf specs/test/spec.md spec.md
ln -sf specs/test/feature_list.json feature_list.json
echo "# Progress" > specs/test/progress.txt
ln -sf specs/test/progress.txt progress.txt
echo '#!/bin/bash' > init.sh && chmod +x init.sh
git add -A && git commit -m "init: smoke test scope"
```

### 3. Run the skill
```
/iterative-dev continue
```

### 4. Verify (automated checks)

```bash
#!/bin/bash
# Run this after the skill completes

PASS=0
FAIL=0

check() {
  if eval "$2"; then
    echo "PASS: $1"
    ((PASS++))
  else
    echo "FAIL: $1"
    ((FAIL++))
  fi
}

# All features pass
check "All features pass" \
  '[ $(cat feature_list.json | grep -c "\"passes\": true") -eq 2 ]'

# Implementation commits exist
check "Feature commits exist" \
  '[ $(git log --oneline | grep -c "feat:") -ge 2 ]'

# Refinement commits exist (THE KEY TEST)
check "Refinement commits exist" \
  '[ $(git log --oneline | grep -c "refine:") -ge 2 ]'

# Refinement reports exist
check "Refinement reports exist" \
  '[ $(ls specs/test/refinements/feature-*-refinement.md 2>/dev/null | wc -l) -ge 2 ]'

# Commit order: each feat is followed by a refine
check "Commit order: refine follows feat" \
  'git log --oneline --reverse | grep -E "feat:|refine:" | \
   awk "/feat:/{f=1;next} /refine:/{if(f)f=0; else exit 1} END{exit f}"'

# Progress file updated
check "Progress file updated" \
  '[ $(wc -l < specs/test/progress.txt) -gt 1 ]'

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "ALL CHECKS PASSED" || echo "SOME CHECKS FAILED"
```

## Expected Results
- 2 `feat:` commits (one per feature)
- 2 `refine:` commits (one per feature)
- 2 refinement reports in `specs/test/refinements/`
- Alternating pattern: feat → refine → feat → refine
- Both features `"passes": true`

## What This Catches
- Skipped refinements (the bug that prompted this test)
- Missing refinement reports
- Wrong commit order (refinement must follow its feature)
- Incomplete feature list updates
