#!/usr/bin/env bash
# PostToolUse hook: warn on accessibility anti-patterns in edited UI component files.
# This hook WARNS only (always exits 0) to avoid false-positive blocking.

set -euo pipefail

INPUT=$(cat)

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")

if [ -z "$FILE" ]; then
  exit 0
fi

# Self-gating: only check UI component file types
case "$FILE" in
  *.tsx|*.jsx|*.vue|*.svelte|*.html)
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

# Check 1: Raw hex colors not inside CSS custom properties
HEX_HITS=$(grep -nE '#[0-9a-fA-F]{3,8}' "$FILE" | grep -v 'var(--' | grep -v '^\s*//' | grep -v '\.stories\.' || true)
if [ -n "$HEX_HITS" ]; then
  echo "WARN: [A11y] Raw hex colors found — use CSS custom properties or design tokens:" >&2
  echo "$HEX_HITS" | head -3 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 2: Interactive elements without aria-label or aria-labelledby
BUTTONS=$(grep -nE '<button|<input|<select' "$FILE" | grep -v 'aria-label' | grep -v 'aria-labelledby' | grep -v '^\s*//' || true)
if [ -n "$BUTTONS" ]; then
  echo "WARN: [A11y] Interactive elements without aria-label or aria-labelledby:" >&2
  echo "$BUTTONS" | head -3 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 3: outline: none without accessible focus replacement
OUTLINE=$(grep -nE 'outline:\s*(none|0)' "$FILE" | grep -v 'ring' | grep -v 'focus-visible' | grep -v '^\s*//' || true)
if [ -n "$OUTLINE" ]; then
  echo "WARN: [A11y] outline:none without focus replacement (ring/focus-visible):" >&2
  echo "$OUTLINE" | head -3 >&2
  WARNINGS=$((WARNINGS + 1))
fi

# Check 4: Framer Motion usage without reduced-motion support
HAS_FRAMER=$(grep -c 'framer-motion' "$FILE" || true)
if [ "$HAS_FRAMER" -gt 0 ]; then
  HAS_REDUCED_MOTION=$(grep -cE 'useReducedMotion|prefers-reduced-motion|reducedMotion' "$FILE" || true)
  if [ "$HAS_REDUCED_MOTION" -eq 0 ]; then
    echo "WARN: [A11y] framer-motion imported without reduced-motion support:" >&2
    echo "  Add useReducedMotion() or prefers-reduced-motion media query" >&2
    WARNINGS=$((WARNINGS + 1))
  fi
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "Accessibility check: ${WARNINGS} warning(s) in $FILE" >&2
fi

# Always exit 0 — warnings only, never block
exit 0
