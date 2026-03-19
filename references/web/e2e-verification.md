# E2E Screenshot Verification — Full Details

> **Subagent reference:** This file is inlined in subagent prompts for quick reference on screenshot mechanics. For the FULL verification process (including interaction tests), see `references/verification/web-verification.md`.

Verify features work correctly using Playwright E2E tests with screenshot capture and visual review.

**Interaction tests that prove user outcomes are the PRIMARY verification.** Tests must perform real user actions (click, fill, submit, navigate) and verify observable results (data appears, page navigates, state changes). Screenshots are SECONDARY — they verify visual quality and catch layout/styling issues that interaction tests cannot detect. Both are required, but a feature that passes interaction tests with rough visuals is closer to done than one with perfect screenshots but broken behavior.

## Screenshot Directory

Screenshots are stored per-scope at `specs/{scope}/screenshots/` relative to the project root. The parent agent resolves this to an absolute path (`{pwd}/specs/{scope}/screenshots/`) and passes it as `{screenshots_dir}` in the subagent prompt.

In Playwright test code, always use the **absolute** `{screenshots_dir}` path provided by the parent agent in `page.screenshot()` calls.

## Prerequisites

Ensure Playwright is set up:

```bash
npm install -D @playwright/test
npx playwright install
```

## Step-by-Step Process

### Step 1: Ensure Environment is Running

```bash
lsof -i :3000 | head -2  # Frontend
lsof -i :8082 | head -2  # Backend
```

If not running, start them with `bash init.sh`.

### Step 2: Ensure Screenshot Directory Exists

```bash
# Screenshots are committed to the repo as results — never delete them
# New screenshots will overwrite same-named files; old ones are preserved as history
mkdir -p specs/{scope}/screenshots
rm -rf test-results/**/*.png 2>/dev/null || true
```

### Step 3: Run E2E Tests

```bash
# Run all tests
npx playwright test

# Or run specific test file
npx playwright test e2e/auth.spec.ts

# Or run tests matching a pattern
npx playwright test --grep "login"
```

### Step 4: Check Test Results

If tests fail, check error context:

```bash
# Find error context files
find test-results -name "error-context.md" 2>/dev/null | head -5

# Find failure screenshots
find test-results -name "*.png" -type f | sort
```

Common failure causes:
- Backend not running
- Database not seeded
- Port conflicts
- Stale selectors

### Step 5: List All Screenshots

```bash
find specs/{scope}/screenshots -name "*.png" -type f 2>/dev/null | sort
find test-results -name "*.png" -type f 2>/dev/null | sort
```

### Step 6: Review Each Screenshot (MANDATORY)

**CRITICAL**: Use the Read tool to open and visually inspect EVERY screenshot. For each screenshot, explicitly evaluate:

#### Layout
- ✓/✗ Content fits without overflow?
- ✓/✗ No clipping or cut-off elements?
- ✓/✗ Proper alignment (grid, flex)?

#### Spacing
- ✓/✗ Appropriate padding/margins?
- ✓/✗ Not too cramped or sparse?
- ✓/✗ Consistent spacing patterns (follows 4/8/16/24/32px scale)?

#### Touch Targets
- ✓/✗ Buttons/inputs at least 44px?
- ✓/✗ Clickable areas visually obvious?

#### Visual Hierarchy
- ✓/✗ Most important action is obvious?
- ✓/✗ Disabled states clearly distinguishable?
- ✓/✗ Focus states visible?
- ✓/✗ Page title > section title > body text size hierarchy?

#### States
- ✓/✗ Loading state present (skeleton or spinner)?
- ✓/✗ Empty state present (icon + message + CTA)?
- ✓/✗ Error state present and styled (red text, red borders)?

#### Aesthetics (follow /frontend-design principles)
- ✓/✗ Looks polished and intentional, not generic/prototype-level?
- ✓/✗ Typography is distinctive and hierarchical?
- ✓/✗ Color palette is cohesive?
- ✓/✗ Visual depth: appropriate shadows, borders, or textures?
- ✓/✗ Micro-interactions: hover/focus transitions visible?

#### Data Display
- ✓/✗ Shows real data, not placeholders?
- ✓/✗ Numbers right-aligned in tables?
- ✓/✗ Status badges have colored backgrounds with text?

#### Consistency
- ✓/✗ Similar screens use same patterns?
- ✓/✗ Colors consistent with theme?
- ✓/✗ Icons consistent in style and size?
- ✓/✗ Spacing consistent with other pages?

### Step 7: Fix Issues Found

If screenshots reveal problems:

