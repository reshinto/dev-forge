# claude-forge

A Claude Code plugin that provides a structured set of agents, skills, and hooks for software development workflows. It enforces branch hygiene, code quality gates, and accessibility standards automatically, and gives you named agents and reusable slash commands to run reviews, audits, and planning tasks on demand.

## What You Get

| Component | Count | What it does |
|-----------|-------|--------------|
| Agents | 10 | Specialized reviewers and planners invoked by name in any session |
| Skills | 13 | Slash commands for development workflows (TDD, debugging, reviews, audits) |
| Hooks | 8 | Automated guards that run on git operations and file edits |
| Scaffold | 2 scripts | Generates and updates `.claude/` project config from templates |

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Git
- `jq` (used by hook scripts to parse tool input; hooks skip gracefully if missing)

## Quick Start

1. Install the plugin:
   ```sh
   claude plugin add --from-git https://github.com/reshinto/claude-forge
   ```

2. Run the project scaffold:
   ```sh
   git clone https://github.com/reshinto/claude-forge /tmp/claude-forge && bash /tmp/claude-forge/scaffold/init.sh
   ```

3. Open a Claude Code session in your project.

4. Verify setup:
   ```
   /branch-safety-check
   ```

## Concepts in 60 Seconds

**Agents** are personas with defined expertise. When you ask Claude Code to act as `senior-engineer-code-reviewer` or `tech-lead-architect`, it follows that agent's instructions — scoped knowledge, review criteria, and response format. Agents are invoked by name during a session.

**Skills** are slash commands backed by prompt files. Typing `/tdd` or `/debugging` loads a structured workflow prompt that guides Claude Code through a specific development task. Skills are composable and project-independent.

**Hooks** are shell scripts that fire automatically on Claude Code lifecycle events — before commits, after file edits, after pushes. They run outside the model, so they enforce rules consistently regardless of what was said in the session.

**Rules** are Markdown files in `.claude/rules/` that set project-specific constraints (naming conventions, architecture patterns, coding standards). They are loaded as context at session start and referenced by agents and skills.

## Documentation

| I want to... | Read |
|---|---|
| Use skills and agents | [docs/skills.md](docs/skills.md), [docs/agents.md](docs/agents.md) |
| Understand hooks | [docs/hooks.md](docs/hooks.md) |
| Customize for my project | [docs/customization.md](docs/customization.md) |
| Add new agents/skills | [docs/extending.md](docs/extending.md) |
| Update the plugin | [docs/updating.md](docs/updating.md) |
| Remove the plugin | [docs/uninstalling.md](docs/uninstalling.md) |
| Contribute | [docs/contributing.md](docs/contributing.md) |
| Write better prompts | [docs/prompting-guide.md](docs/prompting-guide.md) |
| Understand internals | [docs/architecture.md](docs/architecture.md) |

## Agents

| Name | Description |
|------|-------------|
| `senior-engineer-code-reviewer` | Reviews code for correctness, maintainability, and adherence to project standards |
| `tech-lead-architect` | Evaluates structural decisions, patterns, and system design trade-offs |
| `qa-tester` | Validates behavior, test coverage, edge cases, and regression risk |
| `ui-ux-designer` | Reviews interface design, component structure, and user interaction flows |
| `technical-writer` | Reviews documentation for clarity, completeness, and contributor onboarding quality |
| `silent-failure-hunter` | Identifies unhandled errors, swallowed exceptions, and missing failure paths |
| `code-simplifier` | Finds opportunities to reduce complexity, duplication, and unnecessary abstraction |
| `code-explorer` | Maps unfamiliar codebases, traces data flow, and surfaces key entry points |
| `claude-system-architect` | Designs and audits `.claude/` configuration: agents, skills, hooks, and rules |
| `product-strategist` | Evaluates features against product goals and user needs before implementation |

## Skills

| Name | Description |
|------|-------------|
| `/branch-safety-check` | Verifies the current branch is a valid task branch and creates one if needed |
| `/claude-system-management` | Creates, updates, and audits `.claude/` project configuration |
| `/tdd` | Guides test-driven development: write failing test, implement, refactor |
| `/debugging` | Systematic debugging workflow with structured diagnostic steps |
| `/feature-dev` | End-to-end feature development following a 7-step workflow |
| `/implementation-planning` | Breaks a feature or requirement into phased implementation milestones |
| `/verification` | Pre-completion checklist to confirm work is done, tested, and passing |
| `/accessibility-audit` | Audits UI components for WCAG 2.1 AA compliance |
| `/architecture-review` | Reviews architectural decisions for patterns, trade-offs, and consistency |
| `/documentation-review` | Reviews docs for ELI5 clarity, accuracy, and structural consistency |
| `/security-coverage-audit` | Runs OWASP client-side checks and verifies test coverage thresholds |
| `/strict-type-review` | Reviews TypeScript for strict-mode compliance and runtime type safety |
| `/readme-optimization` | Optimizes README structure for discoverability and accurate feature positioning |

## Hooks

| Name | Trigger | Behavior |
|------|---------|----------|
| `block-main-branch-commits` | Pre-commit | Blocks commits on `main` or `master` |
| `block-ai-attribution` | Pre-commit | Blocks commits containing AI/assistant attribution in messages |
| `enforce-branch-naming` | Pre-commit | Blocks commits if branch name does not match `<type>/<description>` |
| `session-start-branch-check` | Session start | Warns if the current branch is `main`, `master`, or has no task context |
| `auto-pr-after-push` | Post-push | Opens a pull request automatically after pushing a feature branch |
| `post-edit-code-quality-check` | Post file edit | Runs language-appropriate linting and type checking after source file edits |
| `post-edit-accessibility-check` | Post file edit | Checks UI component files for accessibility attribute issues after edits |
| `ban-hardcoded-waits` | Post file edit | Warns when `sleep`, hardcoded timeouts, or arbitrary waits are introduced |

## Scaffold

**`init.sh`** generates a `.claude/` directory in your project from templates, including `CLAUDE.md`, `PLAN.md`, a `rules/` directory with standard rule files, and a `memory/` directory. Run once per project.

**`update.sh`** applies diff-based updates when the plugin releases new template versions. It merges changes into your existing `.claude/` config without overwriting local customizations.

## Supported Languages

The `post-edit-code-quality-check` hook runs the appropriate toolchain for each file type:

| Language | Extensions |
|----------|------------|
| TypeScript / JavaScript | `.ts`, `.tsx`, `.js`, `.jsx` |
| Python | `.py` |
| Java / Kotlin | `.java`, `.kt` |
| Go | `.go` |
| Rust | `.rs` |
| C / C++ | `.c`, `.cpp`, `.h`, `.hpp` |

## Marketplace-Ready

This plugin follows the official Claude Code plugin marketplace schema. It can be submitted to the marketplace without modification once the marketplace is publicly available.

## License

MIT — see [LICENSE](LICENSE)
