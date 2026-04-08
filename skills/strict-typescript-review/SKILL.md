---
name: strict-typescript-review
description: Review code for strict TypeScript compliance including noUncheckedIndexedAccess, discriminated unions, tuple types, and runtime validation
user-invocable: true
---

# Strict TypeScript Review

## Task

Review code changes for strict TypeScript compliance, proper type patterns, and runtime validation at system boundaries.

## Instructions

1. Identify changed or new TypeScript files
2. Check each file against the checklist below
3. Flag violations with specific fix suggestions

## Checklist

### No `any` Types

- Zero `any` usage — use `unknown` with explicit type narrowing
- No `@ts-ignore` or `@ts-expect-error` without a comment explaining why
- Generic type parameters have constraints where possible

### Strict Index Access

- `noUncheckedIndexedAccess` compliance: array indexing returns `T | undefined`
- Coordinate/pair arrays use explicit tuple types: `[number, number][]` not `number[][]`
- Map/Record lookups handle the `undefined` case
- Destructuring from indexed access includes undefined checks

### Discriminated Unions

- Discriminated union switches are exhaustive (use `never` in the default case)
- All union variants handled in every switch/if chain
- No type assertions (`as Type`) to bypass union narrowing — use type guards instead
- New union members added to all existing switch/if chains

### Framework-Specific Patterns

- Module imports use statically analyzable paths (no dynamic string interpolation in import paths)
- Hook dependency arrays are complete — no missing deps
- `satisfies` operator used for type-safe constant definitions
- Lazy-loaded components have proper `Suspense` boundaries

### Runtime Validation

- User input validated before passing to any execution or processing function
- Dynamically loaded content validated after import (file might not exist)
- Type guards at system boundaries: external data → validated internal types
- No trusting `JSON.parse()` output without validation

### Type Design Quality

- **Encapsulation**: Types expose only what consumers need — internal state is private
- **Invariant expression**: Types enforce constraints at compile time, using discriminants to prevent invalid state combinations
- **Usefulness**: Each type serves a clear purpose — no redundant or unused type definitions
- **Enforcement**: Type constraints are enforced by the compiler, not by runtime checks or conventions

## Output Format

- PASS: [file:line] - correct usage
- WARN: [file:line] - suboptimal pattern, not a bug
- FAIL: [file:line] - violation + suggested fix
