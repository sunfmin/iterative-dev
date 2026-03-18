# Web Verification Strategy

Verify web features using Playwright E2E tests with screenshot capture and visual review.

**This is the verification strategy for project type: `web`**

## Overview

Web projects are verified through:
1. **E2E tests** — Playwright tests exercising user journeys
2. **Screenshots** — Captured at key states for visual review
3. **Visual review** — AI agent reviews every screenshot against quality criteria
4. **UX standards compliance** — Loading/empty/error states, responsive, accessible

## Prerequisites

```bash
npm install -D @playwright/test
npx playwright install
```

## Process

### Step 1: Ensure Environment is Running

```bash
# Check frontend and backend ports (adjust for your project)
lsof -i :3000 | head -2  # Frontend
lsof -i :8082 | head -2  # Backend
```

If not running, start them with `bash init.sh`.

### Step 2: Write E2E Tests with Screenshots

Every test MUST capture screenshots at key user journey points.

**Screenshot directory:** Screenshots are stored in `e2e/screenshots/` relative to the directory containing `playwright.config.ts`. In a monorepo with `frontend/`, this is `frontend/e2e/screenshots/`. In a standalone frontend project, this is `e2e/screenshots/` at the project root. The parent agent resolves this to an absolute path and passes it as `{screenshots_dir}` in the subagent prompt.

```typescript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');

  // Screenshot: Initial state
  // Path is relative to the Playwright project root (where playwright.config.ts lives)
  await page.screenshot({
    path: `e2e/screenshots/${scope}-feature-${id}-step1-login-initial.png`,
    fullPage: true
  });

  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Login' }).click();

  await expect(page).toHaveURL('/dashboard');

  // Screenshot: After action
  await page.screenshot({
    path: `e2e/screenshots/${scope}-feature-${id}-step2-dashboard-after-login.png`,
    fullPage: true
  });
});
```

### Step 3: Run Tests

```bash
npx playwright test
```

### Step 4: Visual Review (MANDATORY)

Use the Read tool to open and visually inspect EVERY screenshot. Evaluate:

#### Layout
- Content fits without overflow or clipping
- Proper alignment (grid, flex)

#### Spacing
- Consistent spacing patterns (4/8/16/24/32px scale)
- Not too cramped or sparse

#### Visual Hierarchy
- Most important action is obvious
- Page title > section title > body text size hierarchy

#### States
- Loading state present (skeleton or spinner)
- Empty state present (icon + message + CTA)
- Error state present and styled

#### Aesthetics
- Polished and intentional, not generic/prototype-level
- Typography is distinctive and hierarchical
- Color palette is cohesive
- Visual depth: appropriate shadows, borders

#### Consistency
- Similar screens use same patterns
- Colors consistent with theme

### Step 5: Fix Issues

If screenshots reveal problems:
1. Locate the relevant component file
2. Make targeted CSS/layout changes
3. Re-run tests to capture updated screenshots
4. Review again until all issues resolved

**Priority order:**
1. Broken layout (overflow, clipping, misalignment)
2. Missing states (loading, empty, error)
3. Accessibility issues (contrast, focus rings, labels)
4. Visual polish (shadows, transitions, typography)
5. Consistency issues (spacing, colors)

## Screenshot Naming Convention

Format: `{scope}-feature-{id}-step{N}-{description}.png`

Examples:
- `auth-feature-17-step3-modal-open.png`
- `core-feature-7-step6-project-in-list.png`

## Playwright Configuration

```typescript
export default defineConfig({
  timeout: 10000,
  expect: { timeout: 3000 },
  reporter: [
    ['list'],
    ['json', { outputFile: 'e2e/test-results/results.json' }],
  ],
  use: {
    actionTimeout: 5000,
    navigationTimeout: 10000,
    screenshot: 'on',
    trace: 'retain-on-failure',
  },
});
```

## Full-Stack Integration Smoke Test (NON-NEGOTIABLE for web projects with backend)

