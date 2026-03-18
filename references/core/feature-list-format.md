# Feature List Format

The `feature_list.json` file is the single source of truth for project progress.

## Structure

```json
{
  "type": "web",
  "features": [
    {
      "id": 1,
      "category": "functional",
      "priority": "high",
      "description": "Brief description of the feature",
      "steps": [
        "Step 1: Perform action",
        "Step 2: Verify expected result"
      ],
      "passes": false
    }
  ]
}
```

## Top-Level Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Project type: `"web"`, `"api"`, `"cli"`, `"library"`, `"data"`, or `"mobile"`. Determines verification strategy and applicable standards. |
| `features` | array | Array of feature objects |

## Feature Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Unique numeric identifier within scope |
| `category` | string | Feature category (see below) |
| `priority` | string | "high", "medium", or "low" |
| `description` | string | Brief description of the feature |
| `steps` | array | Test steps to verify the feature |
| `passes` | boolean | Whether the feature passes all tests |

## Categories

Categories depend on project type:

| Type | Common Categories |
|------|------------------|
| **web** | `"functional"`, `"style"`, `"accessibility"` |
| **api** | `"functional"`, `"validation"`, `"security"` |
| **cli** | `"functional"`, `"usability"`, `"error-handling"` |
| **library** | `"functional"`, `"api-design"`, `"performance"` |
| **data** | `"functional"`, `"data-quality"`, `"performance"` |
| **mobile** | `"functional"`, `"style"`, `"accessibility"` |

You may use any category that makes sense for the project.

## Requirements

- Cover every feature in the scope's spec
- ALL features start with `"passes": false`
- Each feature has a unique numeric `id` (unique within scope)
- `type` field MUST be present at the top level

## Critical Rules

**NEVER:**
- Remove or edit feature descriptions
- Remove or edit test steps
- Weaken or delete tests
- Change a passing feature back to failing (unless genuine regression)
- **Create separate "testing" or "verification" features** — testing and verification MUST be embedded as steps within the feature they verify (see Self-Contained Features rule below)

**ONLY:**
- Change `"passes": false` to `"passes": true` after thorough verification

## Self-Contained Features (NON-NEGOTIABLE)

Every feature MUST be independently verifiable. This means:

1. **Each feature includes its own test/verification steps** — the `steps` array MUST contain steps that implement the feature AND steps that verify it (run tests, check types, validate behavior)
2. **NO separate "testing" or "verification" features** — never create features like "Write integration tests for X" or "Add E2E tests for all pages" as standalone features. Tests are part of the feature they test.
3. **NO deferred testing** — do not push testing to the end of the feature list. When a feature is marked `"passes": true`, it means the feature is implemented AND tested AND verified.
4. **A feature is not done until it is verified** — the subagent implementing each feature runs the verification strategy for the project type (see `references/verification/`) as part of that feature's implementation.

**Why:** When testing is a separate feature at the end, it creates a false sense of progress — features appear "done" but are unverified. It also makes the test-writing disconnected from the implementation context. Each feature must stand on its own: implemented, tested, and verified before moving on.

## Screenshot & Visual Review Steps (web/mobile — NON-NEGOTIABLE)

For `web` and `mobile` project types, every feature that produces or modifies UI MUST include **screenshot capture and visual review** as explicit steps in its `steps` array. Without these steps, the subagent will implement the UI but skip visual verification — and the parent agent's screenshot gate becomes the only safety net (which is too late and easy to miss).

**Rule:** If a feature creates or modifies any file that renders user-visible HTML/JSX (routes, components, pages, layouts), it is a UI feature and its `steps` MUST include:

1. A step to **capture screenshots** via Playwright at key states (list view, empty state, form, after action, error state)
2. A step to **run Playwright tests** and verify screenshots are generated
3. A step to **visually review** each screenshot for layout, spacing, hierarchy, states, and polish
4. A step to **fix visual issues** and re-capture until acceptable

**Anti-pattern (WRONG) — UI feature without screenshot steps:**
```json
{"id": 9, "description": "Category management pages", "steps": [
  "Create category list page with data table",
  "Create category form with validation",
  "Write E2E test: create category, verify it appears",
  "Run pnpm test — all pass"
]}
```

**Correct pattern — UI feature WITH screenshot steps:**
```json
{"id": 9, "description": "Category management pages", "steps": [
  "Create category list page with data table, empty state, loading skeleton",
  "Create category form with React Hook Form + Zod validation",
  "Write E2E test: seed data via API, verify list displays seeded data",
  "Write E2E test: create category via form, verify it appears in list",
  "Run pnpm tsc --noEmit and pnpm test — all pass",
  "Capture screenshots: list with data, empty state, create form, edit form, delete confirmation",
  "Run Playwright screenshot tests and verify PNGs are generated in e2e/screenshots/",
  "Visually review each screenshot: layout, spacing, hierarchy, loading/empty/error states, polish",
  "Fix any visual issues found in screenshots and re-capture until quality is acceptable"
]}
```

**Backend-only features** (services, models, API endpoints, migrations) do NOT need screenshot steps.

**Anti-pattern (WRONG):**
```json
{"id": 5, "description": "Product CRUD backend service", "steps": ["Implement create", "Implement list", "Implement update", "Implement delete"]},
{"id": 13, "description": "Backend integration tests for all services", "steps": ["Write tests for categories", "Write tests for products", "Run full suite"]}
```

