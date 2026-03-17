# CLI Verification Strategy

Verify CLI tool features through command execution tests, output validation, and exit code checks.

**This is the verification strategy for project type: `cli`**

## Overview

CLI projects are verified through:
1. **Command execution tests** — Run commands with various arguments and flags
2. **Output validation** — Check stdout, stderr, and file output
3. **Exit code checks** — Correct exit codes for success and failure
4. **Edge case coverage** — Missing args, invalid input, permissions, large files

## Process

### Step 1: Ensure Tool is Built

```bash
# Build the CLI tool (adjust for your project)
go build -o ./bin/mytool .       # Go
cargo build                       # Rust
npm run build                     # Node.js
pip install -e .                  # Python
```

### Step 2: Write Integration Tests

Every feature MUST have tests covering:

**Happy path:**
```
- Valid args → correct output + exit code 0
- All flags/options work as documented
- Output format is correct (text, JSON, table, etc.)
```

**Error cases:**
```
- Missing required args → helpful error message + exit code 1
- Invalid flag values → descriptive error + exit code 1
- File not found → clear error + exit code 1
- Permission denied → clear error + exit code 1
- Invalid input format → parse error with line/position info
```

**Edge cases:**
```
- Empty input → graceful handling (not crash)
- Very large input → handles without OOM or hang
- Stdin pipe → works with piped input
- No TTY → works in non-interactive mode
- Ctrl+C → clean shutdown
```

### Example Test Patterns

#### Go (exec.Command)
```go
func TestListCommand(t *testing.T) {
    cmd := exec.Command("./bin/mytool", "list", "--format", "json")
    out, err := cmd.CombinedOutput()
    require.NoError(t, err, "command failed: %s", string(out))

    var items []Item
    require.NoError(t, json.Unmarshal(out, &items))
    assert.NotEmpty(t, items)
}

func TestInvalidFlag(t *testing.T) {
    cmd := exec.Command("./bin/mytool", "--invalid-flag")
    out, err := cmd.CombinedOutput()
    assert.Error(t, err)
    assert.Contains(t, string(out), "unknown flag")
}
```

#### Rust (assert_cmd)
```rust
use assert_cmd::Command;

#[test]
fn test_list_command() {
    Command::cargo_bin("mytool")
        .unwrap()
        .arg("list")
        .arg("--format")
        .arg("json")
        .assert()
        .success()
        .stdout(predicates::str::contains("["));
}
```

#### Python (subprocess)
```python
import subprocess

def test_list_command():
    result = subprocess.run(
        ["python", "-m", "mytool", "list", "--format", "json"],
        capture_output=True, text=True
    )
    assert result.returncode == 0
    data = json.loads(result.stdout)
    assert isinstance(data, list)
```

#### Node.js (execa)
```typescript
import { execa } from 'execa';

test('list command outputs JSON', async () => {
  const { stdout, exitCode } = await execa('./bin/mytool', ['list', '--format', 'json']);
  expect(exitCode).toBe(0);
  const data = JSON.parse(stdout);
  expect(Array.isArray(data)).toBe(true);
});
```

### Step 3: Run Tests

```bash
# Use the project's test command
go test ./...
cargo test
npm test
pytest tests/
```

### Step 4: Verify Test Quality

After tests pass, verify:

1. **All subcommands tested** — Every command/subcommand has at least one test
2. **All flags tested** — Each flag is exercised in at least one test
3. **Help text correct** — `--help` output matches actual behavior
4. **Error messages helpful** — Errors tell the user what to do, not just what went wrong
5. **Exit codes consistent** — 0 for success, 1 for user error, 2 for system error

## Verification Checklist

For each CLI feature, verify:

- [ ] Command produces correct output for valid input
- [ ] Exit code is 0 on success
- [ ] Exit code is non-zero on failure
- [ ] Error messages go to stderr (not stdout)
- [ ] Error messages are actionable (tell user how to fix)
- [ ] `--help` flag works and is accurate
- [ ] Flags have short and long forms where appropriate
- [ ] Output formats work (text, json, table, csv if supported)
- [ ] Piped input works (`echo "data" | mytool process`)
- [ ] File arguments handle missing/unreadable files gracefully
- [ ] Quiet/verbose modes work if supported

## Parent Agent Post-Verification

After subagent completes, parent MUST:
1. Confirm all tests pass
2. Run a quick smoke test: `./bin/mytool --help` or equivalent
3. Verify error cases are tested (not just happy paths)
4. If test coverage seems thin, launch a follow-up subagent
