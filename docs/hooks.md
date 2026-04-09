[Back to README](../README.md)

# Hooks

Think of hooks like automatic safety checks — similar to a smoke detector. You do not have to remember to check for smoke; the detector fires the moment conditions are met. dev-forge hooks run automatically at defined points in a Claude Code session to catch problems before they land in your codebase.

> **Prerequisites**
> - dev-forge installed and `hooks.json` registered in `.claude/settings.json` (see [Getting Started](getting-started.md))

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

## Blocking vs Warning

Hooks can either **block** the tool call or **warn** without blocking:

- **Blocking:** The hook exits with a non-zero status. Claude Code aborts the tool call and surfaces the error message. The action does not proceed.
- **Warning:** The hook exits with zero but prints a message. Claude Code logs the message and continues.

---

## Hook Reference

| Hook | Trigger | Blocking | What It Checks |
|---|---|---|---|
| `session-start-branch-check.sh` | `SessionStart` | Warning | Warns if the current branch is `main` or `master`; prompts to create a feature branch |
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

Plugin profiles are defined in `.claude/hooks/plugin-profiles.json`. Each profile maps a branch prefix pattern to a set of plugins to enable:

```json
{
  "profiles": [
    { "pattern": "feat/", "plugins": ["dev-forge"] },
    { "pattern": "fix/",  "plugins": ["dev-forge"] }
  ]
}
```

When your branch matches a pattern, the corresponding plugins are activated for the session. This lets different branch types load different tool sets automatically.

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
   bash .claude/plugins/dev-forge/hooks/block-main-branch-commits.sh
   ```
3. Check the hook's matcher in `hooks/hooks.json` to confirm it matches the tool call you made.
4. If the hook is incorrectly blocking, adjust the matcher or the script — see [Customization](customization.md) for how to override hooks without modifying the plugin source.

---

## See Also

- [Skills reference](skills.md)
- [Agents reference](agents.md)
- [Customization guide](customization.md)
- [Getting Started](getting-started.md)
