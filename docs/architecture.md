[Back to README](../README.md)

# Architecture

## What this covers

Internals of how dev-forge works: the system model, file layout, settings resolution, hook execution, plugin profiles, and the session lifecycle. Intended for contributors and advanced users who need to understand why things behave the way they do.

## Prerequisites

> Familiarity with Claude Code's hook system and basic shell scripting is assumed here.

---

## System model: 4 layers

dev-forge is organized into four layers that compose at runtime:

| Layer | What it contains | Where it lives |
|-------|-----------------|----------------|
| **Agents** | Sub-models for delegated review and analysis tasks | `agents/*.md` |
| **Skills** | Structured instruction sets invoked during a session | `skills/*/SKILL.md` |
| **Hooks** | Shell scripts that gate or observe tool calls | `hooks/*.sh`, `hooks/hooks.json` |
| **Rules** | Constraints injected into project CLAUDE.md via scaffold | `scaffold/templates/rules/` |

Agents and skills are passive: they do nothing until invoked. Hooks are active: they fire automatically at defined lifecycle points.

---

## File layout

```
dev-forge/
  agents/          # Plugin-side agent definitions (*.md)
  skills/          # Plugin-side skill definitions (*/SKILL.md)
  hooks/           # Hook scripts + hooks.json registry
  scaffold/
    init.sh        # Interactive setup — generates .claude/ in a project
    update.sh      # Diff-based updater for scaffolded files
    templates/     # {{PLACEHOLDER}} template files for init.sh
  docs/
  CHANGELOG.md
  LICENSE
```

---

## Settings resolution order

Claude Code merges two settings files in the project's `.claude/` directory:

1. `settings.json` — committed to version control, shared across the team
2. `settings.local.json` — gitignored, machine-local overrides

Fields in `settings.local.json` take precedence over `settings.json` when both define the same key. The plugin's own `hooks/hooks.json` is loaded separately by the plugin system and does not participate in this merge — it defines the plugin-level hooks that are always active when the plugin is enabled.

---

## Hook execution model

### Environment variables

Every hook script receives these environment variables from Claude Code:

| Variable | Value |
|----------|-------|
| `$CLAUDE_TOOL_INPUT` | JSON string of the triggering tool's input |
| `$CLAUDE_PROJECT_DIR` | Absolute path to the project root |
| `$CLAUDE_PLUGIN_ROOT` | Absolute path to the dev-forge plugin directory |

### Exit codes

| Exit code | Meaning |
|-----------|---------|
| `0` | Pass — the tool call proceeds normally |
| Non-zero | Block — Claude Code stops the tool call |

When blocking, write a human-readable explanation to `stderr`. Claude Code surfaces this message to the user.

### Timeout

Each hook entry in `hooks.json` has a `timeout` field (in seconds). If the hook script does not exit within this window, Claude Code treats it as a pass and continues. Keep hook scripts fast: under 5 seconds for PreToolUse, under 10 seconds for PostToolUse.

---

## Plugin-profiles.json schema

The scaffold generates `.claude/hooks/plugin-profiles.json` in each project. The `auto-plugin-mode.sh` SessionStart hook reads this file to enable extra plugins based on the current branch name.

```json
{
  "core": ["<plugin-id>", "..."],
  "branch_modes": {
    "<branch-prefix>": ["<plugin-id>", "..."]
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `core` | string[] | Plugins always enabled, regardless of branch |
| `branch_modes` | object | Keys are branch name prefixes; values are extra plugin lists |

Resolution: `auto-plugin-mode.sh` reads the current branch, iterates over all keys in `branch_modes`, and activates plugins for every prefix that matches. Multiple prefixes can match simultaneously.

---

## Agent and skill invocation model

| Aspect | Agents | Skills |
|--------|--------|--------|
| Discovery | File presence in `agents/*.md` | Directory presence in `skills/*/SKILL.md` |
| Invocation | Agent picker in Claude Code UI | `/skill-name` or Skill tool |
| Execution | Sub-model in a separate turn | Instructions injected into the active session |
| Tools | Restricted to frontmatter `tools` list | Inherits session tools |

---

## Session lifecycle

| Phase | Hooks that fire | Can block? |
|-------|----------------|------------|
| Session opens | `SessionStart`: `session-start-branch-check.sh`, `auto-plugin-mode.sh` | Yes (exit 2 blocks) |
| Each tool call | `PreToolUse`: branch/attribution/naming guards | Yes |
| After each tool call | `PostToolUse`: code quality, accessibility, PR automation | Yes |
| Session closes | `Stop`: `session-end-unified-gate.sh` (full quality gate) | No — output shown but session already ended |

Stop hooks cannot prevent the session from closing. Their exit code is reported to the user but does not cancel anything. Use PreToolUse hooks if you need hard blocks.

---

## See also

- [Extending dev-forge](./extending.md)
- [Contributing to dev-forge](./contributing.md)
- [Updating dev-forge](./updating.md)
