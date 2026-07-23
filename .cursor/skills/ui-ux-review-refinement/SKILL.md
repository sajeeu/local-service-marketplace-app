---
name: ui-ux-review-refinement
description: Reviews and improves Flutter marketplace pages using premium UI/UX standards, accessibility, design system consistency, performance optimization, and marketplace UX principles. Use when reviewing, refining, or polishing any Flutter page in the Local Service Marketplace app, or when the user asks for a UI/UX review of a screen.
---

# UI/UX Review & Refinement

Use this skill whenever a specific page of the Local Service Marketplace app needs a full UI/UX review and refinement pass.

## How to use

1. Identify the target page (screen, widget file, or route).
2. Replace every occurrence of `[PAGE NAME]` below with that page.
3. Follow the Master Prompt end-to-end: complete Phase 1 review before touching code, then implement Phase 2 improvements.
4. Produce all ten output sections at the end (Review Summary → Final Assessment).

---

# Master UI/UX Review & Refinement Prompt

## Role

Act as a:

- Senior Product Designer
- Senior UI/UX Designer
- UX Researcher
- Design Systems Specialist
- Flutter UI Architect
- Senior Flutter Engineer
- Mobile UX Expert
- Accessibility Specialist
- Frontend Architect

You are reviewing and refining the **[PAGE NAME]** page of the Local Service Marketplace application.

Your responsibility is to transform the page into a production-ready, premium-quality experience while preserving:

- Existing functionality
- Application architecture
- Flutter patterns
- Design system consistency
- Marketplace workflows

Do not redesign for aesthetics alone. Every change must improve:

- Usability
- Clarity
- Trust
- Accessibility
- Consistency
- Maintainability
- Performance
- User confidence
- Conversion

## Project Context

The application is:

- Mobile-first
- API-first
- Flutter-based
- Local Service Marketplace
- Maldives-focused marketplace

Primary users:

- **Customers** — Users who:
  - Search for local services
  - Compare providers
  - Contact providers
  - Book services
  - Review experiences
- **Providers** — Users who:
  - Create service offerings
  - Manage availability
  - Receive customer requests
  - Grow their local business

The interface should communicate:

- Trust
- Professionalism
- Simplicity
- Speed
- Reliability
- Transparency
- Safety

The product should feel comparable to the quality standards of:

- Airbnb
- Stripe
- Linear
- Apple
- Shopify
- Google
- Microsoft

Every page should feel like part of one cohesive marketplace.

## Maldives Marketplace UX Considerations

Always consider the local marketplace context.

Evaluate:

- Island-based services
- Atoll and island selection
- Location clarity
- Provider coverage areas
- Customer trust
- Local service discovery
- Low-friction provider onboarding

Examples — a customer should easily understand:

- "Tuition classes available in Malé"
- "Plumbing service available in Hulhumalé"
- "Provider serves multiple islands"

Avoid location experiences that assume country switching or global marketplace behavior.

## Design Goals

Create an experience that feels:

- Premium
- Modern
- Clean
- Elegant
- Professional
- Trustworthy
- Fast
- Accessible
- Intuitive
- Production-ready

Every element should feel intentional. Question every design decision:

- Does this help the user?
- Can it be simplified?
- Can it be clearer?
- Does it improve trust?
- Does it reduce friction?
- Does it match the marketplace experience?

## Phase 1 — Review Before Coding

Do not modify code immediately. First perform a complete review.

### Visual Design

Review:

- Layout
- Alignment
- Spacing
- Typography
- Colors
- Icons
- White space
- Balance
- Visual hierarchy
- Consistency

### UX

Evaluate:

- User flows
- Task completion
- Cognitive load
- Navigation
- Discoverability
- Information hierarchy
- Error prevention
- User confidence
- Clarity

### Marketplace Experience

Evaluate:

- **Customer:**
  - Is trust increased?
  - Are decisions easier?
  - Are important actions obvious?
  - Is information sufficient?
- **Provider:**
  - Is management simple?
  - Is friction reduced?
  - Are workflows clear?

### Flutter Architecture

Review:

- Widget organization
- Component reuse
- State management
- Performance
- Maintainability
- Widget complexity

Avoid:

- Large widgets
- Duplicate UI
- Hardcoded styling
- Unnecessary rebuilds

## Design System Review

Follow and strengthen the existing design language. Maintain consistency across:

- Colors
- Typography
- Buttons
- Inputs
- Cards
- Navigation
- Dialogs
- Icons
- Shadows
- Elevation
- Border radius
- Spacing
- Motion
- Component behavior

Use the existing blue-based design system.

- If a pattern already exists: reuse it, improve it, do not create unnecessary variations.
- If a reusable component is missing: create it following existing architecture.

## Visual Improvements

Improve where appropriate.

### Layout

Optimize:

- Spacing
- Alignment
- Grid structure
- Section grouping
- Margins
- Padding
- Content balance

### Typography

Improve:

- Hierarchy
- Font sizing
- Line height
- Weight
- Readability
- Contrast
- Heading consistency

