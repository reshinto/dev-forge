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

Invoke any skill by typing its name as a slash command.

### `/tdd` — Test-Driven Development

Write tests first, then implement to make them pass.

```
/tdd
I need to add a calculateShipping function that returns free shipping
for orders over $50 and flat $5.99 otherwise.
```

### `/debugging` — Systematic Debugging

Follow structured diagnostic paths to isolate a bug.

```
/debugging
The checkout page shows a blank total when the cart has more than
10 items. It works fine with fewer items.
```

### `/feature-dev` — Guided Feature Development

7-step workflow: product eval → design → architecture → implement → review → QA → docs.

```
/feature-dev
Add a dark mode toggle to the settings page that persists the
user's preference across sessions.
```

### `/implementation-planning` — Create Implementation Plan

Plan file changes, dependencies, and test strategy before coding.

```
/implementation-planning
I need to add role-based access control. Admins can manage users,
editors can publish content, viewers can only read.
```

### `/verification` — Pre-Completion Checklist

Verify work is complete before committing or creating a PR.

```
/verification
I just finished the user preferences API. Check that everything
is wired up, tested, and ready to ship.
```

### `/accessibility-audit` — WCAG 2.1 AA Audit

Audit UI components for accessibility compliance.

```
/accessibility-audit
Check the new modal dialog component in src/components/Modal.tsx
for keyboard navigation, screen reader support, and color contrast.
```

### `/architecture-review` — Architecture Review

Evaluate structural decisions for state management, build optimization, and security.

```
/architecture-review
I'm adding a WebSocket layer for real-time notifications. Review
the proposed architecture in src/services/ws/ for scalability.
```

### `/documentation-review` — Documentation Review

Check docs for clarity, accuracy, and contributor onboarding quality.

```
/documentation-review
Review the README and docs/api.md — I rewrote the getting started
section and added new API endpoint docs.
```

### `/security-coverage-audit` — Security & Coverage Audit

Combined security checks and test coverage verification.

```
/security-coverage-audit
Run a full security and coverage audit before we cut the v2.0 release.
```

### `/strict-type-review` — Strict Type Safety Review

Check for unsafe type escape hatches, unchecked collection access, and exhaustiveness gaps.

```
/strict-type-review
Review the new types in src/types/order.ts and their usage across
the order processing module.
```

### `/readme-optimization` — README Optimization

Optimize README for GitHub discoverability and clear presentation.

```
/readme-optimization
Our README hasn't been updated since launch. Optimize it for
discoverability and make the value proposition clearer.
```

### `/branch-safety-check` — Branch Safety

Verify you're on a proper feature branch, not main.

```
/branch-safety-check
```

### `/claude-system-management` — System Config Audit

Audit .claude/ configuration for consistency and drift.

```
/claude-system-management
Audit all agents, skills, and hooks for consistency. Check that
CLAUDE.md matches the current codebase.
```

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

If you have companion plugins installed alongside dev-forge, here's how to trigger their key capabilities.

### superpowers (if installed)

#### `/superpowers:brainstorming` — Explore Design Options

```
/superpowers:brainstorming
I need to add real-time collaboration to the document editor.
Multiple users should be able to edit simultaneously.
```

#### `/superpowers:test-driven-development` — Full TDD Workflow

```
/superpowers:test-driven-development
Implement a rate limiter middleware that allows 100 requests
per minute per API key, with a sliding window algorithm.
```

#### `/superpowers:systematic-debugging` — Hypothesis-Driven Debugging

```
/superpowers:systematic-debugging
Users report that the search API returns stale results for about
30 seconds after updating a document. Cache invalidation issue?
```

#### `/superpowers:writing-plans` — Create Implementation Plan

```
/superpowers:writing-plans
Plan the migration from REST to GraphQL for the user and order
endpoints. We need to maintain backward compatibility.
```

#### `/superpowers:executing-plans` — Execute Plan with Checkpoints

```
/superpowers:executing-plans
Execute the GraphQL migration plan we created. Start with Phase 1:
schema definitions and resolvers for the user endpoint.
```

#### `/superpowers:verification-before-completion` — Final Verification

```
/superpowers:verification-before-completion
I'm about to create a PR for the payment processing feature.
Verify everything is complete and nothing was missed.
```

#### `/superpowers:requesting-code-review` — Request Code Review

```
/superpowers:requesting-code-review
Review the changes in src/services/payment/ — new Stripe
integration replacing the old PayPal module.
```

#### `/superpowers:receiving-code-review` — Handle Review Feedback

```
/superpowers:receiving-code-review
I got review feedback on PR #42. The reviewer flagged concerns
about error handling in the retry logic. Address the feedback.
```

#### `/superpowers:finishing-a-development-branch` — Finish Branch

```
/superpowers:finishing-a-development-branch
The feature is done and tests pass. Decide how to integrate
this branch — merge, squash, or rebase.
```

#### `/superpowers:using-git-worktrees` — Parallel Worktrees

```
/superpowers:using-git-worktrees
I need to work on a hotfix while my feature branch is mid-progress.
Set up an isolated worktree for the fix.
```

#### `/superpowers:dispatching-parallel-agents` — Parallel Tasks

```
/superpowers:dispatching-parallel-agents
Run these independently: lint the entire codebase, audit dependencies
for vulnerabilities, and check for unused exports.
```

### commit-commands (if installed)

#### `/commit` — Create Git Commit

```
/commit
```

Analyzes staged changes and creates a well-formatted commit message.

#### `/commit-push-pr` — Commit, Push, and Open PR

```
/commit-push-pr
```

Commits staged changes, pushes the branch, and opens a pull request in one step.

### code-review (if installed)

#### `/code-review:code-review` — Full Code Review

```
/code-review:code-review
Review PR #35 for correctness, security, and adherence to
our coding standards.
```

### pr-review-toolkit (if installed)

#### `/pr-review-toolkit:review-pr` — Comprehensive PR Review

```
/pr-review-toolkit:review-pr 42
```

Runs a multi-agent review of the specified PR using specialized reviewers.

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
