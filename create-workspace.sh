#!/usr/bin/env bash
#
# create-workspace.sh — Scaffold a new workspace directory from default templates.
#
# Usage:
#   ./create-workspace.sh [target-directory]
#
# Creates a new workspace by copying all default template files and optionally
# filling in agent name, user name, and timezone via interactive prompts.
#
# Arguments:
#   target-directory    Where to create the workspace (default: ./my-workspace/)
#
# Options:
#   -h, --help          Show this help message
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULTS_DIR="$SCRIPT_DIR/workspace/defaults"
TARGET_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "Usage: $0 [target-directory]"
      echo ""
      echo "Scaffold a new workspace directory from default templates."
      echo ""
      echo "Arguments:"
      echo "  target-directory    Where to create the workspace (default: ./my-workspace/)"
      echo ""
      echo "Options:"
      echo "  -h, --help          Show this help message"
      echo ""
      echo "In interactive mode (tty attached), you'll be prompted for:"
      echo "  - Agent name        (filled into IDENTITY.md)"
      echo "  - User name         (filled into USER.md)"
      echo "  - Timezone          (filled into USER.md)"
      echo "  - Whether to include BOOTSTRAP.md"
      echo ""
      echo "In non-interactive mode (no tty), templates are copied as-is."
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *)
      if [[ -n "$TARGET_DIR" ]]; then
        echo "Error: Multiple target directories specified." >&2
        exit 1
      fi
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

# Default target directory
if [[ -z "$TARGET_DIR" ]]; then
  TARGET_DIR="./my-workspace"
fi

# Ensure trailing slash is stripped for consistent display
TARGET_DIR="${TARGET_DIR%/}"

# Check that the defaults directory exists
if [[ ! -d "$DEFAULTS_DIR" ]]; then
  echo "Error: Default templates not found at $DEFAULTS_DIR" >&2
  exit 1
fi

# Don't overwrite an existing workspace
if [[ -e "$TARGET_DIR" ]]; then
  echo "Error: $TARGET_DIR already exists. Remove it first or choose a different path." >&2
  exit 1
fi

# All template files to copy
WORKSPACE_FILES=(
  "AGENTS.md"
  "BOOT.md"
  "BOOTSTRAP.md"
  "HEARTBEAT.md"
  "IDENTITY.md"
  "MEMORY.md"
  "SOUL.md"
  "TOOLS.md"
  "USER.md"
)

# Interactive prompts (only when connected to a terminal)
AGENT_NAME=""
USER_NAME=""
TIMEZONE=""
INCLUDE_BOOTSTRAP=true

if [[ -t 0 ]]; then
  echo "Setting up a new OpenClaw workspace..."
  echo ""

  read -r -p "Agent name (leave blank to fill in later): " AGENT_NAME
  read -r -p "Your name (leave blank to fill in later): " USER_NAME
  read -r -p "Timezone (e.g. America/New_York, leave blank to fill in later): " TIMEZONE

  echo ""
  read -r -p "Include first-run bootstrap? [Y/n] " INCLUDE_BOOTSTRAP_ANSWER
  if [[ "$INCLUDE_BOOTSTRAP_ANSWER" =~ ^[Nn]$ ]]; then
    INCLUDE_BOOTSTRAP=false
  fi

  echo ""
fi

# Create the target directory
mkdir -p "$TARGET_DIR"

COPIED=0

for file in "${WORKSPACE_FILES[@]}"; do
  # Skip BOOTSTRAP.md if user opted out
  if [[ "$file" == "BOOTSTRAP.md" && "$INCLUDE_BOOTSTRAP" == "false" ]]; then
    continue
  fi

  src="$DEFAULTS_DIR/$file"
  dst="$TARGET_DIR/$file"

  if [[ ! -f "$src" ]]; then
    echo "  SKIP  $file (template not found)"
    continue
  fi

  cp "$src" "$dst"
  ((COPIED++)) || true
done

# Fill in interactive values via sed replacements
if [[ -n "$AGENT_NAME" && -f "$TARGET_DIR/IDENTITY.md" ]]; then
  sed -i '' "s/^- \*\*Name:\*\*$/- **Name:** $AGENT_NAME/" "$TARGET_DIR/IDENTITY.md"
  sed -i '' "s/^  _(pick something you like)_$//" "$TARGET_DIR/IDENTITY.md"
fi

if [[ -n "$USER_NAME" && -f "$TARGET_DIR/USER.md" ]]; then
  sed -i '' "s/^- \*\*Name:\*\*$/- **Name:** $USER_NAME/" "$TARGET_DIR/USER.md"
  sed -i '' "s/^- \*\*What to call them:\*\*$/- **What to call them:** $USER_NAME/" "$TARGET_DIR/USER.md"
fi

if [[ -n "$TIMEZONE" && -f "$TARGET_DIR/USER.md" ]]; then
  sed -i '' "s/^- \*\*Timezone:\*\*$/- **Timezone:** $TIMEZONE/" "$TARGET_DIR/USER.md"
fi

echo "Workspace created at $TARGET_DIR/ with $COPIED files"
