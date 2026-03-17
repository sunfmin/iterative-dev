# Mobile Verification Strategy

Verify mobile app features through E2E tests with screenshot capture and visual review.

**This is the verification strategy for project type: `mobile`**

## Overview

Mobile projects are verified through:
1. **E2E tests** — Detox (React Native) or XCTest/Espresso (native) exercising user flows
2. **Screenshots** — Captured at key states for visual review
3. **Visual review** — AI agent reviews every screenshot against quality criteria
4. **Device coverage** — Test on multiple screen sizes

## Prerequisites

### React Native (Detox)
```bash
npm install -D detox
npx detox build --configuration ios.sim.debug
```

### Flutter
```bash
flutter test integration_test/
```

### Native iOS (XCTest)
```bash
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Process

### Step 1: Ensure Emulator/Simulator is Running

```bash
# iOS Simulator
xcrun simctl list devices | grep Booted

# Android Emulator
adb devices
```

### Step 2: Write E2E Tests with Screenshots

Every test MUST capture screenshots at key states.

#### Detox (React Native)
```javascript
describe('Login', () => {
  it('should login successfully', async () => {
    await device.takeScreenshot('login-initial');

    await element(by.id('email-input')).typeText('test@example.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();

    await expect(element(by.id('dashboard'))).toBeVisible();
    await device.takeScreenshot('dashboard-after-login');
  });
});
```

#### Flutter
```dart
testWidgets('login flow', (tester) async {
  await tester.pumpWidget(MyApp());

  // Screenshot: initial
  await expectLater(find.byType(MyApp), matchesGoldenFile('login-initial.png'));

  await tester.enterText(find.byKey(Key('email')), 'test@example.com');
  await tester.enterText(find.byKey(Key('password')), 'password123');
  await tester.tap(find.byKey(Key('login-button')));
  await tester.pumpAndSettle();

  // Screenshot: after login
  await expectLater(find.byType(MyApp), matchesGoldenFile('dashboard.png'));
});
```

### Step 3: Run Tests

```bash
# Detox
npx detox test --configuration ios.sim.debug

# Flutter
flutter test integration_test/

# XCTest
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Step 4: Visual Review (MANDATORY)

Use the Read tool to inspect EVERY screenshot. Evaluate:

#### Layout
- Content fits screen without horizontal scrolling
- No elements clipped by safe area (notch, home indicator)
- Proper alignment and spacing

#### Touch Targets
- All tappable elements at least 44x44 points
- Adequate spacing between touch targets

#### Platform Conventions
- iOS: follows HIG (navigation bars, tab bars, system colors)
- Android: follows Material Design (app bars, FAB, bottom nav)
- Platform-appropriate gestures and transitions

#### States
- Loading indicators present during async operations
- Empty states with helpful messaging
- Error states with recovery options
- Pull-to-refresh where appropriate

#### Aesthetics
- Polished and platform-native feel
- Typography matches platform conventions
- Colors and theming consistent
- Smooth transitions between screens

#### Device Sizes
- Works on small screens (iPhone SE / small Android)
- Works on large screens (iPhone Pro Max / tablet)
- Landscape orientation handled (if applicable)

### Step 5: Fix Issues

If screenshots reveal problems:
1. Fix layout/styling in the relevant component
2. Re-run tests to capture updated screenshots
3. Review again until all issues resolved

## Verification Checklist

For each mobile feature, verify:

- [ ] E2E test passes on target platform(s)
- [ ] Screenshots captured at key states
- [ ] Touch targets are minimum 44x44 points
- [ ] Safe area respected (notch, home indicator)
- [ ] Loading states present for async operations
- [ ] Error states present with recovery options
- [ ] Works on small and large screen sizes
- [ ] Platform conventions followed (HIG/Material)
- [ ] Accessibility labels present on interactive elements

## Parent Agent Post-Verification

After subagent completes, parent MUST:
1. Confirm screenshots exist for this feature
2. Spot-check one screenshot with the Read tool
3. If quality is poor, launch a polish subagent
4. Verify platform conventions are followed
