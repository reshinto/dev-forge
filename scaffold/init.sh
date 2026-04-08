#!/usr/bin/env bash
# claude-forge scaffold: Interactive project setup for .claude/ configuration.
# Generates CLAUDE.md, rules, hooks, and settings based on project type.
#
# Usage: bash /path/to/claude-forge/scaffold/init.sh [target-dir]
# If target-dir is omitted, uses the current directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
TARGET_DIR="${1:-$(pwd)}"
CLAUDE_DIR="$TARGET_DIR/.claude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[info]${NC} $1"; }
ok()    { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; }

# ---- Guard: don't overwrite existing .claude/ ----

if [ -d "$CLAUDE_DIR" ]; then
  warn ".claude/ directory already exists at $TARGET_DIR"
  read -rp "Overwrite? This will replace existing config. [y/N]: " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    info "Aborted. Use scaffold/update.sh to update an existing setup."
    exit 0
  fi
fi

echo ""
echo "============================================"
echo "  claude-forge scaffold"
echo "  Project setup for Claude Code"
echo "============================================"
echo ""

# ---- Stage 1: Project Identity ----

info "Stage 1: Project Identity"
echo ""

# Auto-detect project name
AUTO_NAME=""
if [ -f "$TARGET_DIR/package.json" ]; then
  AUTO_NAME=$(jq -r '.name // empty' "$TARGET_DIR/package.json" 2>/dev/null || true)
elif [ -f "$TARGET_DIR/pyproject.toml" ]; then
  AUTO_NAME=$(grep -m1 '^name' "$TARGET_DIR/pyproject.toml" | sed 's/.*= *"//;s/"//' || true)
elif [ -f "$TARGET_DIR/Cargo.toml" ]; then
  AUTO_NAME=$(grep -m1 '^name' "$TARGET_DIR/Cargo.toml" | sed 's/.*= *"//;s/"//' || true)
elif [ -f "$TARGET_DIR/go.mod" ]; then
  AUTO_NAME=$(head -1 "$TARGET_DIR/go.mod" | awk '{print $2}' | sed 's|.*/||' || true)
fi
AUTO_NAME="${AUTO_NAME:-$(basename "$TARGET_DIR")}"

read -rp "Project name [$AUTO_NAME]: " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-$AUTO_NAME}"

read -rp "One-line description: " PROJECT_DESCRIPTION

echo ""
echo "Project type:"
echo "  1) Web Frontend (React, Vue, Svelte, etc.)"
echo "  2) Full-Stack Web (frontend + backend)"
echo "  3) Backend API / Service"
echo "  4) CLI Tool"
echo "  5) Library / Package"
echo "  6) Other"
read -rp "Select [1-6]: " PROJECT_TYPE_NUM

HAS_FRONTEND=false
HAS_BACKEND=false
case "$PROJECT_TYPE_NUM" in
  1) PROJECT_TYPE="frontend"; HAS_FRONTEND=true ;;
  2) PROJECT_TYPE="fullstack"; HAS_FRONTEND=true; HAS_BACKEND=true ;;
  3) PROJECT_TYPE="backend"; HAS_BACKEND=true ;;
  4) PROJECT_TYPE="cli" ;;
  5) PROJECT_TYPE="library" ;;
  *) PROJECT_TYPE="other" ;;
esac

# ---- Stage 2: Language & Runtime ----

echo ""
info "Stage 2: Language & Runtime"
echo ""

# Auto-detect primary language
AUTO_LANG=""
if [ -f "$TARGET_DIR/tsconfig.json" ] || [ -f "$TARGET_DIR/tsconfig.base.json" ]; then
  AUTO_LANG="TypeScript"
elif [ -f "$TARGET_DIR/package.json" ]; then
  AUTO_LANG="JavaScript"
elif [ -f "$TARGET_DIR/pyproject.toml" ] || [ -f "$TARGET_DIR/setup.py" ] || [ -f "$TARGET_DIR/requirements.txt" ]; then
  AUTO_LANG="Python"
