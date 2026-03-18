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

## Outcome-Oriented Features (NON-NEGOTIABLE)

### The Problem This Solves

The #1 cause of features that "pass" but don't work is **component-level feature definition**. When features are defined as UI components ("category list page", "category form", "delete dialog"), each component gets verified in isolation — but nobody verifies the user can actually complete the journey across components. The Edit button may exist on the list page, but if it navigates to a broken route, or the form doesn't submit, or the submission doesn't update the list, the feature is marked "passes: true" anyway because each component *looks* correct in its screenshot.

### The Rule

**Features MUST be defined as user outcomes, not implementation components.**

Ask: "What can the user (or caller) DO when this feature is done?" — not "What UI component (or module) exists?"

This applies universally to all project types:
- **Web/Mobile:** "User can manage categories" — not "Category list page" + "Category form" + "Delete dialog"
- **API:** "Client can manage products via REST" — not "POST endpoint" + "GET endpoint" + "PUT endpoint"
- **CLI:** "User can initialize and configure a project" — not "Init command" + "Config file generation"
- **Library:** "Caller can parse, transform, and serialize data" — not "Parse function" + "Transform function" + "Serialize function"
- **Data:** "Pipeline ingests, transforms, and outputs daily reports" — not "Ingestion step" + "Transform step" + "Output step"

### Why This Works

When a feature is an outcome ("user can manage categories"), the verification naturally covers the full journey:
- Can the user see the list? (list renders with data)
- Can the user create one? (form works, submission saves, new item appears in list)
- Can the user edit one? (edit loads existing data, changes persist)
- Can the user delete one? (confirmation works, item removed)

When a feature is a component ("category list page"), the verification only covers that component:
- Does the page render? ✓ (but Edit button may be broken)
- Does it look nice? ✓ (but clicking anything may fail)

### Infrastructure / Scaffolding Exception

Some features are genuinely infrastructure with no user-facing outcome: project setup, database migration, code generation, CI/CD configuration. These are fine as component-level features. The rule applies to features that deliver **user-facing or caller-facing functionality**.

## Self-Contained Features (NON-NEGOTIABLE)

Every feature MUST be independently verifiable. This means:

1. **Each feature includes its own test/verification steps** — the `steps` array MUST contain steps that implement the feature AND steps that verify it (run tests, check types, validate behavior)
2. **NO separate "testing" or "verification" features** — never create features like "Write integration tests for X" or "Add E2E tests for all pages" as standalone features. Tests are part of the feature they test.
3. **NO deferred testing** — do not push testing to the end of the feature list. When a feature is marked `"passes": true`, it means the feature is implemented AND tested AND verified.
4. **A feature is not done until it is verified** — the subagent implementing each feature runs the verification strategy for the project type (see `references/verification/`) as part of that feature's implementation.

**Why:** When testing is a separate feature at the end, it creates a false sense of progress — features appear "done" but are unverified. It also makes the test-writing disconnected from the implementation context. Each feature must stand on its own: implemented, tested, and verified before moving on.

## Verification Must Prove the Outcome (NON-NEGOTIABLE)

This is the universal verification principle that applies to ALL project types:

**Verification must prove the user/caller can achieve the outcome described in the feature, not just that the code exists or compiles.**

| Project Type | WRONG verification | RIGHT verification |
|-------------|-------------------|-------------------|
| **Web** | Screenshot of a page that renders | Playwright test: user clicks, fills, submits, and sees result |
| **API** | Code compiles, handler function exists | Integration test: HTTP request returns correct response |
| **CLI** | Binary builds successfully | Run the command, verify output matches expected |
| **Library** | Types compile, function exists | Unit test: call function with input, verify output |
| **Data** | Pipeline script has no syntax errors | Run pipeline on sample data, verify output schema and values |
| **Mobile** | Screenshot of initial screen render | Interaction test: tap, swipe, verify navigation and state changes |

### How to Write Verification Steps

For each feature, ask: **"If I were a user/caller, how would I prove this works?"** Then write steps that do exactly that.

**Bad steps** (prove code exists):
```
"Create the product list component"
"Add the edit form route"
"Run tsc --noEmit"
"Take a screenshot"
```

**Good steps** (prove outcome works):
```
"Seed 3 products via API, navigate to /products, verify all 3 are visible with correct names and prices"
"Click Edit on a product, verify form loads with existing data, change the name, submit, verify the updated name appears in the list"
"Click Delete, confirm in dialog, verify the product is removed from the list"
"Run all tests and verify they pass"
```

The difference: bad steps verify the code was written. Good steps verify the feature works from the user's perspective.

## Screenshot & Visual Review Steps (web/mobile — NON-NEGOTIABLE)

For `web` and `mobile` project types, every feature that produces or modifies UI MUST include **screenshot capture and visual review** as explicit steps in its `steps` array. Screenshots are the secondary verification layer — they catch visual/design issues that interaction tests don't (spacing, alignment, colors, polish).

**Rule:** If a feature creates or modifies any file that renders user-visible HTML/JSX, its `steps` MUST include:

1. A step to **capture screenshots** via Playwright at key states (after completing user flows, at empty/loading/error states)
2. A step to **run Playwright tests** and verify screenshots are generated
3. A step to **visually review** each screenshot for layout, spacing, hierarchy, states, and polish
4. A step to **fix visual issues** and re-capture until acceptable

**IMPORTANT:** Screenshots supplement interaction tests — they do NOT replace them. A feature that has screenshots but no interaction tests is NOT verified. A feature that has interaction tests but no screenshots is functionally verified but not visually verified. Both are required.

**Backend-only features** (services, models, API endpoints, migrations) do NOT need screenshot steps.

