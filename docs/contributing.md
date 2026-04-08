[Back to README](../README.md)

# Contributing to dev-forge

## What this covers

How to contribute new agents, skills, hooks, and scaffold templates to the dev-forge project itself. This is for changes to the plugin — not changes to your own project's `.claude/` directory.

For adding extensions to your own project only, see [Extending dev-forge](./extending.md).

## Prerequisites

> You need Git and Claude Code installed. A working knowledge of Bash is helpful for hook contributions.

---

## Development setup

```bash
git clone https://github.com/<org>/dev-forge.git
cd dev-forge
```

No build step is required. All agents, skills, and hooks are plain text files or shell scripts.

Open the repo in Claude Code to get the plugin's own `.claude/` configuration active during development.

---

## Contribution types

| Type | Required artifacts |
|------|--------------------|
| New agent | `agents/<name>.md` |
| New skill | `skills/<name>/SKILL.md` |
| New hook | `hooks/<name>.sh`, entry in `hooks/hooks.json` |
| Scaffold template change | `scaffold/templates/<path>`, update `scaffold/update.sh` if adding a new tracked file |
| Documentation | `docs/<name>.md` or update existing |
| Bug fix | Changed file(s) + description in PR body |

All contributions require a CHANGELOG entry under `## [Unreleased]`.

---

## Adding an agent

1. Create `agents/<name>.md`. The filename must match the `name` frontmatter field.
2. Required frontmatter fields: `name`, `description`, `tools`, `model`, `maxTurns`.
3. Required sections in the body: `## Role`, `## Review Checklist` (or equivalent), `## Output Format`.
4. Keep the agent under 80 lines total. Agents that grow beyond this are usually trying to do too much.
5. Add a CHANGELOG entry.
6. Open a PR. Include one example invocation in the PR description showing expected output.

```bash
# Verify your agent file is valid YAML frontmatter before opening a PR
python3 -c "
import sys, re
content = open('agents/<name>.md').read()
match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
if not match: sys.exit('No frontmatter found')
print('Frontmatter OK')
"
```

---

## Adding a skill

1. Create the directory `skills/<name>/`.
2. Create `skills/<name>/SKILL.md`.
3. Required frontmatter fields: `name`, `description`, `user-invocable`.
4. Required sections: `## Task`, `## Instructions`, `## Rules`, `## Output Format`.
5. If the skill delegates to one or more agents, name them explicitly in the instructions.
6. Add a CHANGELOG entry.
7. Open a PR. Include a short example session showing the skill being invoked.

Skills should be self-contained instruction sets. Do not embed project-specific logic — skills must work across any project that installs dev-forge.

---

## Adding a hook

1. Create `hooks/<name>.sh`. Make it executable: `chmod +x hooks/<name>.sh`.
2. The script must be self-gating: check whether it applies before doing anything expensive.
3. Write all diagnostic output to `stderr`. Write nothing to `stdout` unless the hook is expected to produce output consumed by Claude Code.
4. Exit `0` to pass, non-zero to block.
5. Register the hook in `hooks/hooks.json` under the correct lifecycle event.
6. Add a CHANGELOG entry.
7. Open a PR. Include a test case showing the hook blocking and passing.

Every hook must handle the case where it is run outside a git repository gracefully (do not crash; exit 0 with a warning to stderr).

---

## PR requirements

- One logical change per PR. Split unrelated changes.
- PR title: imperative mood, under 72 characters. Example: `Add security-scanner agent`.
- PR body: what changed, why, and how to test it manually.
- CHANGELOG entry under `## [Unreleased]` in the correct category (`Added`, `Changed`, `Fixed`, `Removed`).
- All shell scripts must pass `shellcheck` with no warnings.
- No AI attribution in commit messages or PR descriptions.

---

## See also

- [Architecture internals](./architecture.md)
- [Extending dev-forge](./extending.md)
- [CHANGELOG](../CHANGELOG.md)
