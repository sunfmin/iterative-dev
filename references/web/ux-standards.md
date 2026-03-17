# UX Standards for Production-Quality Apps

Every feature implemented by a subagent must meet these standards. A feature that works but looks like a prototype is NOT complete.

## Non-Negotiable Standards (every page must have these)

### Loading States
- Use skeleton screens for initial page load (preferred over spinners)
- Show inline spinner for actions (save, delete, bulk operations)
- Button text changes during action: "Save" → "Saving..." with disabled state
- Never show a blank page while data loads

### Empty States
- Icon + heading + description + CTA button
- Example: `[inbox icon] "No products yet" / "Create your first product to get started" / [Add Product button]`
- Empty search results: "No results for 'X'" with a "Clear filters" link
- Never show just an empty table or blank area

### Error States
- Inline errors below form fields (red text + red border on field)
- Toast notifications for action errors (red/destructive variant)
- Full-page error boundary for crashes with retry option
- Never show raw error messages or stack traces to users

### Responsive Design
- **375px (Mobile)**: Single column, hamburger nav, stacked cards, horizontal scroll for tables
- **768px (Tablet)**: 2 columns, condensed sidebar or top nav
- **1280px (Desktop)**: Full layout with permanent sidebar
- Tables must either scroll horizontally on mobile OR collapse to card layout
- Touch targets minimum 44px on mobile
- Test at all three breakpoints

### Accessibility
- All interactive elements: aria-label or associated visible label
- Focus ring visible on keyboard navigation (focus-visible)
- Color is never the only indicator (always add text or icon)
- Minimum contrast ratio: 4.5:1 for text
- Modals must trap focus and close on Escape
- Form inputs must have associated labels

## Visual Design Standards

### Typography Hierarchy
- Page title: `text-2xl font-bold` or larger
- Section title: `text-lg font-semibold`
- Body text: `text-sm` or `text-base`
- Caption/label: `text-xs text-muted-foreground`
- Choose distinctive fonts — avoid generic defaults like Inter, Arial, system-ui
- Pair a display font with a complementary body font

### Color & Theme
- Commit to a cohesive palette — don't use random colors
- Define CSS variables for consistency
- Dominant color with sharp accent outperforms evenly-distributed palettes
- Status colors: green=success/active, yellow/amber=warning/draft, red=error/destructive, gray=neutral/archived
- Status badges must have both colored background AND text (not color alone)

### Spacing Scale
Use a consistent scale throughout the app:
- `4px` (p-1) — tight inline spacing
- `8px` (p-2) — compact elements
- `12px` (p-3) — standard inline padding
- `16px` (p-4) — standard section padding
- `24px` (p-6) — generous section spacing
- `32px` (p-8) — major section breaks
- `48px` (p-12) — page-level spacing

### Shadows & Depth
- Cards: `shadow-sm` at rest, `shadow-md` on hover
- Modals/dialogs: `shadow-lg`
- Dropdowns: `shadow-md`
- Always add transition: `transition-shadow duration-200`

### Transitions & Micro-interactions
- Hover effects: `transition-colors duration-150` or `transition-all duration-200`
- Button press feedback: slight scale or color change
- Page elements: subtle fade-in on mount
- Sidebar/menu open: slide transition with backdrop
- Toast notifications: slide-in from edge
- Never change state abruptly — always transition

## Feature-Specific Standards

### Forms
- Group related fields with section headers and visual dividers
- Required fields marked with asterisk (*)
- Help text below non-obvious fields (smaller, muted color)
- Auto-generation feedback (e.g., slug auto-generates as user types name)
- Submit button shows loading state, disables during submit
- Cancel navigates back without side effects
- Unsaved changes: consider confirm-before-leave

### Tables
- Column headers: bold, uppercase or semi-bold, with sort indicators
- Zebra striping: alternating row backgrounds (subtle, `even:bg-muted/50`)
- Hover highlighting: `hover:bg-muted transition-colors`
- Text alignment: text left, numbers right, status centered
- Actions column: icon buttons with tooltips
- Pagination: show current page, total pages, and per-page count

### Cards / Grid Views
- Consistent card sizing within a grid
- Rounded corners (`rounded-lg`)
- Border or shadow for visual separation
- Hover effect for clickable cards
- Image aspect ratio maintained

### Navigation
- Active link clearly distinguished (background color, font weight, or indicator)
- Breadcrumbs on nested pages (e.g., Products > Edit MacBook Pro)
- Mobile: hamburger menu with slide-in overlay + backdrop
- Keyboard accessible: Tab through links, Enter to activate

### Dialogs / Modals
- Backdrop overlay (semi-transparent black)
- Centered with max-width appropriate to content
- Close button (X) in top-right corner
- Close on Escape key and backdrop click
- Focus trapped inside dialog
- Destructive actions: red/destructive button variant

### Toast Notifications
- Success: green variant, auto-dismiss after 4s
- Error: red/destructive variant, longer display or manual dismiss
- Position: bottom-right or top-right, consistent throughout app
- Include relevant context (e.g., "Product 'MacBook Pro' deleted")
