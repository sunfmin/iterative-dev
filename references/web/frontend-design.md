# Frontend Design Principles

> Adapted from the `/frontend-design` skill. These principles guide all UI implementation across iterative-dev projects of all types.

## Core Philosophy

Create distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Every UI decision should be intentional, not default.

## Design Thinking (Before Coding)

Before implementing any UI, pause and consider:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick a direction: brutally minimal, luxury/refined, playful, editorial/magazine, industrial/utilitarian, soft/pastel, etc. Admin dashboards often benefit from refined minimalism or industrial clarity.
- **Constraints**: Technical requirements (framework, performance, accessibility)
- **Differentiation**: What makes this memorable? What's the signature detail?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work — the key is intentionality, not intensity.

## Aesthetic Guidelines

### Typography
- Choose fonts that are beautiful, unique, and interesting
- **NEVER** use: Inter, Roboto, Arial, system fonts, or other generic defaults
- Opt for distinctive choices that elevate the interface
- Pair a display font with a refined body font
- Use font size contrast to create hierarchy (title vs body vs caption)

### Color & Theme
- Commit to a cohesive aesthetic — don't scatter colors randomly
- Use CSS variables for consistency across the app
- Dominant colors with sharp accents outperform timid, evenly-distributed palettes
- Dark themes and light themes both work — choose intentionally
- Avoid cliched AI color schemes (particularly purple gradients on white)

### Motion & Micro-interactions
- Use animations for high-impact moments: page load reveals, state transitions
- Prioritize CSS-only solutions for performance
- Focus on: hover states that surprise, smooth transitions between states, staggered reveals
- One well-orchestrated animation creates more delight than scattered micro-interactions
- Button feedback, loading spinners, and toast slide-ins should all feel intentional

### Spatial Composition
- Unexpected layouts > cookie-cutter grids
- Asymmetry, overlap, diagonal flow, grid-breaking elements can all work
- Generous negative space OR controlled density — pick one and commit
- For admin/dashboard UIs: clean grid with clear visual hierarchy usually works best

### Backgrounds & Visual Details
- Create atmosphere and depth rather than solid white/gray backgrounds
- Consider: subtle gradients, noise textures, geometric patterns, layered transparencies
- Dramatic shadows, decorative borders, grain overlays — use sparingly but intentionally
- For admin UIs: subtle texture or gradient in sidebar, clean content area

## Anti-Patterns (NEVER Do These)

- Generic font stacks (Inter, Roboto, Arial, system-ui)
- Purple gradients on white backgrounds
- Predictable layouts with no visual interest
- Cookie-cutter component patterns with default styles
- Bare, unstyled HTML elements
- Empty pages with just text "No items found"
- Forms with no visual grouping or hierarchy
- Tables with no hover states or alignment
- Buttons with no feedback on interaction
- Dialogs with no backdrop or transitions

## Practical Application for Admin/Dashboard UIs

Admin interfaces need to be **functional AND beautiful**. This means:

1. **Clean but not bland** — Use subtle visual interest: card shadows, section dividers, icon accents
2. **Data-dense but readable** — Use typography hierarchy, proper spacing, zebra striping
3. **Efficient but not ugly** — Forms should be organized with sections, not a wall of inputs
4. **Professional but not generic** — Choose a color palette, font pairing, and spacing system that has character

Remember: Claude is capable of extraordinary creative work. Don't hold back — show what can truly be created when committing fully to a distinctive vision, even for "boring" admin UIs.
