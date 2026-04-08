#!/usr/bin/env bash
# PostToolUse hook: block hardcoded delays in test and E2E files.
# Hardcoded delays degrade test performance and create flaky tests.
# Use element-based waits (waitFor, waitForSelector, waitForFunction) instead.

set -euo pipefail

# Self-gating: extract file path from tool input
FILE_PATH=$(echo "$CLAUDE_TOOL_INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')

# Only check test and E2E files — exit immediately for everything else
case "$FILE_PATH" in
  *test*|*spec*|*e2e*|*.test.*|*.spec.*)
    # Proceed with check below
    ;;
  *)
    exit 0
    ;;
esac

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Banned patterns: waitForTimeout, new Promise + setTimeout, sleep()
MATCHES=$(grep -nE 'waitForTimeout|\.sleep\(|await new Promise.*setTimeout' "$FILE_PATH" || true)
if [ -n "$MATCHES" ]; then
  echo "BLOCKED: $FILE_PATH contains hardcoded delays:" >&2
  echo "$MATCHES" >&2
  echo "" >&2
  echo "Use element-based waits instead:" >&2
  echo "  waitFor()           — wait for element condition" >&2
  echo "  waitForSelector()   — wait for DOM element" >&2
  echo "  waitForFunction()   — wait for JS condition" >&2
  echo "Never use waitForTimeout, sleep, or setTimeout-based delays." >&2
  exit 1
fi

exit 0