## Priority Order

Work on features in this order:
1. **high** priority first
2. **medium** priority second
3. **low** priority last
4. Within same priority, work in order they appear in the file

## Best Practices for Test Steps

### Write Verifiable Steps

Every feature's test steps should be concrete and verifiable — they should describe **what the user/caller does and what they see/get back**, not what the developer builds.

**Web projects:**
- "Seed 2 items via API, navigate to /items, verify both items visible with correct data"
- "Click 'New Item', fill the form, submit, verify new item appears in the list"
- "Click Edit on an item, verify form has existing data, change a field, submit, verify change persists"
- "Delete an item, verify it's removed from the list"

**API projects:**
- "POST /api/products with valid body returns 201 and product object"
- "POST /api/products with missing name returns 400 with field error"
- "GET /api/products returns list including the created product"

**CLI projects:**
- "Run `mytool init myproject`, verify directory structure created"
- "Run `mytool init` without name, verify helpful error message shown"
- "Run `mytool init myproject` twice, verify idempotent (no error)"

**Library projects:**
- "Call parse('valid input') and verify correct result"
- "Call parse('') and verify it returns descriptive error"
- "Verify Parse is exported in public API"

**Data projects:**
- "Run pipeline with sample input and verify output schema"
- "Run pipeline with empty input and verify empty output (not error)"
- "Verify aggregation totals match expected values"

**Mobile projects:**
- "Tap login button, verify navigation to dashboard"
- "Fill search field, verify results filter in real-time"
- "Pull to refresh, verify data updates"

## Examples

Note: Every example below defines features as **user outcomes** with verification steps that **prove the outcome works**. Features are NOT split into component-level pieces.

### Web Project (Full-Stack)
```json
{
  "type": "web",
  "features": [
    {
      "id": 1,
      "category": "functional",
      "priority": "high",
      "description": "Project scaffolding and shared infrastructure",
      "steps": [
        "Initialize frontend (React, Vite, Router, UI library) and backend (Go, framework) projects",
        "Create shared OpenAPI spec, generate types for both sides",
        "Create root layout with navigation",
        "Verify frontend compiles and dev server starts",
        "Verify backend compiles"
      ],
      "passes": false
    },
    {
      "id": 2,
      "category": "functional",
      "priority": "high",
      "description": "User can manage categories (create, view list, edit, delete)",
      "steps": [
        "Implement backend: category CRUD endpoints with validation and error handling",
        "Write backend integration tests: create, list, get, update, delete, duplicate slug rejection",
        "Run backend tests and verify all pass",
        "Implement frontend: category list page, create form, edit form, delete confirmation",
        "Write E2E test: seed category via API, navigate to list, verify it's visible",
        "Write E2E test: click New, fill form, submit, verify new category in list",
        "Write E2E test: click Edit on a category, verify form has existing data, change name, submit, verify updated name in list",
        "Write E2E test: click Delete, confirm, verify category removed from list",
        "Run all tests, verify all pass",
        "Capture screenshots of list, create form, edit form, delete dialog, empty state",
        "Visually review screenshots for layout and polish",
        "Fix any issues and re-run until all tests pass and screenshots look good"
      ],
      "passes": false
    },
    {
      "id": 3,
      "category": "functional",
      "priority": "high",
      "description": "User can manage products (create, view list with filters, edit, delete, bulk status change)",
      "steps": [
        "Implement backend: product CRUD + bulk status + filtering endpoints",
        "Write backend integration tests: all CRUD ops, filters, bulk update, edge cases",
        "Run backend tests and verify all pass",
        "Implement frontend: product list with filters/search/pagination, create form, edit form, delete dialog, bulk actions",
        "Write E2E test: seed products, navigate to list, verify data visible with correct prices and statuses",
        "Write E2E test: create product with category selection, verify in list",
        "Write E2E test: edit a product, verify changes persist",
        "Write E2E test: delete a product, verify removed",
        "Write E2E test: select multiple products, bulk change status, verify statuses updated",
        "Write E2E test: filter by category, verify only matching products shown",
        "Run all tests, verify all pass",
        "Capture screenshots of list, filters active, bulk selection, forms, dialogs",
        "Visually review screenshots",
        "Fix any issues"
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
      "description": "Client can manage products via REST API (CRUD + validation)",
      "steps": [
        "Implement all product endpoints: POST, GET list, GET by ID, PUT, DELETE",
        "Write integration test: POST with valid body returns 201 with product",
        "Write integration test: POST with missing required field returns 400",
        "Write integration test: GET list returns created products with pagination",
        "Write integration test: PUT updates product, GET returns updated data",
        "Write integration test: DELETE removes product, GET returns 404",
        "Write integration test: POST with duplicate SKU returns 409",
        "Run all tests and verify they pass"
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
      "description": "User can initialize and configure a new project",
      "steps": [
        "Implement init command with directory creation and config generation",
        "Write test: `mytool init myproject` creates expected directory structure",
        "Write test: `mytool init myproject` generates config with correct defaults",
        "Write test: `mytool init` without name shows helpful error",
        "Write test: running init twice is idempotent",
        "Write test: `mytool init --template api` uses API template",
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
      "description": "Caller can parse all supported input formats into AST",
      "steps": [
        "Implement parse() for strings, interpolation, and nested expressions",
        "Write unit test: parse('simple string') returns correct AST",
        "Write unit test: parse('Hello {name}') handles interpolation",
        "Write unit test: parse('') returns descriptive error",
        "Write unit test: parse(null) returns error without panic",
        "Verify Parse is exported in public API",
        "Run all tests and verify they pass"
      ],
      "passes": false
    }
  ]
}
```