elif [ -f "$TARGET_DIR/go.mod" ]; then
  AUTO_LANG="Go"
elif [ -f "$TARGET_DIR/Cargo.toml" ]; then
  AUTO_LANG="Rust"
elif [ -f "$TARGET_DIR/pom.xml" ] || [ -f "$TARGET_DIR/build.gradle" ] || [ -f "$TARGET_DIR/build.gradle.kts" ]; then
  AUTO_LANG="Java/Kotlin"
elif ls "$TARGET_DIR"/*.cpp "$TARGET_DIR"/src/*.cpp "$TARGET_DIR"/CMakeLists.txt 2>/dev/null | head -1 > /dev/null 2>&1; then
  AUTO_LANG="C/C++"
fi

echo "Primary language:"
echo "  1) TypeScript"
echo "  2) JavaScript"
echo "  3) Python"
echo "  4) Go"
echo "  5) Rust"
echo "  6) Java/Kotlin"
echo "  7) C/C++"
echo "  8) Other"
if [ -n "$AUTO_LANG" ]; then
  echo "  (auto-detected: $AUTO_LANG)"
fi
read -rp "Select [1-8]: " LANG_NUM

case "$LANG_NUM" in
  1) PRIMARY_LANGUAGE="TypeScript" ;;
  2) PRIMARY_LANGUAGE="JavaScript" ;;
  3) PRIMARY_LANGUAGE="Python" ;;
  4) PRIMARY_LANGUAGE="Go" ;;
  5) PRIMARY_LANGUAGE="Rust" ;;
  6) PRIMARY_LANGUAGE="Java/Kotlin" ;;
  7) PRIMARY_LANGUAGE="C/C++" ;;
  *) read -rp "Language name: " PRIMARY_LANGUAGE ;;
esac

# ---- Stage 3: Conditional Questions ----

echo ""
info "Stage 3: Project-Specific Configuration"
echo ""

TECH_STACK="$PRIMARY_LANGUAGE"
IMPORT_ALIAS="none"
STATE_MANAGEMENT="None"
CSS_FRAMEWORK="None"
INCLUDE_STORYBOOK=false
TEST_RUNNER=""
E2E_RUNNER="None"
COVERAGE_THRESHOLDS="80/75/80/80"
LINT_CMD=""
FORMAT_CMD=""
TYPECHECK_CMD=""
TEST_CMD=""
E2E_CMD=""
STORYBOOK_BUILD_CMD=""
INCLUDE_DOCKER=false
INCLUDE_UI_UX=false

# TypeScript-specific
if [[ "$PRIMARY_LANGUAGE" == "TypeScript" || "$PRIMARY_LANGUAGE" == "JavaScript" ]]; then
  read -rp "Import alias (@/, ~/, or none) [none]: " IMPORT_ALIAS
  IMPORT_ALIAS="${IMPORT_ALIAS:-none}"

  # Auto-detect commands from package.json
  if [ -f "$TARGET_DIR/package.json" ]; then
    LINT_CMD=$(jq -r '.scripts.lint // empty' "$TARGET_DIR/package.json" 2>/dev/null | head -1)
    [ -n "$LINT_CMD" ] && LINT_CMD="npm run lint"
    FORMAT_CMD=$(jq -r '.scripts.format // empty' "$TARGET_DIR/package.json" 2>/dev/null | head -1)
    [ -n "$FORMAT_CMD" ] && FORMAT_CMD="npm run format"
    TEST_CMD=$(jq -r '.scripts.test // empty' "$TARGET_DIR/package.json" 2>/dev/null | head -1)
    [ -n "$TEST_CMD" ] && TEST_CMD="npm run test"
    TYPECHECK_CMD="npx tsc --noEmit"
    E2E_CMD=$(jq -r '.scripts.e2e // .scripts["test:e2e"] // empty' "$TARGET_DIR/package.json" 2>/dev/null | head -1)
    [ -n "$E2E_CMD" ] && E2E_CMD="npm run e2e"
    STORYBOOK_BUILD_CMD=$(jq -r '.scripts["build-storybook"] // empty' "$TARGET_DIR/package.json" 2>/dev/null | head -1)
    [ -n "$STORYBOOK_BUILD_CMD" ] && STORYBOOK_BUILD_CMD="npm run build-storybook"
  fi
fi

# Frontend-specific
if [ "$HAS_FRONTEND" = true ]; then
  INCLUDE_UI_UX=true

  read -rp "CSS framework (Tailwind/CSS Modules/None) [None]: " CSS_FRAMEWORK
  CSS_FRAMEWORK="${CSS_FRAMEWORK:-None}"

  read -rp "State management (Zustand/Redux/Jotai/None) [None]: " STATE_MANAGEMENT
  STATE_MANAGEMENT="${STATE_MANAGEMENT:-None}"

  read -rp "Include Storybook? [y/N]: " SB_ANSWER
  [[ "$SB_ANSWER" =~ ^[Yy]$ ]] && INCLUDE_STORYBOOK=true

  if [ -z "$E2E_RUNNER" ] || [ "$E2E_RUNNER" = "None" ]; then
    read -rp "E2E runner (Playwright/Cypress/None) [None]: " E2E_RUNNER
    E2E_RUNNER="${E2E_RUNNER:-None}"
  fi

  [ "$STATE_MANAGEMENT" != "None" ] && TECH_STACK="$TECH_STACK + $STATE_MANAGEMENT"
  [ "$CSS_FRAMEWORK" != "None" ] && TECH_STACK="$TECH_STACK + $CSS_FRAMEWORK"
fi

# Python-specific
if [ "$PRIMARY_LANGUAGE" = "Python" ]; then
  LINT_CMD="${LINT_CMD:-ruff check .}"
  FORMAT_CMD="${FORMAT_CMD:-black .}"
  TYPECHECK_CMD="${TYPECHECK_CMD:-mypy .}"
  TEST_CMD="${TEST_CMD:-pytest}"
fi

# Go-specific
if [ "$PRIMARY_LANGUAGE" = "Go" ]; then
  LINT_CMD="${LINT_CMD:-golangci-lint run}"
  FORMAT_CMD="${FORMAT_CMD:-gofmt -w .}"
  TYPECHECK_CMD="${TYPECHECK_CMD:-go vet ./...}"
  TEST_CMD="${TEST_CMD:-go test ./...}"
fi

# Rust-specific
if [ "$PRIMARY_LANGUAGE" = "Rust" ]; then
  LINT_CMD="${LINT_CMD:-cargo clippy}"
  FORMAT_CMD="${FORMAT_CMD:-cargo fmt}"
  TYPECHECK_CMD="${TYPECHECK_CMD:-cargo check}"
  TEST_CMD="${TEST_CMD:-cargo test}"
fi

# Java/Kotlin-specific
if [ "$PRIMARY_LANGUAGE" = "Java/Kotlin" ]; then
  LINT_CMD="${LINT_CMD:-./gradlew check}"
  FORMAT_CMD="${FORMAT_CMD:-./gradlew spotlessApply}"
  TYPECHECK_CMD="${TYPECHECK_CMD:-./gradlew compileJava}"
  TEST_CMD="${TEST_CMD:-./gradlew test}"
fi

# C/C++-specific
if [ "$PRIMARY_LANGUAGE" = "C/C++" ]; then
  LINT_CMD="${LINT_CMD:-cppcheck --enable=all .}"
  FORMAT_CMD="${FORMAT_CMD:-clang-format -i src/**/*.cpp src/**/*.h}"
  TYPECHECK_CMD="${TYPECHECK_CMD:-cmake --build build}"
  TEST_CMD="${TEST_CMD:-ctest --test-dir build}"
