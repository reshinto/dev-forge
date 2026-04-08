#!/usr/bin/env bash
# PostToolUse hook: warn on Java/Kotlin anti-patterns in edited files.
# WARNS only (always exits 0).

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

if [ -z "$FILE" ]; then
  exit 0
fi

# Self-gating: only check .java and .kt files
case "$FILE" in
  *.java|*.kt)
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
SINGLE_CHARS=$(grep -nE '\b(int|long|double|float|boolean|char|String|var)\s+[a-z]\s*[=;,)]' "$FILE" | grep -v '^\s*//' || true)
if [ -n "$SINGLE_CHARS" ]; then
  echo "WARN: [Java/Kotlin] Single-character variable names — use meaningful names:" >&2
  echo "$SINGLE_CHARS" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 2: Raw types (e.g., List instead of List<Integer>)
RAW_TYPES=$(grep -nE '\b(List|Map|Set|Queue|Stack|ArrayList|HashMap|HashSet)\s+\w' "$FILE" | grep -v '<' | grep -v '^\s*//' || true)
if [ -n "$RAW_TYPES" ]; then
  echo "WARN: [Java/Kotlin] Raw types found — use generics (e.g., List<Integer>):" >&2
  echo "$RAW_TYPES" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 3: @SuppressWarnings without justification comment
SUPPRESS=$(grep -nE '@SuppressWarnings' "$FILE" | grep -v '//' || true)
if [ -n "$SUPPRESS" ]; then
  echo "WARN: [Java/Kotlin] @SuppressWarnings — add justification comment:" >&2
  echo "$SUPPRESS" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 4: Catching generic Exception
CATCH_GENERIC=$(grep -nE 'catch\s*\(\s*Exception\s' "$FILE" || true)
if [ -n "$CATCH_GENERIC" ]; then
  echo "WARN: [Java/Kotlin] Catching generic Exception — use specific exception type:" >&2
  echo "$CATCH_GENERIC" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "Java/Kotlin check: ${WARNINGS} warning(s) in $FILE" >&2
fi

exit 0
