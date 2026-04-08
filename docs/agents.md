[Back to README](../README.md)

# Agents

Think of an agent like a colleague with a specific expertise. A senior engineer reviews code differently than a QA tester, and a technical writer reads differently than both. Agents give Claude a focused role with a defined set of tools and a maximum turn budget, so each review stays on-task.

> **Prerequisites**
> - claude-forge installed (see [Getting Started](getting-started.md))
> - Agents directory registered in your Claude Code plugin settings

---

## How to Invoke an Agent

Agents are invoked through the Agent tool inside a Claude Code session. Ask Claude to use a specific agent by name:

```
Use the senior-engineer-code-reviewer agent to review the last change.
Use the qa-tester agent to validate the new feature end-to-end.
Use the tech-lead-architect agent to evaluate the state management approach.
```

Claude Code loads the agent's system prompt, restricts its available tools to the declared set, and caps its response depth at `maxTurns`.

---

## Agent Reference

| Agent | Role | Tools | Max Turns |
|---|---|---|---|
| `senior-engineer-code-reviewer` | Reviews code for correctness, naming, DRY violations, architecture alignment, and test coverage | Read, Glob, Grep, Bash | 10 |
| `tech-lead-architect` | Evaluates architectural decisions, type system design, state management, and scalability | Read, Glob, Grep | 8 |
| `qa-tester` | Validates test coverage, runs test suites, and verifies correctness of core features and UI | Bash, Read, Glob, Grep | 10 |
| `ui-ux-designer` | Reviews UI components for visual consistency, responsiveness, accessibility, and design system adherence | Read, Glob, Grep | 6 |
| `technical-writer` | Reviews documentation for clarity, ELI5 accessibility, structured formatting, and contributor onboarding | Read, Glob, Grep | 6 |
| `product-strategist` | Evaluates features for user engagement and documentation value using Hook Model and AIDA frameworks | Read, Glob, Grep | 6 |
| `silent-failure-hunter` | Finds silent failures in architecture patterns, edge cases, static imports, and type safety boundaries | Read, Glob, Grep | 8 |
| `code-simplifier` | Simplifies code while preserving core abstractions, architectural contracts, and intentional verbosity | Read, Glob, Grep | 6 |
| `code-explorer` | Traces data flow, module loading, dependency graphs, and rendering pipelines | Read, Glob, Grep | 8 |
| `claude-system-architect` | Manages `.claude/` configuration: skills, agents, memory, CLAUDE.md, rules, hooks, and settings | Read, Glob, Grep | 8 |

---

## The 7-Step Workflow

The `feature-dev` skill orchestrates agents in a defined sequence. Each step maps to a specific agent or set of agents:

| Step | Role | Agent |
|---|---|---|
| 1. Product evaluation | Is this feature worth building? Does it serve users? | `product-strategist` |
| 2. UI/UX review | How should it look and behave? | `ui-ux-designer` |
| 3. Architecture | What is the right structure and pattern? | `tech-lead-architect` |
| 4. Implementation | Write the code with tests | (Claude Code directly, with skills) |
| 5. Code review | Is the implementation correct and clean? | `senior-engineer-code-reviewer` |
| 6. QA validation | Does it actually work end-to-end? | `qa-tester` |
| 7. Documentation | Is it documented clearly for contributors? | `technical-writer` |

You can invoke any agent individually at the appropriate step, or use `/feature-dev` to run through all steps in sequence.

---

## Agent vs Skill Decision Table

| Situation | Use |
|---|---|
| You need Claude to follow a multi-step checklist | Skill |
| You need a focused second opinion on code quality | Agent (`senior-engineer-code-reviewer`) |
| You need to diagnose a bug systematically | Skill (`/debugging`) |
| You need an architectural recommendation | Agent (`tech-lead-architect`) |
| You need to verify work is complete before merging | Skill (`/verification`) |
| You need a docs readability review | Agent (`technical-writer`) or Skill (`/documentation-review`) |
| You need to find silent failures or edge cases | Agent (`silent-failure-hunter`) |
| You need a full feature from planning to merge | Skill (`/feature-dev`, which orchestrates agents internally) |

---

## See Also

- [Skills reference](skills.md)
- [Hooks reference](hooks.md)
- [Getting Started](getting-started.md)
