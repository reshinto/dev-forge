#!/usr/bin/env bash
# PostToolUse hook: warn on strict TypeScript anti-patterns in edited files.
# This hook WARNS only (always exits 0) to avoid false-positive blocking.

set -euo pipefail

INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

if [ -z "$FILE" ]; then
  exit 0
fi

# Self-gating: only check .ts and .tsx files
case "$FILE" in
  *.ts|*.tsx)
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

# Check 1: any type usage (exclude comments and type imports)
ANY_HITS=$(grep -nE ':\s*any\b|<any>|as any\b' "$FILE" | grep -v '^\s*//' | grep -v '@ts-' || true)
if [ -n "$ANY_HITS" ]; then
  echo "WARN: [TypeScript] 'any' type usage found — use 'unknown' with narrowing:" >&2
  echo "$ANY_HITS" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 2: @ts-ignore or @ts-expect-error without explanation
TS_IGNORE=$(grep -nE '@ts-ignore\s*$|@ts-expect-error\s*$' "$FILE" || true)
if [ -n "$TS_IGNORE" ]; then
  echo "WARN: [TypeScript] @ts-ignore/@ts-expect-error without explanation:" >&2
  echo "$TS_IGNORE" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 3: type assertions (exclude as const, as unknown)
ASSERTIONS=$(grep -nE '\bas [A-Z][a-zA-Z]+' "$FILE" | grep -v 'as const' | grep -v 'as unknown' | grep -v '^\s*//' || true)
if [ -n "$ASSERTIONS" ]; then
  echo "WARN: [TypeScript] Type assertions found — prefer type guards:" >&2
  echo "$ASSERTIONS" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 4: number[][] instead of explicit tuple types
NESTED_ARRAYS=$(grep -nE 'number\[\]\[\]' "$FILE" || true)
if [ -n "$NESTED_ARRAYS" ]; then
  echo "WARN: [TypeScript] number[][] found — use explicit tuple types (e.g., [number, number][]) for coordinate/pair arrays:" >&2
  echo "$NESTED_ARRAYS" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "TypeScript check: ${WARNINGS} warning(s) in $FILE" >&2
fi

# Always exit 0 — warnings only, never block
exit 0
