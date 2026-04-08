[Back to README](../README.md)

# Extending claude-forge

## What this covers

This guide explains how to add your own agents, skills, hooks, and plugin profiles to claude-forge so the plugin fits your project's exact workflow.

Think of claude-forge as a set of defaults. Extending it means layering your own rules on top without touching the plugin's own files — so updates stay clean.

## Prerequisites

> You must have claude-forge installed and a project scaffolded with `scaffold/init.sh` before extending it. See the [README](../README.md) for setup steps.

---

## Adding a custom agent

Agents are sub-models Claude Code can delegate to. Each agent is a Markdown file with YAML frontmatter.

**File location:** `.claude/agents/<name>.md` in your project.

### Frontmatter schema

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | yes | Kebab-case. Must match filename. |
| `description` | string | yes | One sentence shown in agent picker. |
| `tools` | string[] | yes | Tools the agent may call. |
| `model` | string | yes | `sonnet` or `opus`. |
| `maxTurns` | number | no | Defaults to 10. |

### Required body sections

- `## Role` — what the agent is responsible for
- `## Review Checklist` — numbered checks the agent runs
- `## Output Format` — shape of the response (e.g., `PASS/WARN/FAIL` lines)

### Naming conventions

- Lowercase kebab-case: `security-scanner`, not `SecurityScanner`
- Name by function: `api-contract-reviewer`, not `bob`
- Filename must match the `name` frontmatter field exactly

---

## Adding a custom skill

Skills are structured instruction sets Claude Code loads when invoked via `/skill-name` or the Skill tool.

**File location:** `.claude/skills/<name>/SKILL.md` in your project.

### Frontmatter schema

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | yes | Kebab-case. Used as the invocation name. |
| `description` | string | yes | One sentence shown in skill picker. |
| `user-invocable` | boolean | yes | `true` if triggerable via slash command. |

### Required body sections

- `## Task` — one sentence stating what the skill accomplishes
- `## Instructions` — numbered steps Claude follows
- `## Rules` — hard constraints, imperative mood
- `## Output Format` — what Claude produces when done

---

## Adding a custom hook

Hooks are shell scripts that run at specific points in the session lifecycle. They gate or observe tool calls.

**File location:** `.claude/hooks/<name>.sh` in your project.

### Exit code semantics

| Exit code | Effect |
|-----------|--------|
| `0` | Pass — tool call proceeds |
| Non-zero | Block — Claude Code stops the call and shows stderr |

Always write a diagnostic message to `stderr` before exiting non-zero.

### Available environment variables

| Variable | Value |
|----------|-------|
| `$CLAUDE_TOOL_INPUT` | JSON string of the tool's input parameters |
| `$CLAUDE_PROJECT_DIR` | Absolute path to the project root |
| `$CLAUDE_PLUGIN_ROOT` | Absolute path to the claude-forge plugin directory |

### Registering in settings.json

Add an entry under the correct lifecycle event in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [{ "type": "command", "command": ".claude/hooks/my-check.sh", "timeout": 10 }]
      }
    ]
  }
}
```

**Lifecycle events:** `SessionStart`, `PreToolUse`, `PostToolUse`, `Stop`

---

## Adding a new plugin profile

Plugin profiles let you automatically enable extra plugins when Claude Code detects a certain branch name prefix.

Edit `.claude/hooks/plugin-profiles.json`:

```json
{
  "core": ["claude-forge@local", "superpowers"],
  "branch_modes": {
    "feat/payments-": ["stripe-docs", "pci-compliance-checker"],
    "feat/infra-":   ["terraform-helper"]
  }
}
```

- `core`: Always-enabled plugins, regardless of branch.
- `branch_modes`: Keys are branch name prefixes. Values are plugin lists to add when the prefix matches.

---

## Testing extensions

| Extension type | How to test |
|----------------|-------------|
| Agent | Invoke directly in Claude Code, verify output format matches spec |
| Skill | Run `/my-skill`, check that all instructions are followed |
| Hook (PreToolUse) | Attempt the gated action (e.g., `git commit`), verify block fires |
| Hook (PostToolUse) | Perform an Edit or Write, verify hook output appears |
| Plugin profile | Create a branch with the prefix, open Claude Code, confirm plugins activate |

## See also

- [Architecture internals](./architecture.md)
- [Contributing to claude-forge](./contributing.md)
- [Updating the plugin](./updating.md)
