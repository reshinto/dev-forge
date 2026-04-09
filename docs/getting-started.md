[Back to README](../README.md)

# Getting Started

dev-forge is a Claude Code plugin that installs structured workflows, review agents, and safety hooks into any project. This guide covers installation and walks through your first session.

> **Prerequisites**
>
> - Claude Code installed and authenticated
> - Git initialized in your project

---

## How the marketplace works

dev-forge is distributed as a **self-hosted plugin marketplace**. The GitHub repository serves double duty:

1. **Marketplace catalog** — `.claude-plugin/marketplace.json` tells Claude Code what plugins are available
2. **Plugin source** — the plugin code (agents, skills, hooks) lives in the same repository

When a user runs `claude plugin marketplace add reshinto/dev-forge`, Claude Code fetches the repository and reads `marketplace.json` to discover available plugins. When they then run `claude plugin install dev-forge@dev-forge`, Claude Code installs the plugin from the source specified in the catalog (`"source": "."` — the repo root).

This means there is no external registry. The GitHub repo **is** the marketplace.

---

## Installation

### Method 1: Install from marketplace (recommended)

From any project directory, add the marketplace and install the plugin:

```bash
# Add the marketplace (one-time setup)
claude plugin marketplace add reshinto/dev-forge

# Install the plugin
claude plugin install dev-forge@dev-forge
```

The first command registers the dev-forge GitHub repository as a marketplace source. The second installs the plugin from that marketplace. After installation, all dev-forge skills, agents, and hooks are available in every Claude Code session — regardless of which project you are in.

### Method 2: Load locally for development/testing

Clone the repository and load it directly for a single session:

```bash
git clone https://github.com/reshinto/dev-forge.git
claude --plugin-dir /path/to/dev-forge
```

This loads the plugin for the current session only and does not persist across sessions. Use this when you need to customize scripts or test changes before committing.

---

## Running init.sh

After installation, scaffold your project's `.claude/` directory:

```bash
# If installed from marketplace
DEV_FORGE_PATH=$(grep -o '"installPath": *"[^"]*"' ~/.claude/plugins/installed_plugins.json | grep dev-forge/dev-forge | head -1 | sed 's/.*": *"//' | sed 's/"$//')
bash "$DEV_FORGE_PATH/scaffold/init.sh"

# If loaded locally
bash /path/to/dev-forge/scaffold/init.sh
```

`init.sh` is interactive. It detects your project name, stack, and language, then generates the following files:

| File                                        | Purpose                                                        |
| ------------------------------------------- | -------------------------------------------------------------- |
| `.claude/CLAUDE.md`                         | Project identity, stack summary, key paths, and behavior rules |
| `.claude/rules/coding-standards.md`         | Naming conventions, formatting, import rules                   |
| `.claude/rules/workflow.md`                 | Branch strategy, git operations, PR requirements               |
| `.claude/rules/architecture.md`             | Directory layout, pattern constraints                          |
| `.claude/rules/testing.md`                  | Test runner config, coverage thresholds                        |
| `.claude/rules/token-efficiency.md`         | Token-aware communication guidelines                           |
| `.claude/rules/docs.md`                     | Documentation standards                                        |
| `.claude/rules/ui-ux.md`                    | UI/UX rules (generated when project has a frontend)            |
| `.claude/rules/docker-ci-cd.md`             | Docker and CI/CD rules (generated when applicable)             |
| `.claude/settings.json`                     | Plugin IDs, model preferences, hook registration               |
| `.claude/settings.local.json`               | Local overrides (not committed)                                |
| `.claude/hooks/auto-plugin-mode.sh`         | Branch-name-based plugin profile switcher                      |
| `.claude/hooks/plugin-profiles.json`        | Plugin profile definitions per branch prefix                   |
| `.claude/hooks/session-end-unified-gate.sh` | End-of-session quality gate (lint, typecheck, tests)           |
| `.claude/hooks/security-patterns.txt`       | Patterns used by the security scan hook                        |
| `.claude/.scaffold-meta.json`               | Version and checksum record for future updates                 |

---

## Verifying Installation

**Check hooks fire:**

Start a new Claude Code session. You should see a branch-safety message at session start if you are on `main`. Try creating a branch with a non-standard name — the `enforce-branch-naming` hook will warn you.

**Check skills are available:**

In a Claude Code session, type `/branch-safety-check`. Claude should invoke the skill without errors. Try `/tdd` to confirm skill loading works end-to-end.

**Check agents are available:**

Ask Claude to "use the senior-engineer-code-reviewer agent to review the last change." The agent should respond with a structured review using only read-only tools.

---

## First Session Walkthrough

1. Open a Claude Code session in your project directory.
2. The `session-start-branch-check` hook runs automatically and confirms you are not on `main`.
3. Create a feature branch: `git checkout -b feat/my-feature`.
4. Ask Claude to plan the feature using `/implementation-planning`.
5. Implement with `/tdd` to drive tests first.
6. Before finishing, run `/verification` to confirm completeness.
7. Use `/feature-dev` for a guided end-to-end walkthrough of all 7 steps.

---

## Troubleshooting

| Symptom                                                  | Cause                                        | Fix                                                                                                    |
| -------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Skills not found                                         | Plugin not loaded                            | Run `claude plugin install dev-forge@dev-forge` or start with `claude --plugin-dir /path/to/dev-forge` |
| Hooks not firing                                         | `settings.json` missing hook entries         | Re-run `init.sh` or manually add hook blocks from `hooks/hooks.json`                                   |
| `block-main-branch-commits` fires on non-main branch     | `CLAUDE_BRANCH` env var not set              | Ensure you are in a git repo with a valid HEAD                                                         |
| `enforce-branch-naming` rejects valid name               | Pattern mismatch with your naming convention | Edit `.claude/hooks/plugin-profiles.json` to adjust the regex                                          |
| `session-end-unified-gate.sh` fails with missing command | Test runner or linter not installed          | Install missing tools per your `rules/testing.md` configuration                                        |
| `init.sh` aborts with "already exists"                   | `.claude/` directory present                 | Run `scaffold/update.sh` instead to apply only changed files                                           |

---

## See Also

- [Skills reference](skills.md)
- [Agents reference](agents.md)
- [Hooks reference](hooks.md)
- [Customization guide](customization.md)