When a feature connects the frontend to a real backend API (e.g., replacing mock data with real API calls), a **live integration smoke test** MUST be performed. This catches issues that TypeScript compilation alone cannot detect — CORS, route prefix mismatches, response envelope mismatches, and authentication failures.

### When to Run

Run this smoke test for ANY feature that:
- Replaces mock/stub data with real API calls
- Changes the API base URL, fetch wrapper, or custom client
- Modifies backend route registration or middleware
- Is the first feature to connect a previously-mocked frontend to the real backend

### Process

**Step 1: Start both servers**

```bash
# Start backend (with real database)
cd backend && DATABASE_URL="..." go run ./cmd/api/ &
sleep 3

# Start frontend (pointing to backend)
cd frontend && VITE_API_BASE_URL=http://localhost:8080 pnpm dev &
sleep 3
```

**Step 2: Verify backend responds to API calls**

```bash
# Test a list endpoint directly (bypasses CORS — this tests the backend alone)
curl -s http://localhost:8080/api/v1/<resource> | head -5
```

If this returns 404, the route prefix is wrong (common with code generators like ogen that don't include the OpenAPI `servers.url` prefix in generated routes). Fix by mounting the generated server under the correct prefix (e.g., `http.StripPrefix("/api/v1", server)`).

**Step 3: Verify CORS headers**

```bash
curl -s -I -X OPTIONS http://localhost:8080/api/v1/<resource> \
  -H 'Origin: http://localhost:5173' | grep -i 'access-control'
```

If no `Access-Control-Allow-Origin` header is present, the browser will block all frontend requests. Add CORS middleware to the backend. This is the **#1 most common cause** of "frontend shows loading forever" bugs in full-stack web projects.

**Step 4: Seed test data and take screenshots**

```bash
# Seed at least 2-3 records via API
curl -X POST http://localhost:8080/api/v1/<resource> -H 'Content-Type: application/json' -d '...'
```

Then run Playwright screenshot tests against all major pages and **visually verify** that:
- Pages show **real data** (not loading skeletons or empty states)
- Data matches what was seeded (correct names, counts, values)
- No console errors in the browser (especially CORS or fetch failures)

**Step 5: Fail-fast criteria**

The integration smoke test FAILS if any of these are true:
- Backend returns 404 for known API endpoints → route prefix mismatch
- CORS headers are missing → add CORS middleware
- Screenshots show loading skeletons that never resolve → API calls failing silently
- Screenshots show empty states despite seeded data → response envelope mismatch
- Browser console shows fetch/network errors → connectivity or CORS issue

### Common Root Causes

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Backend returns 404 for /api/v1/... | Code generator (ogen, openapi-generator) registers routes without server URL prefix | Mount generated handler under `/api/v1` with `http.StripPrefix` or equivalent |
| Frontend shows loading forever | CORS: browser blocks cross-origin requests | Add CORS middleware (`Access-Control-Allow-Origin: *` for dev) |
| Frontend shows empty despite seeded data | Response envelope mismatch: frontend expects `{ data: ... }` but backend returns flat response, or vice versa | Align envelope handling in fetch wrapper or backend |
| API works via curl but not from browser | CORS (curl bypasses CORS, browsers enforce it) | Add CORS middleware |
| OPTIONS requests return 404 | Backend doesn't handle preflight requests | CORS middleware must handle OPTIONS with 204 No Content |

## Parent Agent Post-Verification

After subagent completes, parent MUST:
1. Confirm screenshots exist: `ls {screenshots_dir}/{scope}-feature-{id}-*.png 2>/dev/null | wc -l`
   (`{screenshots_dir}` = absolute path to `e2e/screenshots/` relative to `playwright.config.ts`)
2. Spot-check one screenshot with the Read tool
3. If quality is poor, launch a polish subagent
4. **For full-stack features**: verify screenshots show **real data**, not loading skeletons or empty states. If data is missing, run the integration smoke test above to diagnose.
