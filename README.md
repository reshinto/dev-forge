# dev-forge

A Claude Code plugin that provides a structured set of agents, skills, and hooks for software development workflows. It enforces branch hygiene, code quality gates, and accessibility standards automatically, and gives you named agents and reusable slash commands to run reviews, audits, and planning tasks on demand.

## What You Get

| Component | Count | What it does |
|-----------|-------|--------------|
| Agents | 10 | Specialized reviewers and planners invoked by name in any session |
| Skills | 13 | Slash commands for development workflows (TDD, debugging, reviews, audits) |
| Hooks | 11 | Automated guards that run on git operations, file edits, and session lifecycle |
| Scaffold | 2 scripts | Generates and updates `.claude/` project config from templates |

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Git

## Quick Start

### Install from marketplace (recommended)

Run these commands from any project directory:

1. Add the marketplace (one-time setup):
   ```sh
   claude plugin marketplace add reshinto/dev-forge
   ```

2. Install the plugin:
   ```sh
   claude plugin install dev-forge@dev-forge
   ```

Once installed, dev-forge is available in every Claude Code session across all your projects.

3. Find the plugin install path and run the project scaffold (from your target project directory):
   ```sh
   DEV_FORGE_PATH=$(grep -o '"installPath": *"[^"]*"' ~/.claude/plugins/installed_plugins.json | grep dev-forge/dev-forge | head -1 | sed 's/.*": *"//' | sed 's/"$//')
   bash "$DEV_FORGE_PATH/scaffold/init.sh"
   ```

4. Verify setup:
   ```
   /branch-safety-check
   ```

### Load locally for development/testing

1. Clone the repository:
   ```sh
   git clone https://github.com/reshinto/dev-forge.git
   ```

2. Start a Claude Code session with the plugin loaded:
   ```sh
   claude --plugin-dir /path/to/dev-forge
   ```

3. Run the project scaffold (from your project directory):
   ```sh
   bash /path/to/dev-forge/scaffold/init.sh
   ```

## Concepts in 60 Seconds

**Agents** are personas with defined expertise. When you ask Claude Code to act as `senior-engineer-code-reviewer` or `tech-lead-architect`, it follows that agent's instructions — scoped knowledge, review criteria, and response format. Agents are invoked by name during a session.

**Skills** are slash commands backed by prompt files. Typing `/tdd` or `/debugging` loads a structured workflow prompt that guides Claude Code through a specific development task. Skills are composable and project-independent.

**Hooks** are shell scripts that fire automatically on Claude Code lifecycle events — before commits, after file edits, after pushes. They run outside the model, so they enforce rules consistently regardless of what was said in the session.

**Rules** are Markdown files in `.claude/rules/` that set project-specific constraints (naming conventions, architecture patterns, coding standards). They are loaded as context at session start and referenced by agents and skills.

## Documentation

| I want to... | Read |
|---|---|
| Set up my project | [docs/scaffold.md](docs/scaffold.md) |
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
| `block-main-branch-commits` | PreToolUse | Blocks commits and pushes on `main` or `master` |
| `block-ai-attribution` | PreToolUse | Blocks commits containing AI/assistant attribution in messages |
| `enforce-branch-naming` | PreToolUse | Blocks branch creation if name does not match `<type>/<description>` |
| `session-start-branch-check` | SessionStart | Warns if the current branch is `main`, `master`, or has no task context |
| `auto-plugin-mode` | SessionStart | Activates plugin profiles based on branch name prefix |
| `auto-pr-after-push` | PostToolUse | Reminds to create a PR after pushing a feature branch |
| `post-edit-code-quality-check` | PostToolUse | Runs language-appropriate linting and type checking after source file edits |
| `post-edit-accessibility-check` | PostToolUse | Checks UI component files for accessibility attribute issues after edits |
| `ban-hardcoded-waits` | PostToolUse | Warns when `sleep`, hardcoded timeouts, or arbitrary waits are introduced |
| `session-end-unified-gate` | Stop | Runs lint, format, typecheck, tests, and security scan at session end |
| `session-end-claude-system-check` | Stop | Validates .claude/ config consistency at session end |

## Scaffold

**`init.sh`** generates a `.claude/` directory in your project from templates, including `CLAUDE.md`, rules, agents, skills, hooks, and settings. Run once per project. See the [Scaffold guide](docs/scaffold.md) for details.

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

## License

MIT — see [LICENSE](LICENSE)
