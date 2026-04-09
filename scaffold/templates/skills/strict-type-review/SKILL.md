---
name: strict-type-review
description: Review code for strict type safety compliance including checked indexed access, discriminated unions, tuple types, and runtime validation
user-invocable: true
---

# Strict Type Review

## Task

Review code changes for strict type safety compliance, proper type patterns, and runtime validation at system boundaries. Applicable to any statically typed language (TypeScript, Rust, Go, Kotlin, etc.).

## Instructions

1. Identify changed or new source files in the project's primary language
2. Check each file against the checklist below
3. Flag violations with specific fix suggestions

## Checklist

### No Unsafe Type Escape Hatches

- No untyped escape hatches (`any` in TS, `interface{}` in Go, `Any` in Python, `unsafe` without justification in Rust)
- No compiler directive suppressions (e.g., `@ts-ignore`, `# type: ignore`, `//nolint`) without a comment explaining why
- Generic type parameters have constraints where possible

### Strict Collection Access

- Collection indexing handles the case where the element may not exist (null/undefined/Option/Result)
- Coordinate/pair collections use explicit tuple or fixed-size types, not nested arrays
- Map/dictionary lookups handle the missing-key case
- Destructuring from indexed access includes existence checks

### Exhaustive Variant Handling

- Switch/match statements on union/enum/variant types are exhaustive
- All variants handled in every branching construct
- No unsafe type casts to bypass type narrowing — use type guards or pattern matching instead
- New variants added to all existing branching constructs

### Framework-Specific Patterns

- Module imports use statically analyzable paths (no dynamic string interpolation in import paths)
- Framework-specific dependency tracking is complete (e.g., hook deps, reactive subscriptions)
- Type-safe constant definitions used where the language supports them
- Lazy-loaded modules have proper error boundaries or fallbacks

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
