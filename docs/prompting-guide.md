[Back to README](../README.md)

# Prompting Guide

How to write effective prompts and trigger the full range of capabilities in dev-forge and companion plugins.

## Prerequisites

- dev-forge installed ([getting started](getting-started.md))
- Familiarity with [skills](skills.md) and [agents](agents.md)

---

## Writing Effective Prompts

### Be Specific About What You Want

| Instead of... | Try... |
|---------------|--------|
| "Fix this" | "Fix the null pointer in `processOrder()` at line 42 — it crashes when `items` is empty" |
| "Add tests" | "Add unit tests for the `calculateDiscount` function covering empty cart, single item, and bulk discount cases" |
| "Review this" | "Review the authentication changes in `src/auth/` for security issues and naming conventions" |
| "Make it better" | "Refactor `UserService.ts` to extract the validation logic into a separate function" |

### Structure Complex Requests

For multi-step tasks, break them down:

```
I need to add a new API endpoint for user preferences:
1. Create the route handler in src/api/preferences.ts
2. Add validation for the request body
3. Write tests for success and error cases
4. Update the API docs
```

### Provide Context

When the task depends on project knowledge:

```
The auth middleware at src/middleware/auth.ts uses JWT tokens stored
in httpOnly cookies. I need to add a refresh token rotation mechanism
that invalidates the old token when a new one is issued.
```

### Specify Constraints

When you have requirements:

```
Add pagination to the /api/users endpoint.
Constraints:
- Use cursor-based pagination, not offset
- Default page size: 20, max: 100
- Return total count in response headers
```

---

## Triggering dev-forge Skills

Invoke any skill by typing its name as a slash command:

| Command | When to Use |
|---------|-------------|
| `/tdd` | Before implementing a feature — writes tests first, then implementation |
| `/debugging` | When you hit a bug — follows structured diagnostic paths |
| `/feature-dev` | Starting a new feature — guided 7-step workflow with agent reviews |
| `/implementation-planning` | Before a complex change — creates structured file-by-file plan |
| `/verification` | Before claiming work is done — runs completeness checklist |
| `/accessibility-audit` | After UI changes — checks WCAG 2.1 AA compliance |
| `/architecture-review` | For structural changes — evaluates state management, build, security |
| `/documentation-review` | Before merging — checks docs for clarity and accuracy |
| `/security-coverage-audit` | Before release — combined security + coverage check |
| `/strict-type-review` | After writing typed code — checks exhaustiveness, unsafe escapes |
| `/readme-optimization` | When updating README — AIDA flow, GitHub SEO |
| `/branch-safety-check` | Anytime — verifies you're on a proper feature branch |
| `/claude-system-management` | When editing .claude/ — audits system config consistency |

---

## Triggering dev-forge Agents

Use agents when you need a specific reviewer's perspective:

```
Use the senior-engineer-code-reviewer agent to review my recent changes.
```

```
Ask the tech-lead-architect agent to evaluate this architectural decision.
```

```
Run the qa-tester agent to validate test coverage.
```

| Agent | Best Prompt |
|-------|-------------|
| senior-engineer-code-reviewer | "Review [files/changes] for code quality, naming, and architecture" |
| tech-lead-architect | "Evaluate [decision/design] for maintainability and scalability" |
| qa-tester | "Validate test coverage and run quality checks on [feature]" |
| ui-ux-designer | "Review [component] for design consistency and accessibility" |
| technical-writer | "Review [docs] for clarity and contributor onboarding quality" |
| silent-failure-hunter | "Hunt for silent failures in [files/module]" |
| code-simplifier | "Simplify [files] while preserving architectural contracts" |
| code-explorer | "Trace the data flow from [entry point] to [output]" |
| claude-system-architect | "Audit the .claude/ configuration for consistency" |
| product-strategist | "Evaluate [feature] for user engagement and value" |

---

## Triggering Companion Plugin Skills

If you have companion plugins installed alongside dev-forge, here's how to trigger their key capabilities:

### superpowers (if installed)

| Command | What it Does |
|---------|-------------|
| `/superpowers:brainstorming` | Explore requirements, constraints, and design options before building. Use before any creative work — features, components, modifications. |
| `/superpowers:test-driven-development` | Full TDD workflow with red-green-refactor cycle. Use when implementing any feature or bugfix. |
| `/superpowers:systematic-debugging` | Structured debugging with hypothesis formation and evidence gathering. Use when encountering any unexpected behavior. |
| `/superpowers:writing-plans` | Create detailed implementation plans from specs. Use before touching code on multi-step tasks. |
| `/superpowers:executing-plans` | Execute plans with review checkpoints. Use after writing a plan. |
| `/superpowers:verification-before-completion` | Verify work is actually done before claiming it. Use before committing or creating PRs. |
| `/superpowers:requesting-code-review` | Request structured code review. Use after completing a feature. |
| `/superpowers:receiving-code-review` | Handle review feedback with technical rigor. Use when receiving PR comments. |
| `/superpowers:finishing-a-development-branch` | Decide how to integrate work (merge, PR, cleanup). Use when implementation is complete. |
| `/superpowers:using-git-worktrees` | Create isolated git worktrees for parallel work. Use when starting feature work that needs isolation. |
| `/superpowers:dispatching-parallel-agents` | Run independent tasks in parallel. Use when facing 2+ independent tasks. |

### commit-commands (if installed)

| Command | What it Does |
|---------|-------------|
| `/commit` | Create a well-formatted git commit |
| `/commit-push-pr` | Commit, push, and open a PR in one step |

### code-review (if installed)

| Command | What it Does |
|---------|-------------|
| `/code-review:code-review` | Full code review of a pull request |

### pr-review-toolkit (if installed)

| Command | What it Does |
|---------|-------------|
| `/pr-review-toolkit:review-pr` | Comprehensive PR review using specialized agents |

---

## Workflow Recipes

### Starting a New Feature

```
1. /superpowers:brainstorming     — explore design options
2. /superpowers:writing-plans     — create implementation plan
3. /tdd                           — write tests first
4. /feature-dev                   — guided implementation with reviews
5. /verification                  — confirm completeness
6. /commit-push-pr                — ship it
```

### Fixing a Bug

```
1. /superpowers:systematic-debugging  — diagnose root cause
2. /debugging                         — follow diagnostic path
3. /tdd                               — write failing test for the bug
4. (implement the fix)
5. /verification                      — confirm fix + no regressions
6. /commit                            — commit the fix
```

### Preparing a PR

```
1. /verification                      — completeness check
2. /security-coverage-audit           — security + coverage
3. /documentation-review              — docs accuracy
4. /superpowers:verification-before-completion  — final verification
5. /commit-push-pr                    — ship it
```

---

## Tips

- **Chain skills**: Use multiple skills in sequence for complex workflows (see recipes above)
- **Be explicit about scope**: "Review src/auth/" is better than "review the code"
- **Reference rules**: "Following rules/architecture.md, add a new module for..." gives the agent context
- **Use agents for opinions**: Agents give opinionated feedback from a specific role's perspective
- **Use skills for process**: Skills enforce a specific workflow with checklists

---

## See Also

- [Skills reference](skills.md) — full details on each skill
- [Agents reference](agents.md) — full details on each agent
- [Customization](customization.md) — adapting to your project
