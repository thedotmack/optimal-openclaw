#!/usr/bin/env bash
#
# sync-prompts.sh — Sync edited workspace template files back to an OpenClaw installation.
#
# Usage:
#   ./sync-prompts.sh [--dry-run] [--openclaw-path /path/to/openclaw]
#
# This script copies edited workspace template files from this repo's
# prompts/workspace-files/defaults/ directory back to the OpenClaw package's
# docs/reference/templates/ directory.
#
# Options:
#   --dry-run           Show what would be copied without making changes
#   --openclaw-path     Path to the OpenClaw package root (default: auto-detect via npm)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
DRY_RUN=false
OPENCLAW_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --openclaw-path)
      OPENCLAW_PATH="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [--openclaw-path /path/to/openclaw]"
      echo ""
      echo "Sync edited workspace template files back to an OpenClaw installation."
      echo ""
      echo "Options:"
      echo "  --dry-run           Show what would be copied without making changes"
      echo "  --openclaw-path     Path to the OpenClaw package root (default: auto-detect)"
      echo "  -h, --help          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Auto-detect OpenClaw path if not provided
if [[ -z "$OPENCLAW_PATH" ]]; then
  NPM_ROOT="$(npm root -g 2>/dev/null || true)"
  if [[ -n "$NPM_ROOT" && -d "$NPM_ROOT/openclaw" ]]; then
    OPENCLAW_PATH="$NPM_ROOT/openclaw"
  else
    echo "Error: Could not find OpenClaw installation. Use --openclaw-path to specify." >&2
    exit 1
  fi
fi

TEMPLATES_DIR="$OPENCLAW_PATH/docs/reference/templates"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: Templates directory not found at $TEMPLATES_DIR" >&2
  exit 1
fi

echo "OpenClaw path:   $OPENCLAW_PATH"
echo "Templates dir:   $TEMPLATES_DIR"
echo "Prompts source:  $PROMPTS_DIR"
echo "Dry run:         $DRY_RUN"
echo ""

# Workspace files to sync (defaults)
DEFAULT_FILES=(
  "AGENTS.md"
  "SOUL.md"
  "TOOLS.md"
  "IDENTITY.md"
  "USER.md"
  "HEARTBEAT.md"
  "BOOTSTRAP.md"
  "BOOT.md"
)

# Dev variant files to sync
DEV_FILES=(
  "AGENTS.dev.md"
  "SOUL.dev.md"
  "TOOLS.dev.md"
  "IDENTITY.dev.md"
  "USER.dev.md"
)

SYNCED=0
SKIPPED=0

sync_file() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [[ ! -f "$src" ]]; then
    echo "  SKIP  $label (source not found)"
    ((SKIPPED++)) || true
    return
  fi

  if [[ ! -f "$dst" ]]; then
    echo "  NEW   $label"
  elif diff -q "$src" "$dst" > /dev/null 2>&1; then
    echo "  OK    $label (unchanged)"
    return
  else
    echo "  SYNC  $label"
  fi

  if [[ "$DRY_RUN" == "false" ]]; then
    cp "$src" "$dst"
  fi
  ((SYNCED++)) || true
}

echo "--- Default workspace files ---"
for file in "${DEFAULT_FILES[@]}"; do
  sync_file "$PROMPTS_DIR/workspace-files/defaults/$file" "$TEMPLATES_DIR/$file" "defaults/$file"
done

echo ""
echo "--- Dev variant files ---"
for file in "${DEV_FILES[@]}"; do
  sync_file "$PROMPTS_DIR/workspace-files/dev-variants/$file" "$TEMPLATES_DIR/$file" "dev-variants/$file"
done

echo ""
echo "--- Config defaults ---"
if [[ -f "$PROMPTS_DIR/config/openclaw-defaults.json" ]]; then
  echo "  INFO  config/openclaw-defaults.json is a reference file."
  echo "        To apply config changes, edit ~/.openclaw/openclaw.json directly"
  echo "        or use: openclaw config apply"
fi

echo ""
echo "Done. Synced: $SYNCED, Skipped: $SKIPPED"

if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  echo "(Dry run — no files were modified)"
fi

if [[ "$SYNCED" -gt 0 && "$DRY_RUN" == "false" ]]; then
  echo ""
  echo "Restart OpenClaw to pick up changes:"
  echo "  openclaw gateway restart"
fi
