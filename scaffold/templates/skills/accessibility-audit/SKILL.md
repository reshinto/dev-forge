---
name: accessibility-audit
description: Audit UI components for WCAG 2.1 AA compliance, animation accessibility, and design token consistency
user-invocable: true
---

# Accessibility Audit

## Task

Audit the specified component(s) or the entire UI for WCAG 2.1 AA compliance, animation accessibility, and design system consistency.

## Instructions

1. Identify the target: specific component path or full component directory scan
2. Run through each checklist area below
3. Report findings using the output format

## Checklist

### Color Contrast

- Text on backgrounds meets 4.5:1 ratio (normal text) or 3:1 (large text)
- UI components (buttons, inputs, focus rings) meet 3:1 contrast ratio
- Interactive states are distinguishable without relying solely on color
- Colors reference the project's design system tokens — no raw hardcoded hex values in component files

### Keyboard Navigation

- All interactive elements reachable via Tab key
- Focus order follows visual layout
- Focus indicators are visible (not `outline: none` without replacement)
- Keyboard shortcuts documented in ARIA labels or tooltips
- Escape key closes drawers and modals

### Screen Reader Support

- ARIA labels on all interactive elements (buttons, controls, tabs)
- `aria-live` regions for dynamic content updates
- Semantic HTML landmarks (`main`, `nav`, `aside`, `section`)
- Dynamic state changes announced to assistive technology

### Animation Accessibility

- All animations wrapped with `reduced-motion` media query check
- Exit transitions don't trap focus
- Layout animations don't cause content reflow that loses keyboard focus
- Stagger animations respect `prefers-reduced-motion: reduce`

### Design Token Consistency (if project uses a design system)

- Colors use design tokens or CSS custom properties (e.g., `var(--color-primary)`), not hardcoded values
- Spacing follows the project's spacing scale consistently
- Responsive breakpoints use project-standard values per `.claude/rules/ui-ux.md`
- Typography uses design token font families

## Output Format

- PASS: [area] - meets WCAG 2.1 AA standard
- WARN: [area] - minor concern, not a blocker
- FAIL: [area] - violation + specific fix required
