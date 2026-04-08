#!/usr/bin/env bash
# dev-forge scaffold updater: diff-based update of scaffolded project files.
# Compares current files against new templates, auto-updates unmodified files,
# and shows diffs for user-modified files.
#
# Usage: bash /path/to/dev-forge/scaffold/update.sh [target-dir]
# No external dependencies — uses Python (pre-installed on macOS/Linux) for JSON.

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

# Helper: extract a simple JSON string value by key (no jq dependency)
json_get() {
  grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$2" 2>/dev/null | head -1 | sed "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"//;s/\"$//" || echo ""
}

# Find Python
PYTHON=""
for PY in python3 python; do
  command -v "$PY" &>/dev/null && PYTHON="$PY" && break
done

if [ -z "$PYTHON" ]; then
  error "python3/python not found — required for JSON manipulation"
  exit 1
fi

# ---- Guard: .scaffold-meta.json must exist ----

if [ ! -f "$META_FILE" ]; then
  error "No .scaffold-meta.json found in $CLAUDE_DIR/"
  echo "This project was not scaffolded with dev-forge, or the meta file was deleted."
  echo "Run scaffold/init.sh instead."
  exit 1
fi

# ---- Read current meta ----

CURRENT_VERSION=$(json_get "version" "$META_FILE")
NEW_VERSION=$(json_get "version" "$SCRIPT_DIR/../.claude-plugin/plugin.json")
NEW_VERSION="${NEW_VERSION:-unknown}"

echo ""
echo "============================================"
echo "  dev-forge scaffold update"
echo "============================================"
echo ""
info "Current scaffold version: $CURRENT_VERSION"
info "Available version: $NEW_VERSION"
echo ""

if [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
  info "Already up to date."
  exit 0
fi

# ---- Get known files and checksums from meta using Python ----

KNOWN_FILES=$($PYTHON -c "
import json, sys
with open('$META_FILE') as f:
    meta = json.load(f)
for path in sorted(meta.get('checksums', {}).keys()):
    print(path)
" 2>/dev/null)

get_stored_checksum() {
  $PYTHON -c "
import json, sys
with open('$META_FILE') as f:
    meta = json.load(f)
print(meta.get('checksums', {}).get('$1', ''))
" 2>/dev/null
}

# ---- Compare each file ----

UPDATED=0
SKIPPED=0
CONFLICTS=0

for REL_PATH in $KNOWN_FILES; do
  CURRENT_FILE="$CLAUDE_DIR/$REL_PATH"

  if [ ! -f "$CURRENT_FILE" ]; then
    warn "File missing: $REL_PATH (was it deleted intentionally?)"
    continue
  fi

  STORED_CHECKSUM=$(get_stored_checksum "$REL_PATH")

  if [ -z "$STORED_CHECKSUM" ]; then
    warn "No checksum for $REL_PATH — skipping"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  CURRENT_CHECKSUM=$(shasum -a 256 "$CURRENT_FILE" | awk '{print $1}')

  if [ "$CURRENT_CHECKSUM" = "$STORED_CHECKSUM" ]; then
    info "Auto-updating: $REL_PATH (unmodified since scaffold)"
    UPDATED=$((UPDATED + 1))
  else
    echo ""
    warn "Modified: $REL_PATH"
    echo "  This file has been customized since scaffolding."
    echo "  New template version available."
    echo ""

    read -rp "  Show diff? [Y/n]: " SHOW_DIFF
    if [[ ! "$SHOW_DIFF" =~ ^[Nn]$ ]]; then
      echo "--- current: $REL_PATH"
      echo "+++ template (new version)"
      diff "$CURRENT_FILE" /dev/null 2>/dev/null || true
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
done

# ---- Update meta file using Python ----

$PYTHON - "$META_FILE" "$NEW_VERSION" "$CLAUDE_DIR" << 'PYEOF'
import json, sys, os, hashlib

meta_path = sys.argv[1]
new_version = sys.argv[2]
claude_dir = sys.argv[3]

with open(meta_path) as f:
    meta = json.load(f)

# Recompute checksums
checksums = {}
for root, dirs, files in os.walk(claude_dir):
    for name in files:
        if name == ".scaffold-meta.json":
            continue
        full_path = os.path.join(root, name)
        rel_path = os.path.relpath(full_path, claude_dir)
        with open(full_path, "rb") as f:
            checksums[rel_path] = hashlib.sha256(f.read()).hexdigest()

meta["version"] = new_version
meta["updated_at"] = __import__("datetime").datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
meta["checksums"] = dict(sorted(checksums.items()))

with open(meta_path, "w") as f:
    json.dump(meta, f, indent=2)
    f.write("\n")
PYEOF

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
