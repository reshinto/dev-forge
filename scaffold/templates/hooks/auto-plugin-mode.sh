#!/usr/bin/env bash
# SessionStart + branch creation hook: auto-switch plugins based on git branch prefix.
# Reads plugin-profiles.json and updates settings.local.json enabledPlugins.
#
# CRITICAL: Only manages plugins listed in plugin-profiles.json. Any plugins already
# present in settings.local.json that are NOT in plugin-profiles.json are preserved
# (merged, not overwritten). This ensures the forge plugin itself is never disabled.
#
# Uses Node.js for JSON manipulation (no jq dependency).
# Always exits 0 — never blocks session start.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PROFILES="$PROJECT_DIR/.claude/hooks/plugin-profiles.json"
SETTINGS="$PROJECT_DIR/.claude/settings.local.json"

# Guard: profiles must exist; settings.local.json is created if missing
if [ ! -f "$PROFILES" ]; then
  echo "WARN: plugin-profiles.json missing — plugin auto-switching disabled" >&2
  exit 0
fi

# Create settings.local.json if it doesn't exist
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Guard: Node.js must be available
if ! command -v node &>/dev/null; then
  echo "WARN: node not found — plugin auto-switching disabled" >&2
  exit 0
fi

# Get current branch (handle detached HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
if [ -z "$BRANCH" ] || [ "$BRANCH" = "HEAD" ]; then
  BRANCH="main"
fi

# Allow override from argument (used by branch creation hook)
if [ -n "${1:-}" ]; then
  BRANCH="$1"
fi

# Use Node.js to update settings.local.json atomically.
# Merges managed plugins with any pre-existing unmanaged plugins in the file.
node -e "
const fs = require('fs');

const profilesPath = process.argv[1];
const settingsPath = process.argv[2];
const branch = process.argv[3];

try {
  const profiles = JSON.parse(fs.readFileSync(profilesPath, 'utf8'));
  const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));

  // Collect all plugin names managed by this profiles file
  const managedPlugins = new Set([
    ...profiles.core,
    ...Object.values(profiles.branch_modes).flat()
  ]);

  // Start with existing enabledPlugins, preserving any unmanaged entries
  // (e.g. the forge plugin itself installed via settings.local.json)
  const existing = settings.enabledPlugins || {};
  const merged = {};

  // Copy over any plugins NOT in our managed set (preserve unmanaged plugins)
  for (const [pluginId, enabled] of Object.entries(existing)) {
    if (!managedPlugins.has(pluginId)) {
      merged[pluginId] = enabled;
    }
  }

  // Set all managed plugins to false initially
  for (const plugin of managedPlugins) merged[plugin] = false;

  // Enable core plugins
  for (const plugin of profiles.core) merged[plugin] = true;

  // Enable branch-matched plugins
  for (const [prefix, plugins] of Object.entries(profiles.branch_modes)) {
    if (branch.startsWith(prefix)) {
      for (const plugin of plugins) merged[plugin] = true;
    }
  }

  // Check if anything changed (only compare managed plugin keys for change detection)
  const oldManaged = {};
  for (const plugin of managedPlugins) oldManaged[plugin] = (existing[plugin] ?? false);
  const newManaged = {};
  for (const plugin of managedPlugins) newManaged[plugin] = merged[plugin];

  const sortedKeys = [...managedPlugins].sort();
  const oldJson = JSON.stringify(oldManaged, sortedKeys);
  const newJson = JSON.stringify(newManaged, sortedKeys);
  const changed = oldJson !== newJson;

  settings.enabledPlugins = merged;

  // Atomic write: temp file + rename
  const tmpPath = settingsPath + '.tmp.' + process.pid;
  fs.writeFileSync(tmpPath, JSON.stringify(settings, null, 2) + '\n');
  fs.renameSync(tmpPath, settingsPath);

  const enabledCount = Object.values(merged).filter(Boolean).length;
  console.log('Plugin mode: branch \"' + branch + '\" — enabled ' + enabledCount + ' plugins');
  if (changed) {
    console.log('Plugins changed — restart session (new chat) for changes to take effect');
  }
} catch (err) {
  console.log('WARN: plugin auto-switch failed: ' + err.message);
}
" "$PROFILES" "$SETTINGS" "$BRANCH" 2>&1

exit 0