fi

# Test runner (if not already set)
if [ -z "$TEST_RUNNER" ]; then
  case "$PRIMARY_LANGUAGE" in
    TypeScript|JavaScript) TEST_RUNNER="Vitest" ;;
    Python) TEST_RUNNER="pytest" ;;
    Go) TEST_RUNNER="go test" ;;
    Rust) TEST_RUNNER="cargo test" ;;
    Java/Kotlin) TEST_RUNNER="JUnit" ;;
    "C/C++") TEST_RUNNER="CTest" ;;
    *) TEST_RUNNER="project test runner" ;;
  esac
fi

# Fallback for commands not yet set
read -rp "Lint command [${LINT_CMD:-none}]: " USER_LINT
LINT_CMD="${USER_LINT:-$LINT_CMD}"
read -rp "Format command [${FORMAT_CMD:-none}]: " USER_FORMAT
FORMAT_CMD="${USER_FORMAT:-$FORMAT_CMD}"
read -rp "Type check command [${TYPECHECK_CMD:-none}]: " USER_TYPECHECK
TYPECHECK_CMD="${USER_TYPECHECK:-$TYPECHECK_CMD}"
read -rp "Test command [${TEST_CMD:-none}]: " USER_TEST
TEST_CMD="${USER_TEST:-$TEST_CMD}"

