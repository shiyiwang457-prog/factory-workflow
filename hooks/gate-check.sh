#!/usr/bin/env bash
# Factory Workflow — Gate Check Hook
# Claude Code PreToolUse hook: warns before editing source code without gate evidence.
#
# Install: add to .claude/settings.json under hooks.PreToolUse
# Mode: FACTORY_GATE_MODE=block (default) or FACTORY_GATE_MODE=advisory
#
# How it works:
# - When Claude tries to Edit/Write a source file, this hook checks if the
#   required gate artifacts exist in docs/reviews/
# - If artifacts are missing, it blocks (or warns) the edit
# - Docs, tests, configs, and migrations are always allowed

set -euo pipefail

# --- Configuration ---
GATE_MODE="${FACTORY_GATE_MODE:-block}"
REVIEWS_DIR="docs/reviews"

# --- Parse input from Claude Code ---
# Claude Code passes: tool_name, file_path via stdin JSON
# For simplicity, we check arguments
TOOL_NAME="${1:-}"
FILE_PATH="${2:-}"

# --- Always-allow list ---
# These paths can be edited without gate evidence
ALLOW_PATTERNS=(
  "docs/*"
  "tests/*"
  "test_*"
  "*_test.*"
  "*.md"
  "*.txt"
  "*.json"
  "*.yaml"
  "*.yml"
  "*.toml"
  "*.cfg"
  "*.ini"
  "*.env*"
  ".gitignore"
  "*.lock"
  "migrations/*"
  "alembic/*"
  "dev_scripts/*"
  ".claude/*"
  ".factory/*"
)

# --- Functions ---
matches_allow_list() {
  local path="$1"
  for pattern in "${ALLOW_PATTERNS[@]}"; do
    # shellcheck disable=SC2254
    case "$path" in
      $pattern) return 0 ;;
    esac
  done
  return 1
}

check_gate_artifacts() {
  local missing=()

  # Check for at least one review artifact
  if [ -d "$REVIEWS_DIR" ]; then
    local count
    count=$(find "$REVIEWS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -eq 0 ]; then
      missing+=("No gate evidence in $REVIEWS_DIR/ — run /factory-gate to check")
    fi
  else
    missing+=("$REVIEWS_DIR/ directory doesn't exist — run /factory-init first")
  fi

  # Check for dispatch brief
  if ! ls docs/dispatch/agent2b-v*.md &>/dev/null; then
    missing+=("No dispatch brief — run /factory-dispatch first")
  fi

  if [ ${#missing[@]} -gt 0 ]; then
    echo "${missing[*]}"
    return 1
  fi
  return 0
}

# --- Main ---

# Only check Edit and Write tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Skip if no file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Allow-listed paths pass through
if matches_allow_list "$FILE_PATH"; then
  exit 0
fi

# Check gate artifacts for source file edits
GATE_ISSUES=$(check_gate_artifacts 2>&1) || {
  if [ "$GATE_MODE" = "block" ]; then
    echo "FACTORY GATE BLOCK: Editing source file without gate evidence."
    echo "File: $FILE_PATH"
    echo "Issues: $GATE_ISSUES"
    echo ""
    echo "To proceed anyway: export FACTORY_GATE_MODE=advisory"
    exit 1
  else
    echo "FACTORY GATE WARNING: Editing source file without gate evidence."
    echo "File: $FILE_PATH"
    echo "Issues: $GATE_ISSUES"
    exit 0
  fi
}

exit 0
