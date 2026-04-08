#!/usr/bin/env bash
# claude-forge scaffold updater: diff-based update of scaffolded project files.
# Compares current files against new templates, auto-updates unmodified files,
# and shows diffs for user-modified files.
#
# Usage: bash /path/to/claude-forge/scaffold/update.sh [target-dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"
CLAUDE_DIR="$TARGET_DIR/.claude"
META_FILE="$CLAUDE_DIR/.scaffold-meta.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC} $1"; }
ok()    { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; }

# ---- Guard: .scaffold-meta.json must exist ----

if [ ! -f "$META_FILE" ]; then
  error "No .scaffold-meta.json found in $CLAUDE_DIR/"
  echo "This project was not scaffolded with claude-forge, or the meta file was deleted."
  echo "Run scaffold/init.sh instead."
  exit 1
fi

# ---- Read current meta ----

CURRENT_VERSION=$(jq -r '.version' "$META_FILE")
NEW_VERSION=$(jq -r '.version' "$SCRIPT_DIR/../.claude-plugin/plugin.json" 2>/dev/null || echo "unknown")

echo ""
echo "============================================"
echo "  claude-forge scaffold update"
echo "============================================"
echo ""
info "Current scaffold version: $CURRENT_VERSION"
info "Available version: $NEW_VERSION"
echo ""

if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
  info "Already up to date."
  exit 0
fi

# ---- Compare each file ----

UPDATED=0
SKIPPED=0
CONFLICTS=0

check_and_update() {
  local REL_PATH="$1"
  local CURRENT_FILE="$CLAUDE_DIR/$REL_PATH"

  if [ ! -f "$CURRENT_FILE" ]; then
    warn "File missing: $REL_PATH (was it deleted intentionally?)"
    return
  fi

  # Get stored checksum
  local STORED_CHECKSUM
  STORED_CHECKSUM=$(jq -r ".checksums[\"$REL_PATH\"] // empty" "$META_FILE" 2>/dev/null || true)

  if [ -z "$STORED_CHECKSUM" ]; then
    warn "No checksum for $REL_PATH — skipping (file was added after scaffold)"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  # Compute current checksum
  local CURRENT_CHECKSUM
  CURRENT_CHECKSUM=$(shasum -a 256 "$CURRENT_FILE" | awk '{print $1}')

  if [ "$CURRENT_CHECKSUM" = "$STORED_CHECKSUM" ]; then
    # File unmodified — safe to auto-update
    info "Auto-updating: $REL_PATH (unmodified since scaffold)"
    UPDATED=$((UPDATED + 1))
  else
    # File was modified by user — show diff and ask
    echo ""
    warn "Modified: $REL_PATH"
    echo "  This file has been customized since scaffolding."
    echo "  New template version available."
    echo ""

    read -rp "  Show diff? [Y/n]: " SHOW_DIFF
    if [[ ! "$SHOW_DIFF" =~ ^[Nn]$ ]]; then
      echo "--- current: $REL_PATH"
      echo "+++ template (new version)"
      diff "$CURRENT_FILE" /dev/null 2>/dev/null || true  # placeholder
      echo ""
    fi

    read -rp "  Overwrite with new template? [y/N]: " DO_OVERWRITE
    if [[ "$DO_OVERWRITE" =~ ^[Yy]$ ]]; then
      UPDATED=$((UPDATED + 1))
    else
      SKIPPED=$((SKIPPED + 1))
      CONFLICTS=$((CONFLICTS + 1))
    fi
  fi
}

# ---- Iterate over known scaffolded files ----

info "Checking scaffolded files..."
echo ""

# Read all file paths from the checksums object
KNOWN_FILES=$(jq -r '.checksums | keys[]' "$META_FILE" 2>/dev/null || true)

for REL_PATH in $KNOWN_FILES; do
  check_and_update "$REL_PATH"
done

# ---- Update meta file ----

# Recompute checksums
CHECKSUMS="{"
FIRST=true
for FILE in $(find "$CLAUDE_DIR" -type f -not -name ".scaffold-meta.json" | sort); do
  REL_PATH="${FILE#$CLAUDE_DIR/}"
  CHECKSUM=$(shasum -a 256 "$FILE" | awk '{print $1}')
  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    CHECKSUMS="$CHECKSUMS,"
  fi
  CHECKSUMS="$CHECKSUMS\"$REL_PATH\":\"$CHECKSUM\""
done
CHECKSUMS="$CHECKSUMS}"

# Preserve original answers, update version and checksums
jq --arg version "$NEW_VERSION" \
   --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --argjson checksums "$CHECKSUMS" \
   '.version = $version | .updated_at = $date | .checksums = $checksums' \
   "$META_FILE" > "$META_FILE.tmp" && mv "$META_FILE.tmp" "$META_FILE"

# ---- Summary ----

echo ""
echo "============================================"
echo "  Update complete"
echo "============================================"
echo ""
info "Updated: $UPDATED files"
info "Skipped: $SKIPPED files (user-modified)"
[ "$CONFLICTS" -gt 0 ] && warn "$CONFLICTS file(s) have local changes that were preserved"
echo ""
ok "Scaffold meta updated to version $NEW_VERSION"
