[Back to README](../README.md)

# Scaffold Guide

The scaffold generates a `.claude/` directory in your project with configuration files tailored to your stack. It is interactive and asks questions to determine what to generate. Run it once per project.

> **Prerequisites**
>
> - dev-forge installed (via marketplace or `--plugin-dir`)
> - A project directory with a git repository

---

## Finding the scaffold script

The scaffold path depends on how you installed dev-forge.

**If installed from the marketplace:**

```bash
DEV_FORGE_PATH=$(grep -o '"installPath": *"[^"]*"' ~/.claude/plugins/installed_plugins.json | grep dev-forge/dev-forge | head -1 | sed 's/.*": *"//' | sed 's/"$//')
```

**If loaded locally:**

```bash
DEV_FORGE_PATH=/path/to/dev-forge
```

Use `$DEV_FORGE_PATH` in all commands below.

---

## Running init.sh

Navigate to your project directory and run:

```bash
cd /path/to/your-project
bash "$DEV_FORGE_PATH/scaffold/init.sh"
```

You can also pass the target directory as an argument:

```bash
bash "$DEV_FORGE_PATH/scaffold/init.sh" /path/to/your-project
```

If a `.claude/` directory already exists, the script will ask whether to overwrite it. To update an existing setup without losing customizations, use `update.sh` instead (see below).

---

## What the script asks

The scaffold runs through four stages. Each stage auto-detects values where possible and lets you confirm or override them.

### Stage 1: Project Identity

| Prompt | What it does |
|--------|-------------|
| **Project name** | Auto-detected from `package.json`, `pyproject.toml`, `Cargo.toml`, or `go.mod`. Falls back to the directory name. |
| **One-line description** | Free text. Used in the generated `CLAUDE.md`. |
| **Project type** | Choose from: Web Frontend, Full-Stack Web, Backend API, CLI Tool, Library, or Other. This determines which optional rule files are generated (e.g., UI/UX rules for frontend projects). |

Example:

```
============================================
  dev-forge scaffold
  Project setup for Claude Code
============================================

[info] Stage 1: Project Identity

Project name [my-app]: my-app
One-line description: A full-stack task management app with real-time updates

Project type:
  1) Web Frontend (React, Vue, Svelte, etc.)
  2) Full-Stack Web (frontend + backend)
  3) Backend API / Service
  4) CLI Tool
  5) Library / Package
  6) Other
Select [1-6]: 2
```

### Stage 2: Language & Runtime

| Prompt | What it does |
|--------|-------------|
| **Primary language** | Choose from: TypeScript, JavaScript, Python, Go, Rust, Java/Kotlin, C/C++, or Other. Auto-detected from config files in the project root. |

The language selection determines default commands for linting, formatting, type checking, and testing.

Example:

```
[info] Stage 2: Language & Runtime

Primary language:
  1) TypeScript
  2) JavaScript
  3) Python
  4) Go
  5) Rust
  6) Java/Kotlin
  7) C/C++
  8) Other
  (auto-detected: TypeScript)
Select [1-8]: 1
```

### Stage 3: Project-Specific Configuration

Prompts in this stage vary based on your project type and language.

**For TypeScript/JavaScript projects:**

| Prompt | Default |
|--------|---------|
| Import alias | `none` (options: `@/`, `~/`, `none`) |

**For frontend projects (Web Frontend or Full-Stack):**

| Prompt | Default |
|--------|---------|
| CSS framework | `None` (options: Tailwind, CSS Modules, None) |
| State management | `None` (options: Zustand, Redux, Jotai, None) |
| Include Storybook? | No |
| E2E runner | `None` (options: Playwright, Cypress, None) |

**For all projects:**

| Prompt | Default |
|--------|---------|
| Lint command | Auto-detected per language (e.g., `npm run lint`, `ruff check .`, `golangci-lint run`) |
| Format command | Auto-detected per language (e.g., `npm run format`, `black .`, `gofmt -w .`) |
| Type check command | Auto-detected per language (e.g., `npx tsc --noEmit`, `mypy .`, `go vet ./...`) |
| Test command | Auto-detected per language (e.g., `npm run test`, `pytest`, `go test ./...`) |
| Coverage thresholds | `80/75/80/80` (statements/branches/functions/lines) |
| Include Docker/CI-CD rules? | No |

Example (Full-Stack TypeScript project):

