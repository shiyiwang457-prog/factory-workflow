#!/usr/bin/env bash
# Factory Workflow — Install Script
#
# Usage:
#   # Install to a specific project
#   ./install.sh /path/to/my-project
#
#   # Install to current directory
#   ./install.sh .
#
#   # Install globally (commands available in all projects)
#   ./install.sh --global

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_MODE="project"
TARGET_DIR=""

# --- Parse arguments ---
case "${1:-}" in
  --global)
    INSTALL_MODE="global"
    TARGET_DIR="$HOME/.claude"
    ;;
  --help|-h)
    echo "Factory Workflow Installer"
    echo ""
    echo "Usage:"
    echo "  ./install.sh <project-path>   Install to a project"
    echo "  ./install.sh --global         Install commands globally"
    echo "  ./install.sh --help           Show this help"
    echo ""
    echo "What gets installed:"
    echo "  - .claude/commands/factory-*.md  (9 slash commands)"
    echo "  - templates/CLAUDE.md            (project rules template)"
    echo "  - hooks/gate-check.sh            (optional gate enforcement)"
    echo ""
    echo "Project install also creates:"
    echo "  - docs/ directory structure"
    echo "  - CLAUDE.md from template"
    exit 0
    ;;
  "")
    echo "Error: specify a project path or --global"
    echo "Run ./install.sh --help for usage"
    exit 1
    ;;
  *)
    TARGET_DIR="$(cd "$1" 2>/dev/null && pwd || echo "$1")"
    ;;
esac

echo "Factory Workflow Installer"
echo "========================="
echo "Mode: $INSTALL_MODE"
echo "Target: $TARGET_DIR"
echo ""

# --- Install slash commands ---
echo "Installing slash commands..."
mkdir -p "$TARGET_DIR/.claude/commands"

for cmd in "$SCRIPT_DIR/.claude/commands"/factory-*.md; do
  filename=$(basename "$cmd")
  cp "$cmd" "$TARGET_DIR/.claude/commands/$filename"
  echo "  + $filename"
done

echo "  Done: $(ls "$SCRIPT_DIR/.claude/commands"/factory-*.md | wc -l | tr -d ' ') commands installed"

# --- Project-specific installs ---
if [ "$INSTALL_MODE" = "project" ]; then
  # Create directory structure
  echo ""
  echo "Creating project structure..."
  mkdir -p "$TARGET_DIR/docs/prd"
  mkdir -p "$TARGET_DIR/docs/brand"
  mkdir -p "$TARGET_DIR/docs/dispatch"
  mkdir -p "$TARGET_DIR/docs/reviews"
  echo "  + docs/prd/"
  echo "  + docs/brand/"
  echo "  + docs/dispatch/"
  echo "  + docs/reviews/"

  # Copy CLAUDE.md if not exists
  if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    echo "  + CLAUDE.md (from template)"
  else
    echo "  ~ CLAUDE.md already exists, skipping (check templates/CLAUDE.md for updates)"
  fi

  # Copy templates
  echo ""
  echo "Copying templates..."
  mkdir -p "$TARGET_DIR/templates"
  for tpl in "$SCRIPT_DIR/templates"/*.md; do
    filename=$(basename "$tpl")
    if [ "$filename" != "CLAUDE.md" ]; then
      cp "$tpl" "$TARGET_DIR/templates/$filename"
      echo "  + templates/$filename"
    fi
  done

  # Copy hook
  echo ""
  echo "Installing gate-check hook..."
  mkdir -p "$TARGET_DIR/hooks"
  cp "$SCRIPT_DIR/hooks/gate-check.sh" "$TARGET_DIR/hooks/gate-check.sh"
  chmod +x "$TARGET_DIR/hooks/gate-check.sh"
  echo "  + hooks/gate-check.sh"

  # Create CHANGELOG if not exists
  if [ ! -f "$TARGET_DIR/CHANGELOG.md" ]; then
    cat > "$TARGET_DIR/CHANGELOG.md" << 'CHANGELOG'
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Project initialized with Factory Workflow
CHANGELOG
    echo "  + CHANGELOG.md"
  fi
fi

# --- Summary ---
echo ""
echo "========================="
echo "Installation complete!"
echo ""
echo "Available commands:"
echo "  /factory-init      Initialize a new Factory Workflow project"
echo "  /factory-prd       Start PRD phase (Agent 1: PM)"
echo "  /factory-schema    Start Schema phase (Agent 2A)"
echo "  /factory-dispatch  Create a dispatch brief"
echo "  /factory-dev       Start Dev phase (Agent 2B)"
echo "  /factory-qa        Start QA phase (Agent 3)"
echo "  /factory-gate      Check gate evidence"
echo "  /factory-resume    Resume from file state"
echo "  /factory-ship      Ship a version"
echo "  /factory-status    Show project status"
echo ""

if [ "$INSTALL_MODE" = "project" ]; then
  echo "Next step: open Claude Code in $TARGET_DIR and run /factory-prd"
  echo ""
  echo "Optional: enable gate-check hook in .claude/settings.json:"
  echo '  {"hooks": {"PreToolUse": [{"command": "./hooks/gate-check.sh"}]}}'
fi
