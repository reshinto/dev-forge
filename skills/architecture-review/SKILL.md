---
name: architecture-review
description: Evaluate architectural decisions for state management design, build optimization, and security-by-design patterns
user-invocable: true
---

# Architecture Review

## Task

Evaluate a proposed or existing architectural change for state management correctness, build performance, and security compliance. See `.claude/rules/architecture.md` for project-specific patterns.

## Instructions

1. Identify the change scope: state slice, component tree, build config, or cross-cutting
2. Review against each area below
3. Provide actionable recommendations

## Review Areas

### State Management Architecture

- Each slice has a single responsibility — no cross-slice state mutations
- Immutable update patterns used consistently (no accidental direct mutations)
- Selectors are memoized to prevent unnecessary re-renders
- Cross-slice coordination uses root store composition, not direct slice imports
- New actions are scoped to a single slice
- State shape is flat where possible — avoid deep nesting

### Build Optimization

- Code splitting uses lazy loading + Suspense boundaries for route-level or heavy components
- No dynamic imports with string interpolation — static analysis requires statically resolvable paths
- Tree-shaking verified: unused exports don't inflate bundle
- Large dependencies evaluated for lazy loading or lighter alternatives
- Bundle analysis performed when adding new dependencies

### Security-by-Design

- No `eval()`, `Function()`, or `innerHTML` in any component
- User-controlled content treated as untrusted — no execution of user input
- User-provided inputs validated before passing to any execution or processing function
- CSP-compliant patterns: no inline scripts, no `unsafe-eval`
- Dynamic content rendered safely — no `dangerouslySetInnerHTML`
- Dependencies audited: `npm audit` clean or vulnerabilities documented

## Output Format

- APPROVED: [decision] - rationale for why it's sound
- CONCERN: [area] - risk description + specific mitigation
- BLOCKED: [issue] - must resolve before proceeding
