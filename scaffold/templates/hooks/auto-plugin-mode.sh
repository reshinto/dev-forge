#!/usr/bin/env bash
# SessionStart + branch creation hook: auto-switch plugins based on git branch prefix.
# Reads plugin-profiles.json and updates settings.local.json enabledPlugins.
#
# CRITICAL: Only manages plugins listed in plugin-profiles.json. Any plugins already
# present in settings.local.json that are NOT in plugin-profiles.json are preserved
# (merged, not overwritten). This ensures the forge plugin itself is never disabled.
#
# Uses jq for JSON manipulation. Always exits 0 — never blocks session start.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PROFILES="$PROJECT_DIR/.claude/hooks/plugin-profiles.json"
SETTINGS="$PROJECT_DIR/.claude/settings.local.json"

# Guard: profiles must exist; settings.local.json is created if missing
if [ ! -f "$PROFILES" ]; then
  echo "WARN: plugin-profiles.json missing — plugin auto-switching disabled" >&2
  exit 0
fi

if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Guard: jq must be available
if ! command -v jq &>/dev/null; then
  echo "WARN: jq not found — plugin auto-switching disabled" >&2
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

# Build the list of managed plugins (all plugins in profiles)
MANAGED_PLUGINS=$(jq -r '([.core[], (.branch_modes | to_entries[].value[])] | unique | .[])' "$PROFILES" 2>/dev/null)

if [ -z "$MANAGED_PLUGINS" ]; then
  echo "WARN: No plugins found in plugin-profiles.json" >&2
  exit 0
fi

# Build the list of plugins to enable (core + branch-matched)
CORE_PLUGINS=$(jq -r '.core[]' "$PROFILES" 2>/dev/null)
BRANCH_PLUGINS=""
while IFS= read -r PREFIX; do
  if [[ "$BRANCH" == "$PREFIX"* ]]; then
    MATCHED=$(jq -r --arg prefix "$PREFIX" '.branch_modes[$prefix][]' "$PROFILES" 2>/dev/null)
    BRANCH_PLUGINS="$BRANCH_PLUGINS"$'\n'"$MATCHED"
  fi
done < <(jq -r '.branch_modes | keys[]' "$PROFILES" 2>/dev/null)

ENABLED_PLUGINS=$(echo -e "$CORE_PLUGINS\n$BRANCH_PLUGINS" | sort -u | grep -v '^$')

# Build the new enabledPlugins object using jq:
# 1. Start with existing settings
# 2. Remove managed plugins from existing enabledPlugins (preserve unmanaged)
# 3. Add all managed plugins as false
# 4. Enable core + branch-matched plugins
MANAGED_JSON=$(echo "$MANAGED_PLUGINS" | jq -Rn '[inputs] | map({(.): false}) | add // {}')
ENABLED_JSON=$(echo "$ENABLED_PLUGINS" | jq -Rn '[inputs | select(length > 0)] | map({(.): true}) | add // {}')

# Merge: existing unmanaged + managed (false) + enabled (true)
NEW_SETTINGS=$(jq --argjson managed "$MANAGED_JSON" --argjson enabled "$ENABLED_JSON" '
  # Get existing enabledPlugins, default to {}
  (.enabledPlugins // {}) as $existing |
  # Filter out managed plugins from existing (keep unmanaged)
  ($existing | to_entries | map(select(.key as $k | ($managed | has($k)) | not)) | from_entries) as $unmanaged |
  # Merge: unmanaged + managed defaults + enabled overrides
  .enabledPlugins = ($unmanaged + $managed + $enabled)
' "$SETTINGS" 2>/dev/null)

if [ -z "$NEW_SETTINGS" ]; then
  echo "WARN: plugin auto-switch failed — jq merge error" >&2
  exit 0
fi

# Check if anything changed
OLD_ENABLED=$(jq -r '.enabledPlugins // {}' "$SETTINGS" 2>/dev/null | jq -S '.')
NEW_ENABLED=$(echo "$NEW_SETTINGS" | jq -S '.enabledPlugins // {}')

# Atomic write: temp file + rename
TMP_FILE="$SETTINGS.tmp.$$"
echo "$NEW_SETTINGS" | jq '.' > "$TMP_FILE"
mv "$TMP_FILE" "$SETTINGS"

ENABLED_COUNT=$(echo "$NEW_SETTINGS" | jq '[.enabledPlugins | to_entries[] | select(.value == true)] | length')
echo "Plugin mode: branch \"$BRANCH\" — enabled $ENABLED_COUNT plugins"

if [ "$OLD_ENABLED" != "$NEW_ENABLED" ]; then
  echo "Plugins changed — restart session (new chat) for changes to take effect"
fi

exit 0