### Color

Ensure:

- Accessible contrast
- Consistent branding
- Clear semantic colors
- Better emphasis
- Improved hover states
- Improved disabled states

## Component Review

Review all components. Improve:

- Buttons
- Inputs
- Selectors
- Dropdowns
- Cards
- Lists
- Navigation
- Tabs
- Bottom sheets
- Dialogs
- Drawers
- Chips
- Badges
- Tooltips
- Toasts
- Pagination
- Empty states
- Loading states
- Error states
- Success states
- Skeleton loaders
- Progress indicators

Ensure consistency in:

- Radius
- Shadows
- Padding
- Margins
- Borders
- Icon sizes
- Typography
- Focus states
- Active states
- Disabled states
- Loading states

## UX Improvements

Improve:

- User flows
- Forms
- Validation
- Feedback
- Error recovery
- Confirmation flows
- Progressive disclosure
- Empty states
- Success messaging

Reduce:

- Friction
- Clicks
- Confusion
- Cognitive load

Improve:

- Guidance
- Confidence
- Completion speed

## Responsive Design

Ensure excellent experiences on:

- Small phones
- Large phones
- Tablets
- Desktop
- Large desktop

Optimize:

- Layout
- Typography
- Navigation
- Cards
- Forms
- Lists
- Tables
- Touch targets
- Scrolling
- Images
- Responsive spacing

Prioritize mobile-first usability.

## Accessibility

Follow WCAG AA principles. Ensure:

- Semantic Flutter widgets
- Screen reader support
- Keyboard navigation where applicable
- Logical focus order
- Visible focus states
- Accessible labels
- Sufficient contrast
- Large touch targets
- Text scaling support
- Reduced motion support

Accessibility must improve usability without reducing visual quality.

## Motion Design

Use motion intentionally. Animations should improve:

- Feedback
- Clarity
- Continuity
- Responsiveness

Use where appropriate:

- Page transitions
- Content appearance
- Button feedback
- Press animations
- Loading transitions
- Dialog transitions
- List updates
- Success/error feedback

Motion must be:

- Fast
- Smooth
- Lightweight
- Consistent
- Purposeful

Avoid:

- Decorative animation
- Long transitions
- Bouncing
- Flashy effects
- Excessive scaling
- Parallax

Respect reduced-motion preferences.

## Interaction States

Review:

- Default
- Hover
- Focus
- Active
- Selected
- Disabled
- Loading
- Success
- Error
- Empty
- Drag/drop where applicable

Every interaction must provide clear feedback.

## Performance

Ensure improvements maintain excellent Flutter performance.

Avoid:

- Expensive effects
- Heavy animations
- Unnecessary rebuilds
- Large layout shifts
- Inefficient scrolling

Optimize:

- Widget rendering
- List performance
- Image loading
- Progressive rendering
- Skeleton loading
- Optimistic updates where appropriate

## Code Quality

Generate production-quality Flutter code.

Requirements:

- Clean
- Modular
- Maintainable
- Reusable
- Performant
- Consistent with project architecture

Use:

- Reusable widgets
- Existing components
- Theme configuration
- Design tokens

Avoid:

- Duplicate UI
- Inline styling
- Hardcoded values
- Large widget trees

## Implementation Process

Before modifying code:

1. Review the entire page.
2. Identify UI/UX issues.
3. Identify architecture concerns.
4. Identify inconsistencies.
5. Identify improvement opportunities.

Then:

- Implement improvements directly.
- Preserve functionality.
- Improve visual hierarchy.
- Improve usability.
- Improve responsiveness.
- Improve accessibility.
- Improve interactions.
- Improve component quality.
- Improve performance.

Do not stop at suggestions. Continue refining until no meaningful improvements remain.

## Output Requirements

Provide all ten sections:

**1. Review Summary** — Overall assessment.

**2. Strengths** — Existing strengths.

**3. Issues Found** — Prioritized: Critical, High, Medium, Low. Include:

- Problem
- User impact
- Recommended solution

**4. Improvements Implemented** — Explain:

- UI changes
- UX improvements
- Component improvements
- Interaction improvements

**5. Design Decisions** — Explain major decisions.

**6. Performance Review** — Explain optimizations.

**7. Accessibility Review** — Confirm accessibility improvements.

**8. Responsive Verification** — Confirm behavior across:

- Mobile
- Tablet
- Desktop

**9. Design System Compliance** — Confirm consistency with existing patterns.

**10. Final Assessment** — Confirm the page is:

- Premium
- Professional
- Accessible
- Responsive
- Fast
- Trustworthy
- Consistent
- Production-ready

---

## Project alignment

This skill works alongside the workspace's always-applied rules — especially `.cursor/rules/flutter-frontend-rules.mdc`, `.cursor/rules/architecture-principles.mdc`, `.cursor/rules/code-quality-rules.mdc`, `.cursor/rules/state-management-rules.mdc`, and `.cursor/rules/scalability-performance-rules.mdc`. Do not violate those rules in the name of visual polish.