read -rp "Coverage thresholds (statements/branches/functions/lines) [$COVERAGE_THRESHOLDS]: " USER_COV
COVERAGE_THRESHOLDS="${USER_COV:-$COVERAGE_THRESHOLDS}"

read -rp "Include Docker/CI-CD rules? [y/N]: " DOCKER_ANSWER
[[ "$DOCKER_ANSWER" =~ ^[Yy]$ ]] && INCLUDE_DOCKER=true

# ---- Stage 4: Architecture ----

echo ""
info "Stage 4: Architecture"
echo ""

read -rp "Architecture summary (1-2 sentences, or blank): " ARCHITECTURE_SUMMARY
ARCHITECTURE_SUMMARY="${ARCHITECTURE_SUMMARY:-Describe your architecture here. See rules/architecture.md.}"

# Auto-detect key paths
AUTO_PATHS=""
for DIR in src lib app pkg cmd internal components pages api utils tests test spec; do
  [ -d "$TARGET_DIR/$DIR" ] && AUTO_PATHS="$AUTO_PATHS\n- \`$DIR/\`"
done

if [ -n "$AUTO_PATHS" ]; then
  echo "Detected directories:"
  echo -e "$AUTO_PATHS"
fi
read -rp "Key directories (comma-separated, or press Enter to use detected): " USER_PATHS

if [ -n "$USER_PATHS" ]; then
  KEY_PATHS=$(echo "$USER_PATHS" | tr ',' '\n' | sed 's/^ *//;s/ *$//;s/^/- `&`/' | sed 's/`$/`\//')
else
  KEY_PATHS=$(echo -e "$AUTO_PATHS")
fi
KEY_PATHS="${KEY_PATHS:-No key paths configured yet.}"

# ---- Parse coverage thresholds ----

IFS='/' read -r COVERAGE_STATEMENTS COVERAGE_BRANCHES COVERAGE_FUNCTIONS COVERAGE_LINES <<< "$COVERAGE_THRESHOLDS"
COVERAGE_STATEMENTS="${COVERAGE_STATEMENTS:-80}"
COVERAGE_BRANCHES="${COVERAGE_BRANCHES:-75}"
COVERAGE_FUNCTIONS="${COVERAGE_FUNCTIONS:-80}"
COVERAGE_LINES="${COVERAGE_LINES:-80}"

# ---- Detect forge plugin identifier ----

