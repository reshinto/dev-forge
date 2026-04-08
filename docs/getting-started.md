[Back to README](../README.md)

# Getting Started

dev-forge is a Claude Code plugin that installs structured workflows, review agents, and safety hooks into any project. This guide covers two installation methods and walks through your first session.

> **Prerequisites**
> - Claude Code installed and authenticated
> - Git initialized in your project
> - Node.js 18+ (for projects using the JS/TS toolchain)

---

## Installation

### Method 1: Plugin add (recommended)

Install dev-forge as a Claude Code plugin directly from its repository:

```bash
claude plugin add https://github.com/your-org/dev-forge
```

Claude Code registers the plugin and makes its skills, agents, and hooks available automatically in every session.

### Method 2: Self-hosted (git clone)

Clone the repository alongside your project and reference it as a local plugin:

```bash
git clone https://github.com/your-org/dev-forge ~/.claude/plugins/dev-forge
claude plugin add ~/.claude/plugins/dev-forge
```

Use this method when you need to customize hook scripts or pin to a specific version.

---

## Running init.sh

After installation, scaffold your project's `.claude/` directory:

```bash
bash $(claude plugin path dev-forge)/scaffold/init.sh
```

`init.sh` is interactive. It detects your project name, stack, and language, then generates the following files:

| File | Purpose |
|---|---|
| `.claude/CLAUDE.md` | Project identity, stack summary, key paths, and behavior rules |
| `.claude/rules/coding-standards.md` | Naming conventions, formatting, import rules |
| `.claude/rules/workflow.md` | Branch strategy, git operations, PR requirements |
| `.claude/rules/architecture.md` | Directory layout, pattern constraints |
| `.claude/rules/testing.md` | Test runner config, coverage thresholds |
| `.claude/rules/token-efficiency.md` | Token-aware communication guidelines |
| `.claude/rules/docs.md` | Documentation standards |
| `.claude/rules/ui-ux.md` | UI/UX rules (generated when project has a frontend) |
| `.claude/rules/docker-ci-cd.md` | Docker and CI/CD rules (generated when applicable) |
| `.claude/settings.json` | Plugin IDs, model preferences, hook registration |
| `.claude/settings.local.json` | Local overrides (not committed) |
| `.claude/hooks/auto-plugin-mode.sh` | Branch-name-based plugin profile switcher |
| `.claude/hooks/plugin-profiles.json` | Plugin profile definitions per branch prefix |
| `.claude/hooks/session-end-unified-gate.sh` | End-of-session quality gate (lint, typecheck, tests) |
| `.claude/hooks/security-patterns.txt` | Patterns used by the security scan hook |
| `.claude/.scaffold-meta.json` | Version and checksum record for future updates |

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

| Symptom | Cause | Fix |
|---|---|---|
| Skills not found after plugin add | Plugin not registered in settings.json | Run `claude plugin list` and confirm `dev-forge` appears |
| Hooks not firing | `settings.json` missing hook entries | Re-run `init.sh` or manually add hook blocks from `hooks/hooks.json` |
| `block-main-branch-commits` fires on non-main branch | `CLAUDE_BRANCH` env var not set | Ensure you are in a git repo with a valid HEAD |
| `enforce-branch-naming` rejects valid name | Pattern mismatch with your naming convention | Edit `.claude/hooks/plugin-profiles.json` to adjust the regex |
| `session-end-unified-gate.sh` fails with missing command | Test runner or linter not installed | Install missing tools per your `rules/testing.md` configuration |
| `init.sh` aborts with "already exists" | `.claude/` directory present | Run `scaffold/update.sh` instead to apply only changed files |

---

## See Also

- [Skills reference](skills.md)
- [Agents reference](agents.md)
- [Hooks reference](hooks.md)
- [Customization guide](customization.md)