1. Locate the relevant component file
2. Make targeted CSS/layout changes
3. Prefer Tailwind utilities over custom CSS
4. Keep all `data-testid` attributes intact
5. Re-run tests to capture updated screenshots
6. Review again until all issues resolved
7. Focus on the biggest visual impact first

**Priority order for fixes:**
1. Broken layout (overflow, clipping, misalignment)
2. Missing states (loading, empty, error)
3. Accessibility issues (contrast, focus rings, labels)
4. Visual polish (shadows, transitions, typography)
5. Consistency issues (spacing, colors)

### Step 8: Document Verification

After successful verification, note:
- Which features were verified
- Any UX improvements made
- Screenshots reviewed (count)
- Visual quality assessment

## Writing Good E2E Tests

### Key Principles

1. **Use data-testid** for stable selectors
2. **EVERY test MUST capture at least one screenshot** — no exceptions
3. **Wait for conditions**, not timeouts
4. **Test at multiple viewports** for responsive features
5. **Mock external APIs** when needed

### Example Test with Screenshots (REQUIRED PATTERN)

```typescript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');

  // Screenshot: Login page initial state
  await page.screenshot({
    path: `${screenshots_dir}/feature-1-step1-login-initial.png`,
    fullPage: true
  });

  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Login' }).click();

  await expect(page).toHaveURL('/dashboard');

  // Screenshot: Dashboard after login
  await page.screenshot({
    path: `${screenshots_dir}/feature-1-step2-dashboard-after-login.png`,
    fullPage: true
  });
});
```

### Screenshot Rules (MANDATORY)

- **Every test MUST have at least one `page.screenshot()` call**
- Name screenshots descriptively (scope is encoded in the directory path)
- Use `fullPage: true` to capture complete page state
- Capture at key user journey points (before action, after action, error state)
- Include error states and empty states in screenshots
- Capture responsive breakpoints if the feature involves responsive behavior:
  ```typescript
  // Desktop screenshot
  await page.setViewportSize({ width: 1280, height: 720 });
  await page.screenshot({
    path: `${screenshots_dir}/feature-1-step1-desktop.png`,
    fullPage: true
  });

  // Mobile screenshot
  await page.setViewportSize({ width: 375, height: 812 });
  await page.screenshot({
    path: `${screenshots_dir}/feature-1-step1-mobile.png`,
    fullPage: true
  });
  ```

### Screenshot Naming Convention

Format: `feature-{id}-step{N}-{description}.png` (scope is encoded in the directory path `specs/{scope}/screenshots/`)

Examples:
- `feature-17-step3-modal-open.png`
- `feature-7-step6-project-in-list.png`
- `feature-15-complete-flow.png`
- `feature-4-step2-validation-errors.png`

## Playwright Configuration

Optimize for AI agent consumption:

```typescript
export default defineConfig({
  // Short timeouts - fail fast
  timeout: 10000,           // 10s max per test
  expect: {
    timeout: 3000,          // 3s max for assertions
  },

  // AI-readable output format
  reporter: [
    ['list'],               // Simple pass/fail list
    ['json', { outputFile: 'e2e/test-results/results.json' }],
  ],

  use: {
    actionTimeout: 5000,    // 5s max for clicks/fills
    navigationTimeout: 10000,
    screenshot: 'on',       // Keep ALL screenshots
    trace: 'retain-on-failure',
  },
});
```

**Why keep ALL screenshots:**
- AI agents need to review UI for UX issues, not just failures
- Success screenshots enable visual regression detection
- Human reviewers can audit AI's work quality
- Screenshots supplement interaction tests by catching visual regressions

**Why short timeouts:**
- Long waits waste tokens and time
- Missing elements should fail immediately
- Fast feedback enables rapid iteration
- AI can read JSON results directly

## Troubleshooting

### Tests Timeout
- Increase timeout in playwright.config.ts
- Check if backend is responding
- Look for infinite loading states

### Flaky Tests
- Use `await expect()` instead of raw assertions
- Wait for network idle: `await page.waitForLoadState('networkidle')`
- Add retries in CI

### Screenshots Blank or Wrong
- Ensure page fully loaded before screenshot
- Check viewport size
- Verify correct URL navigation
- Add `await page.waitForLoadState('networkidle')` before screenshot

### UI Looks Generic in Screenshots
- Review references/web/frontend-design.md and references/web/ux-standards.md
- Check for: distinctive typography, cohesive colors, proper shadows/depth
- Verify loading/empty/error states are polished, not bare text
- Add micro-interactions: hover transitions, focus effects
