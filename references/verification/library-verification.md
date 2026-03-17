# Library Verification Strategy

Verify library features through unit tests, public API validation, and integration examples.

**This is the verification strategy for project type: `library`**

## Overview

Library projects are verified through:
1. **Unit tests** — Thorough testing of all public functions/methods
2. **Public API validation** — Exports, types, and interfaces are correct
3. **Integration examples** — Real usage patterns work end-to-end
4. **Edge case coverage** — Nil/null inputs, boundary values, concurrent access

## Process

### Step 1: Ensure Library Builds

```bash
# Build/compile the library (adjust for your project)
go build ./...                    # Go
cargo build                       # Rust
npm run build                     # Node.js/TypeScript
python -m py_compile src/*.py     # Python
```

### Step 2: Write Unit Tests

Every public function/method MUST have tests covering:

**Happy path:**
```
- Valid inputs → correct outputs
- All overloads/variants work
- Return types are correct
```

**Error cases:**
```
- Invalid inputs → clear error (not panic/crash)
- Nil/null/undefined → handled gracefully
- Out-of-range values → descriptive error
- Type mismatches → compile-time or clear runtime error
```

**Edge cases:**
```
- Empty collections → correct behavior (not crash)
- Boundary values → correct at min/max
- Concurrent access → thread-safe if documented as such
- Large inputs → handles without excessive memory/time
```

### Example Test Patterns

#### Go
```go
func TestParse(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Result
        wantErr bool
    }{
        {"valid input", "hello", &Result{Value: "hello"}, false},
        {"empty input", "", nil, true},
        {"special chars", "a&b<c", &Result{Value: "a&b<c"}, false},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.input)
            if tt.wantErr {
                require.Error(t, err)
                return
            }
            require.NoError(t, err)
            assert.Equal(t, tt.want, got)
        })
    }
}
```

#### Rust
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_valid_input() {
        let result = parse("hello").unwrap();
        assert_eq!(result.value, "hello");
    }

    #[test]
    fn parse_empty_returns_error() {
        assert!(parse("").is_err());
    }
}
```

#### TypeScript
```typescript
describe('parse', () => {
  it('parses valid input', () => {
    expect(parse('hello')).toEqual({ value: 'hello' });
  });

  it('throws on empty input', () => {
    expect(() => parse('')).toThrow('Input cannot be empty');
  });

  it('handles special characters', () => {
    expect(parse('a&b<c')).toEqual({ value: 'a&b<c' });
  });
});
```

#### Python
```python
def test_parse_valid():
    assert parse("hello") == Result(value="hello")

def test_parse_empty_raises():
    with pytest.raises(ValueError, match="cannot be empty"):
        parse("")
```

### Step 3: Run Tests

```bash
go test ./... -v -race            # Go (with race detection)
cargo test                         # Rust
npm test                           # Node.js
pytest tests/ -v                   # Python
```

### Step 4: Verify Test Quality

After tests pass, verify:

1. **All public API tested** — Every exported function/type/method has tests
2. **Table-driven tests** — Use table tests for functions with multiple input combinations
3. **Error paths tested** — Not just happy paths
4. **No test interdependence** — Tests pass in any order, no shared mutable state
5. **Type safety** — TypeScript: no `any` in public API; Go: no `interface{}` leaking

### Step 5: Verify Public API Surface

Check that the library's public API is intentional:

```bash
# Go: check exported symbols
go doc ./...

# TypeScript: check exports
grep -r "export " src/index.ts

# Python: check __all__ or public functions
grep -r "def [^_]" src/

# Rust: check pub items
grep -r "pub fn\|pub struct\|pub enum\|pub trait" src/
```

Ensure:
- No internal helpers accidentally exported
- Types are exported alongside functions that use them
- Deprecated items are marked

## Verification Checklist

For each library feature, verify:

- [ ] All public functions have unit tests
- [ ] Error cases return descriptive errors (not panics/crashes)
- [ ] Edge cases handled (nil, empty, boundary values)
- [ ] Types are correct and exported
- [ ] No unintended public API surface
- [ ] Thread safety documented and tested (if applicable)
- [ ] Performance is reasonable for expected input sizes
- [ ] Documentation/comments on public API are accurate

## Parent Agent Post-Verification

After subagent completes, parent MUST:
1. Confirm all tests pass (including race detection if applicable)
2. Verify public API surface hasn't accidentally expanded
3. Check that error types/messages are consistent
4. If test coverage seems thin, launch a follow-up subagent
