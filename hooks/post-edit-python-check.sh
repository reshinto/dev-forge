#!/usr/bin/env bash
# PostToolUse hook: warn on Python anti-patterns in edited files.
# WARNS only (always exits 0).

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

if [ -z "$FILE" ]; then
  exit 0
fi

# Self-gating: only check .py files
case "$FILE" in
  *.py)
    # Proceed with check
    ;;
  *)
    exit 0
    ;;
esac

if [ ! -f "$FILE" ]; then
  exit 0
fi

WARNINGS=0

# Check 1: Single-character variable names
SINGLE_CHARS=$(grep -nE '\b[a-z]\s*=' "$FILE" | grep -vE '^\s*#|_\s*=' || true)
if [ -n "$SINGLE_CHARS" ]; then
  echo "WARN: [Python] Single-character variable names — use meaningful names:" >&2
  echo "$SINGLE_CHARS" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 2: Missing type hints on function parameters
NO_HINTS=$(grep -nE '^\s*def\s+\w+\([^)]*\b\w+\s*[,)]' "$FILE" | grep -v ':' | grep -v '@step' || true)
if [ -n "$NO_HINTS" ]; then
  echo "WARN: [Python] Function parameters without type hints:" >&2
  echo "$NO_HINTS" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 3: Bare except (catches too broadly)
BARE_EXCEPT=$(grep -nE '^\s*except\s*:' "$FILE" || true)
if [ -n "$BARE_EXCEPT" ]; then
  echo "WARN: [Python] Bare 'except:' — specify exception type:" >&2
  echo "$BARE_EXCEPT" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 4: type: ignore without explanation
TYPE_IGNORE=$(grep -nE '#\s*type:\s*ignore\s*$' "$FILE" || true)
if [ -n "$TYPE_IGNORE" ]; then
  echo "WARN: [Python] type: ignore without explanation:" >&2
  echo "$TYPE_IGNORE" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "Python check: ${WARNINGS} warning(s) in $FILE" >&2
fi

exit 0
