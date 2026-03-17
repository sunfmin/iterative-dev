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

Every test MUST capture screenshots at key user journey points:

```typescript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');

  // Screenshot: Initial state
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

## Parent Agent Post-Verification

After subagent completes, parent MUST:
1. Confirm screenshots exist: `ls e2e/screenshots/{scope}-feature-{id}-*.png 2>/dev/null | wc -l`
2. Spot-check one screenshot with the Read tool
3. If quality is poor, launch a polish subagent