FORGE_PLUGIN_ID="claude-forge@local"
if command -v node &>/dev/null && [ -f "$HOME/.claude/plugins/installed_plugins.json" ]; then
  DETECTED_ID=$(node -e "
    const data = JSON.parse(require('fs').readFileSync('$HOME/.claude/plugins/installed_plugins.json', 'utf8'));
    const keys = Object.keys(data.plugins || {}).filter(k => k.startsWith('claude-forge'));
    if (keys.length > 0) console.log(keys[0]);
  " 2>/dev/null || true)
  [ -n "$DETECTED_ID" ] && FORGE_PLUGIN_ID="$DETECTED_ID"
fi

# ---- Generate files ----

echo ""
info "Generating .claude/ configuration..."
echo ""

mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/hooks"

# Helper: process a template file with sed substitution
process_template() {
  local SRC="$1"
  local DST="$2"
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_DESCRIPTION}}|$PROJECT_DESCRIPTION|g" \
    -e "s|{{TECH_STACK}}|$TECH_STACK|g" \
    -e "s|{{PRIMARY_LANGUAGE}}|$PRIMARY_LANGUAGE|g" \
    -e "s|{{ARCHITECTURE_SUMMARY}}|$ARCHITECTURE_SUMMARY|g" \
    -e "s|{{TEST_RUNNER}}|$TEST_RUNNER|g" \
    -e "s|{{E2E_RUNNER}}|$E2E_RUNNER|g" \
    -e "s|{{COVERAGE_THRESHOLDS}}|$COVERAGE_THRESHOLDS|g" \
    -e "s|{{LINT_CMD}}|$LINT_CMD|g" \
    -e "s|{{FORMAT_CMD}}|$FORMAT_CMD|g" \
    -e "s|{{TYPECHECK_CMD}}|$TYPECHECK_CMD|g" \
    -e "s|{{TEST_CMD}}|$TEST_CMD|g" \
    -e "s|{{E2E_CMD}}|$E2E_CMD|g" \
    -e "s|{{STORYBOOK_BUILD_CMD}}|$STORYBOOK_BUILD_CMD|g" \
    -e "s|{{IMPORT_ALIAS}}|$IMPORT_ALIAS|g" \
    -e "s|{{STATE_MANAGEMENT}}|$STATE_MANAGEMENT|g" \
    -e "s|{{CSS_FRAMEWORK}}|$CSS_FRAMEWORK|g" \
    -e "s|{{COVERAGE_STATEMENTS}}|$COVERAGE_STATEMENTS|g" \
    -e "s|{{COVERAGE_BRANCHES}}|$COVERAGE_BRANCHES|g" \
    -e "s|{{COVERAGE_FUNCTIONS}}|$COVERAGE_FUNCTIONS|g" \
    -e "s|{{COVERAGE_LINES}}|$COVERAGE_LINES|g" \
    -e "s|{{FORGE_PLUGIN_ID}}|$FORGE_PLUGIN_ID|g" \
    "$SRC" > "$DST"
}

# Special handling for KEY_PATHS (multiline)
process_template_with_paths() {
  local SRC="$1"
  local DST="$2"
  process_template "$SRC" "$DST"
  # Replace KEY_PATHS placeholder with actual multiline content
  local ESCAPED_PATHS
  ESCAPED_PATHS=$(echo "$KEY_PATHS" | sed 's/[&/\]/\\&/g')
  sed -i '' "s|{{KEY_PATHS}}|$ESCAPED_PATHS|g" "$DST" 2>/dev/null || \
    sed -i "s|{{KEY_PATHS}}|$ESCAPED_PATHS|g" "$DST" 2>/dev/null || true
}

# Always generate
process_template_with_paths "$TEMPLATE_DIR/CLAUDE.md.tmpl" "$CLAUDE_DIR/CLAUDE.md"
ok "CLAUDE.md"

process_template "$TEMPLATE_DIR/rules/coding-standards.md.tmpl" "$CLAUDE_DIR/rules/coding-standards.md"
ok "rules/coding-standards.md"

process_template "$TEMPLATE_DIR/rules/workflow.md.tmpl" "$CLAUDE_DIR/rules/workflow.md"
ok "rules/workflow.md"

process_template "$TEMPLATE_DIR/rules/architecture.md.tmpl" "$CLAUDE_DIR/rules/architecture.md"
ok "rules/architecture.md"

