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

**ONLY:**
- Change `"passes": false` to `"passes": true` after thorough verification

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

### Web Project
```json
{
  "type": "web",
  "features": [
    {
      "id": 1,
      "category": "functional",
      "priority": "high",
      "description": "User can register with email and password",
      "steps": [
        "Step 1: Navigate to /register",
        "Step 2: Verify registration form loads with proper layout",
        "Step 3: Submit empty form and verify inline validation errors",
        "Step 4: Fill in email and password fields",
        "Step 5: Click Register and verify loading state on button",
        "Step 6: Verify redirect to dashboard"
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
        "Step 1: POST /api/products with valid body returns 201",
        "Step 2: Response contains id, name, price, created_at",
        "Step 3: POST with missing required field returns 400 with field error",
        "Step 4: POST with invalid price returns 400 with validation error",
        "Step 5: GET /api/products/{id} returns the created product"
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
        "Step 1: Run `mytool init myproject` in empty directory",
        "Step 2: Verify directory structure created (src/, tests/, config/)",
        "Step 3: Verify config file has correct defaults",
        "Step 4: Run `mytool init` without name and verify error message",
        "Step 5: Run `mytool init myproject` again and verify idempotent behavior"
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
        "Step 1: parse('simple string') returns correct AST node",
        "Step 2: parse('nested {value}') handles interpolation",
        "Step 3: parse('') returns descriptive error",
        "Step 4: parse(null) returns descriptive error without panic",
        "Step 5: Verify Parse is exported in public API"
      ],
      "passes": false
    }
  ]
}
```