```
[info] Stage 3: Project-Specific Configuration

Import alias (@/, ~/, or none) [none]: @/
CSS framework (Tailwind/CSS Modules/None) [None]: Tailwind
State management (Zustand/Redux/Jotai/None) [None]: Zustand
Include Storybook? [y/N]: N
E2E runner (Playwright/Cypress/None) [None]: Playwright
Lint command [npm run lint]:
Format command [npm run format]:
Type check command [npx tsc --noEmit]:
Test command [npm run test]:
Coverage thresholds (statements/branches/functions/lines) [80/75/80/80]:
Include Docker/CI-CD rules? [y/N]: y
```

> **Tip:** Press Enter to accept the default value shown in brackets. The script auto-detects commands from your `package.json`, `pyproject.toml`, etc. Only type a value if you want to override the default.

Example (Python backend project):

```
[info] Stage 3: Project-Specific Configuration

Lint command [ruff check .]:
Format command [black .]:
Type check command [mypy .]:
Test command [pytest]:
Coverage thresholds (statements/branches/functions/lines) [80/75/80/80]: 90/85/90/90
Include Docker/CI-CD rules? [y/N]: y
```

### Stage 4: Architecture

| Prompt | What it does |
|--------|-------------|
| **Architecture summary** | 1-2 sentences describing your architecture. Written into `CLAUDE.md`. |
| **Key directories** | Auto-detected from common directory names (`src/`, `lib/`, `app/`, `tests/`, etc.). You can override with a comma-separated list. |

Example:

```
[info] Stage 4: Architecture

Architecture summary (1-2 sentences, or blank): Next.js app router with tRPC API layer and Drizzle ORM
Detected directories:
- `src/`
- `app/`
- `components/`
- `lib/`
- `tests/`
Key directories (comma-separated, or press Enter to use detected):
```

### Output

After all stages complete, the script generates the files and prints a summary:

```
[info] Generating .claude/ configuration...

[ok] CLAUDE.md
[ok] rules/coding-standards.md
[ok] rules/workflow.md
[ok] rules/architecture.md
[ok] rules/testing.md
[ok] rules/token-efficiency.md
[ok] rules/docs.md
[ok] rules/ui-ux.md
[ok] rules/docker-ci-cd.md
[ok] agents/claude-system-architect.md
[ok] agents/code-explorer.md
[ok] agents/code-simplifier.md
[ok] agents/product-strategist.md
[ok] agents/qa-tester.md
[ok] agents/senior-engineer-code-reviewer.md
[ok] agents/silent-failure-hunter.md
[ok] agents/tech-lead-architect.md
[ok] agents/technical-writer.md
[ok] agents/ui-ux-designer.md
[ok] skills/accessibility-audit/SKILL.md
[ok] skills/architecture-review/SKILL.md
[ok] skills/branch-safety-check/SKILL.md
[ok] skills/claude-system-management/SKILL.md
[ok] skills/debugging/SKILL.md
[ok] skills/documentation-review/SKILL.md
[ok] skills/feature-dev/SKILL.md
[ok] skills/implementation-planning/SKILL.md
[ok] skills/readme-optimization/SKILL.md
[ok] skills/security-coverage-audit/SKILL.md
[ok] skills/strict-type-review/SKILL.md
[ok] skills/tdd/SKILL.md
[ok] skills/verification/SKILL.md
[ok] settings.json
[ok] settings.local.json
[ok] hooks/auto-plugin-mode.sh
[ok] hooks/block-ai-attribution.sh
[ok] hooks/block-main-branch-commits.sh
[ok] hooks/enforce-branch-naming.sh
[ok] hooks/session-start-branch-check.sh
[ok] hooks/auto-pr-after-push.sh
[ok] hooks/session-end-claude-system-check.sh
[ok] hooks/plugin-profiles.json
[ok] hooks/session-end-unified-gate.sh
[ok] hooks/security-patterns.txt
[ok] .scaffold-meta.json

============================================
  dev-forge scaffold complete!
============================================

[info] Generated 45 files in /path/to/your-project/.claude/

Next steps:
  1. Review and customize .claude/CLAUDE.md
  2. Fill in .claude/rules/architecture.md with your patterns
  3. Open a Claude Code session to verify hooks fire
  4. Run /branch-safety-check to test the plugin
```

---

## What gets generated

