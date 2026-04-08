[Back to README](../README.md)

# Updating dev-forge

## What this covers

How to keep both the plugin itself and your scaffolded project files current as dev-forge evolves.

There are two separate things that update independently. Confusing them is the most common mistake.

## Prerequisites

> You need an existing dev-forge installation and a project that was scaffolded with `scaffold/init.sh`. If you haven't scaffolded yet, see the [README](../README.md).

---

## Two things that update separately

| Thing | What it is | How to update |
|-------|------------|---------------|
| **Plugin** | The agents, skills, and hooks that dev-forge itself ships | Re-clone or `claude plugin update` |
| **Scaffold** | The `.claude/` files generated into your project | `bash scaffold/update.sh` |

The plugin and the scaffold version together. If you update the plugin but not the scaffold, your project files may be out of date, and vice versa.

---

## Updating the plugin

### Via Claude Code plugin manager

```bash
claude plugin update dev-forge
```

This pulls the latest agents, skills, and hook scripts from the plugin source.

### Via re-clone

If you installed by cloning the repo directly:

```bash
cd /path/to/dev-forge
git pull origin main
```

Then restart any active Claude Code sessions so the updated agents and skills are picked up.

---

## Updating scaffolded project files

Run the update script from inside your project directory:

```bash
bash /path/to/dev-forge/scaffold/update.sh
```

Or, if you have the scaffold path in your project:

```bash
bash scaffold/update.sh
```

### What the updater does

The updater reads `.claude/.scaffold-meta.json` to determine what was generated and when. For each file, it computes a checksum and compares it against the stored value from when the file was first created.

| File state | Updater action |
|------------|----------------|
| Unmodified since scaffold | Auto-updates silently |
| Modified by you | Shows a diff, asks whether to overwrite |
| Missing (deleted) | Warns, skips |
| Added after scaffold | Skips (not tracked) |

You are never silently overwritten. If you have customized a file, the updater always asks first.

---

## Checking your current version

The scaffold version is stored in `.claude/.scaffold-meta.json`:

```bash
cat .claude/.scaffold-meta.json
```

Key fields:

| Field | Meaning |
|-------|---------|
| `version` | The scaffold version used to generate these files |
| `generated_at` | Timestamp of the original scaffold run |
| `updated_at` | Timestamp of the last update run (if any) |
| `checksums` | Per-file hashes used to detect local modifications |

---

## Checking for breaking changes

Before updating, read `CHANGELOG.md` in the dev-forge repo:

```bash
cat /path/to/dev-forge/CHANGELOG.md
```

Look for `### Breaking` or `### Changed` sections under the target version. Common breaking changes include:

- Hook script renames (update `settings.json` references manually)
- Frontmatter field additions to agents or skills (existing files continue to work but miss new features)
- `plugin-profiles.json` schema changes (the updater will prompt for these)

When in doubt, let the updater show you the diff before accepting any changes.

---

## See also

- [Extending dev-forge](./extending.md)
- [Uninstalling](./uninstalling.md)
- [Architecture internals](./architecture.md)
