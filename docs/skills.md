[Back to README](../README.md)

# Skills

Think of a skill like a saved playbook or checklist. Instead of typing out a long set of instructions every time you want to run a code review or set up a TDD cycle, you invoke the skill by name and Claude follows the predefined steps automatically.

> **Prerequisites**
> - dev-forge installed and skills registered (see [Getting Started](getting-started.md))
> - A Claude Code session open in your project

---

## How to Invoke a Skill

Type the skill name prefixed with a `/` in any Claude Code session:

```
/tdd
/verification
/debugging
```

Claude Code matches the name to the installed skill file and loads its instructions. Skills are loaded at invocation time — no setup needed per session.

---

## Skill Reference

| Skill | Purpose | When to Use |
|---|---|---|
| `tdd` | TDD workflow using a 4-part test matrix (unit, integration, component/story, E2E) | Before writing any implementation code |
| `implementation-planning` | Break a feature into phased milestones with file, test, and dependency mapping | After requirements are clear, before opening an editor |
| `feature-dev` | Guided 7-step workflow: product eval, design, architecture, implement, review, QA, docs | For any non-trivial feature from idea to merge |
| `debugging` | Systematic diagnosis across data processing, rendering, state, asset loading, and build layers | When a bug's root cause is unclear |
| `verification` | Pre-completion checklist: coverage, branch safety, completeness, state management | Before claiming work is done or creating a PR |
| `architecture-review` | Evaluate state management design, build optimization, and security-by-design patterns | When making structural or cross-cutting changes |
| `strict-type-review` | Audit for strict type safety: checked indexed access, discriminated unions, tuple types | Before merging TypeScript changes |
| `accessibility-audit` | WCAG 2.1 AA compliance, animation accessibility, design token consistency | After any UI component change |
| `security-coverage-audit` | OWASP client-side checks and test coverage threshold validation with E2E | Before release or on a security-sensitive PR |
| `documentation-review` | Review docs for clarity, ELI5 accessibility, structure, and onboarding quality | At PR time when docs changed |
| `readme-optimization` | Optimize README for GitHub discoverability and accurate feature positioning | Before a public release or repo restructure |
| `branch-safety-check` | Confirm the current branch is a unique task branch; create one if needed | At the start of any new task |
| `claude-system-management` | Create, update, and audit `.claude/` config: agents, skills, memory, rules, hooks | When maintaining or extending the dev-forge setup itself |

---

## Recommended Skill Pairings

Skills are designed to chain together. These sequences cover the most common workflows:

**Feature development (full cycle):**

```
/branch-safety-check  →  /implementation-planning  →  /tdd  →  /verification  →  /documentation-review
```

**Bug fix:**

```
/branch-safety-check  →  /debugging  →  /tdd  →  /verification
```

**Structural change:**

```
/branch-safety-check  →  /architecture-review  →  /strict-type-review  →  /verification
```

**PR review preparation:**

```
/verification  →  /documentation-review  →  /security-coverage-audit
```

**UI component work:**

```
/tdd  →  /accessibility-audit  →  /verification
```

---

## See Also

- [Agents reference](agents.md)
- [Hooks reference](hooks.md)
- [Getting Started](getting-started.md)
