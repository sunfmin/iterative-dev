# Code Quality Standards

Every feature implementation must meet these standards. Code that works but is messy, duplicated, or untestable is NOT complete.

## File Organization

- Keep files under 300 lines — split if larger
- One component/module per file
- Group related files in directories (e.g., `services/`, `utils/`, `components/`)
- Follow existing project conventions for file naming and placement

## Testable Architecture

- **Extract pure functions** out of UI components and handlers
- Move business logic, validation, data transformation, and state calculations into separate utility/service modules
- These modules must be unit-testable without DOM, network, or framework dependencies
- UI components should orchestrate; logic modules should compute

## Unit Testing

- Write unit tests for all extracted logic: pure functions, validators, transformers, state calculations, business rules
- Use the project's existing test framework
- Do NOT unit test UI rendering or things better covered by E2E tests
- Unit tests are for logic; E2E tests are for behavior
- All unit tests must pass before committing

## No Duplication

- If you see duplicated logic (in your code or existing code you touched), extract shared helpers
- Don't duplicate what already exists elsewhere in the codebase
- Check for existing utilities before writing new ones
- Prefer composition over copy-paste

## Code Style

- Follow existing code patterns and architecture in the project
- Keep functions small and single-purpose
- Name things clearly — intent over implementation
- Prefer composition over deep nesting
- Use stable test selectors appropriate to your project type (e.g., `data-testid` for web, accessibility identifiers for mobile, named exports for libraries)

## What NOT to Do

- Don't leave debug code or `console.log` statements
- Don't leave commented-out code
- Don't leave TODO comments without associated feature list items
- Don't introduce new patterns that conflict with existing project conventions
- Don't over-engineer — solve the current problem, not hypothetical future ones