After answering the prompts, the scaffold creates the following files inside `.claude/`:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project identity, stack summary, key paths, and behavior rules. This is the primary context file Claude reads at session start. |
| `rules/coding-standards.md` | Naming conventions, formatting, and import rules for your language. |
| `rules/workflow.md` | Branch strategy, git operations, and PR requirements. |
| `rules/architecture.md` | Directory layout and pattern constraints. |
| `rules/testing.md` | Test runner config, coverage thresholds, and testing conventions. |
| `rules/token-efficiency.md` | Guidelines for token-aware communication. |
| `rules/docs.md` | Documentation standards. |
| `rules/ui-ux.md` | UI/UX rules. Only generated for frontend or full-stack projects. |
| `rules/docker-ci-cd.md` | Docker and CI/CD rules. Only generated if you opted in. |
| `agents/*.md` | 10 agent definitions (code reviewer, architect, QA tester, etc.). Customized with your language and tooling choices. |
| `skills/*/SKILL.md` | 13 skill definitions (TDD, debugging, feature dev, etc.). Customized with your test runner, lint commands, etc. |
| `settings.json` | Plugin IDs, model preferences, and hook registration. |
| `settings.local.json` | Local overrides (not committed to git). |
| `hooks/block-ai-attribution.sh` | Blocks commits/PRs containing AI attribution patterns. |
| `hooks/block-main-branch-commits.sh` | Blocks commits and pushes on main/master branches. |
| `hooks/enforce-branch-naming.sh` | Validates branch names follow `<type>/<description>` convention. |
| `hooks/session-start-branch-check.sh` | Warns if current branch is main/master at session start. |
| `hooks/auto-plugin-mode.sh` | Branch-name-based plugin profile switcher. |
| `hooks/auto-pr-after-push.sh` | Reminds to create a PR after pushing a feature branch. |
| `hooks/plugin-profiles.json` | Plugin profile definitions per branch prefix. |
| `hooks/session-end-unified-gate.sh` | End-of-session quality gate that runs lint, type check, and tests. |
| `hooks/session-end-claude-system-check.sh` | Validates .claude/ config consistency (agent/skill frontmatter, hook references). |
| `hooks/security-patterns.txt` | Patterns used by the security scan hook. |
| `.scaffold-meta.json` | Version, checksums, and metadata for future updates. |

---

## Conflict resolution

If agents or skills already exist in your `.claude/` directory (from a previous scaffold run or manual creation), the scaffold detects the conflict and prompts you for each file:

```
[warn] Conflict: agents/senior-engineer-code-reviewer.md already exists with different content
  [O] Overwrite with scaffold version
  [S] Skip (keep existing)
  [M] Merge (save scaffold version for Claude to merge later)
  Choose [O/S/M]:
```

| Choice | What happens |
|--------|-------------|
| **Overwrite** | Replaces the existing file with the new scaffold version. |
| **Skip** | Keeps your existing file unchanged. |
| **Merge** | Saves the scaffold version as `<filename>.scaffold` alongside your existing file. In your next Claude Code session, ask Claude to merge the two versions — it will combine your customizations with the new scaffold content. |

If the existing file is identical to what the scaffold would generate, it is silently skipped.

---

## After scaffolding

1. **Review `CLAUDE.md`** — This is the most important file. It defines your project identity and constraints for Claude. Edit it to add project-specific details.

2. **Fill in `rules/architecture.md`** — The scaffold generates a placeholder. Replace it with your actual directory layout and pattern constraints.

3. **Verify hooks fire** — Open a Claude Code session. You should see a branch-safety message if you are on `main`.

4. **Test a skill** — Run `/branch-safety-check` to confirm the plugin is loaded and working.

---

## Updating scaffolded files

When dev-forge releases a new version, your scaffolded files may be out of date. The update script applies changes without overwriting your customizations.

```bash
bash "$DEV_FORGE_PATH/scaffold/update.sh"
```

### How the updater works

The updater reads `.scaffold-meta.json` to compare each file against its original checksum.

| File state | What happens |
|------------|-------------|
| **Unmodified** since scaffold | Auto-updated silently |
| **Modified** by you | Shows a diff and asks whether to overwrite |
| **Missing** (deleted) | Warns and skips |
| **Added** after scaffold | Skips (not tracked) |

You are never silently overwritten. If you customized a file, the updater always asks first.

### Checking your current version

```bash
cat .claude/.scaffold-meta.json
```

Key fields: `version` (scaffold version used), `generated_at` (original scaffold timestamp), `updated_at` (last update timestamp), `checksums` (per-file hashes).

---

## Re-scaffolding from scratch

If you want to start over:

```bash
rm -rf .claude/
bash "$DEV_FORGE_PATH/scaffold/init.sh"
```

This deletes all existing configuration and generates fresh files.

---

## See Also

- [Getting Started](getting-started.md)
- [Customization guide](customization.md)
- [Updating dev-forge](updating.md)
- [Hooks reference](hooks.md)
