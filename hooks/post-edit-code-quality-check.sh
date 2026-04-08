#!/usr/bin/env bash
# PostToolUse hook: warn on language-specific anti-patterns in edited files.
# Dispatches checks based on file extension. WARNS only (always exits 0).
#
# Extensible: add new language checks by adding a new case block below.
# Each check function follows the pattern: check_<language>() { ... }

set -euo pipefail

INPUT=$(cat)
# Extract file_path from JSON without jq — pure grep/sed
FILE=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//' || echo "")

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

WARNINGS=0

warn() {
  echo "WARN: [$1] $2:" >&2
  echo "$3" | head -5 >&2
  WARNINGS=$((WARNINGS + 1))
}

# --- Shared checks (all languages) ---

check_shared() {
  # Single-character variable names (best-effort, language-agnostic)
  local SINGLE_CHARS
  SINGLE_CHARS=$(grep -nE '\b[a-z]\s*=' "$FILE" | grep -vE '^\s*(#|//|\*|--)|_\s*=|in\s' | head -5 || true)
  if [ -n "$SINGLE_CHARS" ]; then
    warn "$LANG" "Single-character variable names — use meaningful names" "$SINGLE_CHARS"
  fi
}

# --- TypeScript / JavaScript ---

check_typescript() {
  local HITS

  # any type usage
  HITS=$(grep -nE ':\s*any\b|<any>|as any\b' "$FILE" | grep -v '^\s*//' | grep -v '@ts-' || true)
  [ -n "$HITS" ] && warn "TypeScript" "'any' type usage — use 'unknown' with narrowing" "$HITS"

  # @ts-ignore without explanation
  HITS=$(grep -nE '@ts-ignore\s*$|@ts-expect-error\s*$' "$FILE" || true)
  [ -n "$HITS" ] && warn "TypeScript" "Compiler directive without explanation" "$HITS"

  # Type assertions (exclude as const, as unknown)
  HITS=$(grep -nE '\bas [A-Z][a-zA-Z]+' "$FILE" | grep -v 'as const' | grep -v 'as unknown' | grep -v '^\s*//' || true)
  [ -n "$HITS" ] && warn "TypeScript" "Type assertions — prefer type guards" "$HITS"

  # number[][] instead of tuple types
  HITS=$(grep -nE 'number\[\]\[\]' "$FILE" || true)
  [ -n "$HITS" ] && warn "TypeScript" "number[][] — use explicit tuple types for coordinate/pair arrays" "$HITS"
}

# --- Python ---

check_python() {
  local HITS

  # Missing type hints on function parameters
  HITS=$(grep -nE '^\s*def\s+\w+\([^)]*\b\w+\s*[,)]' "$FILE" | grep -v ':' || true)
  [ -n "$HITS" ] && warn "Python" "Function parameters without type hints" "$HITS"

  # Bare except
  HITS=$(grep -nE '^\s*except\s*:' "$FILE" || true)
  [ -n "$HITS" ] && warn "Python" "Bare 'except:' — specify exception type" "$HITS"

  # type: ignore without explanation
  HITS=$(grep -nE '#\s*type:\s*ignore\s*$' "$FILE" || true)
  [ -n "$HITS" ] && warn "Python" "type: ignore without explanation" "$HITS"
}

# --- Java / Kotlin ---

check_java() {
  local HITS

  # Raw types
  HITS=$(grep -nE '\b(List|Map|Set|Queue|Stack|ArrayList|HashMap|HashSet)\s+\w' "$FILE" | grep -v '<' | grep -v '^\s*//' || true)
  [ -n "$HITS" ] && warn "Java/Kotlin" "Raw types — use generics" "$HITS"

  # @SuppressWarnings without comment
  HITS=$(grep -nE '@SuppressWarnings' "$FILE" | grep -v '//' || true)
  [ -n "$HITS" ] && warn "Java/Kotlin" "@SuppressWarnings — add justification comment" "$HITS"

  # Catching generic Exception
  HITS=$(grep -nE 'catch\s*\(\s*Exception\s' "$FILE" || true)
  [ -n "$HITS" ] && warn "Java/Kotlin" "Catching generic Exception — use specific type" "$HITS"
}

# --- Go ---

check_go() {
  local HITS

  # Blank identifier suppressing errors
  HITS=$(grep -nE '^\s*_\s*,?\s*:?=' "$FILE" | grep -v '^\s*//' || true)
  [ -n "$HITS" ] && warn "Go" "Blank identifier may suppress errors — verify intentional" "$HITS"

  # Naked return in long functions
  HITS=$(grep -nE '^\s*return\s*$' "$FILE" || true)
  [ -n "$HITS" ] && warn "Go" "Naked return — ensure function is short enough for clarity" "$HITS"
}

# --- Rust ---

check_rust() {
  local HITS

  # unwrap() usage
  HITS=$(grep -nE '\.unwrap\(\)' "$FILE" | grep -v '^\s*//' || true)
  [ -n "$HITS" ] && warn "Rust" ".unwrap() — use ? operator or handle the error" "$HITS"

  # allow(unused) without explanation
  HITS=$(grep -nE '#\[allow\(' "$FILE" | grep -v '//' || true)
  [ -n "$HITS" ] && warn "Rust" "#[allow(...)] — add justification comment" "$HITS"
}

# --- C / C++ ---

check_cpp() {
  local HITS

  # Raw pointer usage without smart pointer
  HITS=$(grep -nE '\b\w+\s*\*\s*\w+\s*=\s*new\b' "$FILE" | grep -v '^\s*//' || true)
  [ -n "$HITS" ] && warn "C/C++" "Raw new — prefer smart pointers (unique_ptr, shared_ptr)" "$HITS"

  # C-style casts
  HITS=$(grep -nE '\(\s*(int|char|float|double|long|void\s*\*)\s*\)' "$FILE" | grep -v '^\s*//' || true)
  [ -n "$HITS" ] && warn "C/C++" "C-style cast — use static_cast/reinterpret_cast" "$HITS"

  # using namespace std in headers
  case "$FILE" in
    *.h|*.hpp|*.hxx)
      HITS=$(grep -nE '^\s*using\s+namespace\s+std' "$FILE" || true)
      [ -n "$HITS" ] && warn "C/C++" "'using namespace std' in header — pollutes global namespace" "$HITS"
      ;;
  esac

  # Catching by value instead of reference
  HITS=$(grep -nE 'catch\s*\(\s*\w+\s+\w+\s*\)' "$FILE" | grep -v '&' | grep -v '^\s*//' || true)
  [ -n "$HITS" ] && warn "C/C++" "Catch by value — catch by const reference instead" "$HITS"
}

# --- Dispatch by file extension ---

LANG=""
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    LANG="TypeScript/JS"
    check_typescript
    ;;
  *.py)
    LANG="Python"
    check_shared
    check_python
    ;;
  *.java|*.kt)
    LANG="Java/Kotlin"
    check_java
    ;;
  *.go)
    LANG="Go"
    check_go
    ;;
  *.rs)
    LANG="Rust"
    check_rust
    ;;
  *.c|*.cpp|*.cc|*.cxx|*.h|*.hpp|*.hxx)
    LANG="C/C++"
    check_cpp
    ;;
  *)
    # Unsupported language — skip silently
    exit 0
    ;;
esac

if [ "$WARNINGS" -gt 0 ]; then
  echo "Code quality check: ${WARNINGS} warning(s) in $FILE" >&2
fi

# Always exit 0 — warnings only, never block
exit 0
