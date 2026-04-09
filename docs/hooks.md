[Back to README](../README.md)

# Hooks

Think of hooks like automatic safety checks — similar to a smoke detector. You do not have to remember to check for smoke; the detector fires the moment conditions are met. dev-forge hooks run automatically at defined points in a Claude Code session to catch problems before they land in your codebase.

> **Prerequisites**
> - dev-forge installed and scaffold completed (hooks are registered in `.claude/settings.json`)

---

## Hook Lifecycle

Claude Code supports four hook events:

| Event | When it fires |
|---|---|
| `SessionStart` | Once, when a new Claude Code session opens |
| `PreToolUse` | Before Claude executes a matched tool call |
| `PostToolUse` | After Claude executes a matched tool call |
| `Stop` | When the session ends or Claude finishes its last response |

dev-forge uses all four events: `SessionStart`, `PreToolUse`, `PostToolUse`, and `Stop`.

---

## Plugin-Level vs Project-Level Hooks

dev-forge provides hooks at two levels:

| Level | Location | Scope | Customizable? |
|-------|----------|-------|--------------|
| **Plugin-level** | `hooks/hooks.json` inside the dev-forge plugin | Active whenever the plugin is enabled | No — modify the plugin source to change |
| **Project-level** | `.claude/settings.json` in your project | Active in that project only | Yes — edit `.claude/settings.json` |

The scaffold generates **project-level hooks** in `.claude/settings.json` (e.g., `block-main-branch-commits.sh`, `session-start-branch-check.sh`). The plugin also ships its own hooks in `hooks/hooks.json` (e.g., `post-edit-code-quality-check.sh`, `post-edit-accessibility-check.sh`, `ban-hardcoded-waits.sh`) which are always active when dev-forge is enabled.

---

## Blocking vs Warning

Hooks can either **block** the tool call or **warn** without blocking:

- **Blocking:** The hook exits with a non-zero status. Claude Code aborts the tool call and surfaces the error message. The action does not proceed.
- **Warning:** The hook exits with zero but prints a message. Claude Code logs the message and continues.

---

## Hook Reference

| Hook | Trigger | Blocking | What It Checks |
|---|---|---|---|
| `session-start-branch-check.sh` | `SessionStart` | Warning | Warns if the current branch is `main` or `master`; prompts to create a feature branch |
| `auto-plugin-mode.sh` | `SessionStart` | — | Reads branch name and activates matching plugin profile from `plugin-profiles.json` |
| `block-ai-attribution.sh` | `PreToolUse`: `git commit`, `git push`, `gh pr` | Blocking | Rejects commit messages containing AI attribution patterns (e.g., "Co-Authored-By: Claude") |
| `block-main-branch-commits.sh` | `PreToolUse`: `git commit`, `git push`, `gh pr` | Blocking | Blocks commits and pushes directly to `main` or `master` |
| `enforce-branch-naming.sh` | `PreToolUse`: `git checkout -b`, `git switch -c`, `git branch` | Blocking | Validates branch names match the `<type>/<description>` convention |
| `post-edit-code-quality-check.sh` | `PostToolUse`: `Edit`, `Write` | Warning | Runs lint and type checks on edited files after each write |
| `post-edit-accessibility-check.sh` | `PostToolUse`: `Edit`, `Write` | Warning | Scans edited UI files for common accessibility violations |
| `ban-hardcoded-waits.sh` | `PostToolUse`: `Edit`, `Write` | Warning | Flags hardcoded `sleep`, `setTimeout`, and `waitFor` calls with fixed durations |
| `auto-pr-after-push.sh` | `PostToolUse`: `Bash` | Warning | Detects a successful `git push` and reminds Claude to open a PR immediately |
| `session-end-unified-gate.sh` | `Stop` | Blocking | Runs lint, format, type check, tests, and security scan in sequence |
| `session-end-claude-system-check.sh` | `Stop` | Blocking | Validates .claude/ config: agent/skill frontmatter, hook script references, orphaned scripts |

---

## Plugin Auto-Switching

`auto-plugin-mode.sh` runs as part of `SessionStart` (via your `settings.json`) and reads the current branch name to activate a matching plugin profile.

Plugin profiles are defined in `.claude/hooks/plugin-profiles.json`. The file has two sections:

```json
{
  "core": [
    "dev-forge@dev-forge",
    "superpowers",
    "commit-commands",
    "context7",
    "github",
    "code-review",
    "pr-review-toolkit"
  ],
  "branch_modes": {
    "feat/ui-": ["frontend-design", "figma", "playground"],
    "fix/ui-": ["frontend-design"],
    "feat/backend-": ["security-guidance"],
    "fix/backend-": ["security-guidance"],
    "feat/api-": ["security-guidance"],
    "fix/api-": ["security-guidance"],
    "refactor/": ["code-simplifier"],
    "chore/claude-": ["claude-md-management", "skill-creator", "claude-code-setup"]
  }
}
```

- **`core`**: Plugins always enabled, regardless of branch.
- **`branch_modes`**: Keys are branch name prefixes. When the current branch matches a prefix, those plugins are activated in addition to core. Multiple prefixes can match simultaneously.

---

## Unified Gate Sequence

`session-end-unified-gate.sh` runs the full quality gate in sequence. It fires automatically as a `Stop` hook at session end. You can also run it manually:

```bash
bash .claude/hooks/session-end-unified-gate.sh
```

The gate runs these checks in order and stops on the first failure:

1. Lint
2. Format check
3. Type check
4. Unit tests with coverage
5. Storybook build (if configured)
6. E2E tests (if configured)
7. Security scan against `security-patterns.txt`

All steps must pass before git operations are allowed.

---

## Debugging a Blocked Hook

If a hook blocks unexpectedly:

1. Read the error message printed by the hook — it describes what was checked and why it failed.
2. Run the hook script directly to see its full output:
   ```bash
   bash .claude/hooks/block-main-branch-commits.sh
   ```
3. Check the hook's matcher in `.claude/settings.json` to confirm it matches the tool call you made.
4. If the hook is incorrectly blocking, adjust the matcher or the script — see [Customization](customization.md) for how to override hooks without modifying the plugin source.

---

## See Also

- [Skills reference](skills.md)
- [Agents reference](agents.md)
- [Customization guide](customization.md)
- [Getting Started](getting-started.md)