**Correct pattern:**
```json
{"id": 5, "description": "Product CRUD backend service", "steps": [
  "Implement ProductService with Create, List, GetByID, Update, Delete",
  "Write integration tests: create product, verify response matches fixture",
  "Write integration tests: list with pagination, filter by category/status",
  "Write integration tests: update product, delete product, duplicate SKU rejection",
  "Run go test -v -race ./tests/ and verify all pass"
]}

## Priority Order

Work on features in this order:
1. **high** priority first
2. **medium** priority second
3. **low** priority last
4. Within same priority, work in order they appear in the file

## Best Practices for Test Steps

### Write Verifiable Steps

Every feature's test steps should be concrete and verifiable. The steps depend on project type:

**Web projects:**
- "Step N: Verify loading skeleton appears while data loads"
- "Step N: Verify empty state shows icon, message, and CTA when no items exist"
- "Step N: Verify the page renders correctly at mobile width (375px)"

**API projects:**
- "Step N: POST /api/products with valid body returns 201 and product object"
- "Step N: POST /api/products with missing name returns 400 with field error"
- "Step N: GET /api/products without auth returns 401"

**CLI projects:**
- "Step N: Run `mytool list --format json` and verify JSON output"
- "Step N: Run `mytool` with no args and verify help text is shown"
- "Step N: Run `mytool process --input missing.txt` and verify error message"

**Library projects:**
- "Step N: Call parse('valid input') and verify correct result"
- "Step N: Call parse('') and verify it returns descriptive error"
- "Step N: Verify Parse is exported from the public API"

**Data projects:**
- "Step N: Run pipeline with sample input and verify output schema"
- "Step N: Run pipeline with empty input and verify empty output (not error)"
- "Step N: Verify aggregation totals match expected values"

**Mobile projects:**
- "Step N: Tap login button and verify navigation to dashboard"
- "Step N: Verify loading indicator during API call"
- "Step N: Verify layout on small screen (iPhone SE)"

## Examples

Note: Every example below shows features that are **self-contained** — each feature includes implementation AND test/verification steps. There are no separate "write tests" features.

### Web Project (Full-Stack)
```json
{
  "type": "web",
  "features": [
    {
      "id": 1,
      "category": "functional",
      "priority": "high",
      "description": "User registration with email and password",
      "steps": [
        "Implement registration API endpoint (POST /api/register)",
        "Write backend integration test: valid registration returns 201 with user object",
        "Write backend integration test: duplicate email returns 409",
        "Write backend integration test: missing fields return 400 with validation errors",
        "Run go test -v -race ./tests/ and verify backend tests pass",
        "Implement registration form UI with React Hook Form + Zod validation",
        "Handle loading, error, and success states in the form",
        "Write E2E test: navigate to /register, submit empty form, verify inline validation errors",
        "Write E2E test: fill valid data, submit, verify redirect to dashboard",
        "Run pnpm tsc --noEmit and pnpm test, verify all pass",
        "Capture screenshots: registration form empty, form with validation errors, form submitting (loading), successful redirect to dashboard",
        "Run Playwright screenshot tests, verify PNGs generated in e2e/screenshots/",
        "Visually review each screenshot: layout, spacing, form field alignment, error message styling, loading state, overall polish",
        "Fix any visual issues found and re-capture until quality is acceptable"
      ],
      "passes": false
    }
  ]
}
```

### API Project
```json
{
  "type": "api",
  "features": [
    {
      "id": 1,
      "category": "functional",
      "priority": "high",
      "description": "Create product endpoint",
      "steps": [
        "Implement POST /api/products handler with validation",
        "Write integration test: POST with valid body returns 201 with id, name, price, created_at",
        "Write integration test: POST with missing required field returns 400 with field error",
        "Write integration test: POST with invalid price returns 400 with validation error",
        "Write integration test: GET /api/products/{id} returns the created product",
        "Run go test -v -race ./tests/ and verify all pass"
      ],
      "passes": false
    }
  ]
}
```

### CLI Project
```json
{
  "type": "cli",
  "features": [
    {
      "id": 1,
      "category": "functional",
      "priority": "high",
      "description": "Init command creates project structure",
      "steps": [
        "Implement init command with directory creation and config generation",
        "Write test: `mytool init myproject` in empty directory creates src/, tests/, config/",
        "Write test: verify config file has correct defaults",
        "Write test: `mytool init` without name shows error message with usage hint",
        "Write test: `mytool init myproject` again is idempotent (no error, no overwrite)",
        "Run all tests and verify they pass"
      ],
      "passes": false
    }
  ]
}
```

### Library Project
```json
{
  "type": "library",
  "features": [
    {
      "id": 1,
      "category": "functional",
      "priority": "high",
      "description": "Parse function handles all input formats",
      "steps": [
        "Implement parse() function for string, interpolation, and edge case inputs",
        "Write unit test: parse('simple string') returns correct AST node",
        "Write unit test: parse('nested {value}') handles interpolation",
        "Write unit test: parse('') returns descriptive error",
        "Write unit test: parse(null) returns descriptive error without panic",
        "Verify Parse is exported in public API",
        "Run all tests and verify they pass"
      ],
      "passes": false
    }
  ]
}
```