process_template "$TEMPLATE_DIR/rules/testing.md.tmpl" "$CLAUDE_DIR/rules/testing.md"
ok "rules/testing.md"

cp "$TEMPLATE_DIR/rules/token-efficiency.md" "$CLAUDE_DIR/rules/token-efficiency.md"
ok "rules/token-efficiency.md"

process_template "$TEMPLATE_DIR/rules/docs.md.tmpl" "$CLAUDE_DIR/rules/docs.md"
ok "rules/docs.md"

# Conditional: UI/UX rules
if [ "$INCLUDE_UI_UX" = true ]; then
  process_template "$TEMPLATE_DIR/rules/ui-ux.md.tmpl" "$CLAUDE_DIR/rules/ui-ux.md"
  ok "rules/ui-ux.md"
fi

# Conditional: Docker/CI-CD rules
if [ "$INCLUDE_DOCKER" = true ]; then
  process_template "$TEMPLATE_DIR/rules/docker-ci-cd.md.tmpl" "$CLAUDE_DIR/rules/docker-ci-cd.md"
  ok "rules/docker-ci-cd.md"
fi

# Settings
process_template "$TEMPLATE_DIR/settings.json.tmpl" "$CLAUDE_DIR/settings.json"
ok "settings.json"

process_template "$TEMPLATE_DIR/settings.local.json.tmpl" "$CLAUDE_DIR/settings.local.json"
ok "settings.local.json"

# Hooks
cp "$TEMPLATE_DIR/hooks/auto-plugin-mode.sh" "$CLAUDE_DIR/hooks/auto-plugin-mode.sh"
chmod +x "$CLAUDE_DIR/hooks/auto-plugin-mode.sh"
ok "hooks/auto-plugin-mode.sh"

process_template "$TEMPLATE_DIR/hooks/plugin-profiles.json.tmpl" "$CLAUDE_DIR/hooks/plugin-profiles.json"
ok "hooks/plugin-profiles.json"

process_template "$TEMPLATE_DIR/hooks/session-end-unified-gate.sh.tmpl" "$CLAUDE_DIR/hooks/session-end-unified-gate.sh"
chmod +x "$CLAUDE_DIR/hooks/session-end-unified-gate.sh"
ok "hooks/session-end-unified-gate.sh"

cp "$TEMPLATE_DIR/hooks/security-patterns.txt" "$CLAUDE_DIR/hooks/security-patterns.txt"
ok "hooks/security-patterns.txt"

# ---- Generate .scaffold-meta.json ----

SCAFFOLD_VERSION=$(jq -r '.version' "$SCRIPT_DIR/../.claude-plugin/plugin.json" 2>/dev/null || echo "1.0.0")

# Compute checksums for all generated files
CHECKSUMS="{"
FIRST=true
for FILE in $(find "$CLAUDE_DIR" -type f | sort); do
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

cat > "$CLAUDE_DIR/.scaffold-meta.json" << METAEOF
{
  "version": "$SCAFFOLD_VERSION",
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source": "claude-forge",
  "forge_plugin_id": "$FORGE_PLUGIN_ID",
  "project_type": "$PROJECT_TYPE",
  "primary_language": "$PRIMARY_LANGUAGE",
  "checksums": $CHECKSUMS
}
METAEOF
ok ".scaffold-meta.json"

# ---- Summary ----

echo ""
echo "============================================"
echo "  claude-forge scaffold complete!"
echo "============================================"
echo ""
info "Generated $(find "$CLAUDE_DIR" -type f | wc -l | tr -d ' ') files in $CLAUDE_DIR/"
echo ""
echo "Next steps:"
echo "  1. Review and customize .claude/CLAUDE.md"
echo "  2. Fill in .claude/rules/architecture.md with your patterns"
echo "  3. Open a Claude Code session to verify hooks fire"
echo "  4. Run /branch-safety-check to test the plugin"
echo ""
echo "To update later: bash $SCRIPT_DIR/update.sh"
echo ""
