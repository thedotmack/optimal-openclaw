#!/usr/bin/env bash
#
# sync-prompts.sh — Sync edited workspace template files back to an OpenClaw installation.
#
# Usage:
#   ./sync-prompts.sh [--dry-run] [--diff] [--restore] [--openclaw-path /path/to/openclaw]
#
# This script copies edited workspace template files from this repo's
# workspace/defaults/ directory back to the OpenClaw package's
# docs/reference/templates/ directory.
#
# Options:
#   --dry-run           Show what would be copied without making changes
#   --diff              Show unified diffs between source and target files (no sync)
#   --restore           Restore files from the latest backup
#   --openclaw-path     Path to the OpenClaw package root (default: auto-detect via npm)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/workspace"
DRY_RUN=false
DIFF_ONLY=false
RESTORE=false
OPENCLAW_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --diff)
      DIFF_ONLY=true
      shift
      ;;
    --restore)
      RESTORE=true
      shift
      ;;
    --openclaw-path)
      OPENCLAW_PATH="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [--diff] [--restore] [--openclaw-path /path/to/openclaw]"
      echo ""
      echo "Sync edited workspace template files back to an OpenClaw installation."
      echo ""
      echo "Options:"
      echo "  --dry-run           Show what would be copied without making changes"
      echo "  --diff              Show unified diffs between source and target files (no sync)"
      echo "  --restore           Restore files from the latest backup"
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

# Enforce mutual exclusivity of --dry-run, --diff, and --restore
EXCLUSIVE_COUNT=0
if [[ "$DRY_RUN" == "true" ]]; then ((EXCLUSIVE_COUNT++)) || true; fi
if [[ "$DIFF_ONLY" == "true" ]]; then ((EXCLUSIVE_COUNT++)) || true; fi
if [[ "$RESTORE" == "true" ]]; then ((EXCLUSIVE_COUNT++)) || true; fi
if [[ "$EXCLUSIVE_COUNT" -gt 1 ]]; then
  echo "Error: --dry-run, --diff, and --restore are mutually exclusive." >&2
  exit 1
fi

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
BACKUP_BASE_DIR="$OPENCLAW_PATH/.openclaw-backup"

if [[ ! -d "$TEMPLATES_DIR" ]]; then
  echo "Error: Templates directory not found at $TEMPLATES_DIR" >&2
  exit 1
fi

# --- Handle --restore ---
if [[ "$RESTORE" == "true" ]]; then
  if [[ ! -d "$BACKUP_BASE_DIR" ]]; then
    echo "Error: No backup directory found at $BACKUP_BASE_DIR" >&2
    exit 1
  fi

  LATEST_BACKUP="$(ls -1d "$BACKUP_BASE_DIR"/*/ 2>/dev/null | sort | tail -n 1)"
  if [[ -z "$LATEST_BACKUP" ]]; then
    echo "Error: No backups found in $BACKUP_BASE_DIR" >&2
    exit 1
  fi

  LATEST_BACKUP_NAME="$(basename "$LATEST_BACKUP")"
  echo "Restoring from backup: $LATEST_BACKUP_NAME"
  echo ""

  RESTORED=0
  for backup_file in "$LATEST_BACKUP"*; do
    [[ -f "$backup_file" ]] || continue
    filename="$(basename "$backup_file")"
    target="$TEMPLATES_DIR/$filename"
    echo "  RESTORE  $filename"
    cp "$backup_file" "$target"
    ((RESTORED++)) || true
  done

  echo ""
  echo "Done. Restored $RESTORED file(s) from .openclaw-backup/$LATEST_BACKUP_NAME"
  echo ""
  echo "Restart OpenClaw to pick up changes:"
  echo "  openclaw gateway restart"
  exit 0
fi

echo "OpenClaw path:   $OPENCLAW_PATH"
echo "Templates dir:   $TEMPLATES_DIR"
echo "Workspace source: $WORKSPACE_DIR"
if [[ "$DIFF_ONLY" == "true" ]]; then
  echo "Mode:            diff"
else
  echo "Dry run:         $DRY_RUN"
fi
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
  "MEMORY.md"
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
DIFF_FOUND=0
BACKUP_DIR=""
BACKUP_CREATED=false

# Create the backup directory (once per run) and back up a single file
backup_file() {
  local file_to_backup="$1"

  if [[ "$BACKUP_CREATED" == "false" ]]; then
    BACKUP_TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
    BACKUP_DIR="$BACKUP_BASE_DIR/$BACKUP_TIMESTAMP"
    mkdir -p "$BACKUP_DIR"
    echo "Backed up to .openclaw-backup/$BACKUP_TIMESTAMP/"
    echo ""
    BACKUP_CREATED=true
  fi

  cp "$file_to_backup" "$BACKUP_DIR/"
}

# Show unified diff between source and target
diff_file() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [[ ! -f "$src" ]]; then
    echo "  SKIP  $label (source not found)"
    return
  fi

  if [[ ! -f "$dst" ]]; then
    echo "  NEW   $label (target does not exist yet)"
    ((DIFF_FOUND++)) || true
    return
  fi

  local file_diff
  file_diff="$(diff -u "$dst" "$src" 2>/dev/null)" || true
  if [[ -n "$file_diff" ]]; then
    echo "  DIFF  $label"
    echo "$file_diff"
    echo ""
    ((DIFF_FOUND++)) || true
  fi
}

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
    # Back up the existing target file before overwriting
    if [[ -f "$dst" ]]; then
      backup_file "$dst"
    fi
    cp "$src" "$dst"
  fi
  ((SYNCED++)) || true
}

# --- Handle --diff ---
if [[ "$DIFF_ONLY" == "true" ]]; then
  echo "--- Default workspace files ---"
  for file in "${DEFAULT_FILES[@]}"; do
    diff_file "$WORKSPACE_DIR/defaults/$file" "$TEMPLATES_DIR/$file" "defaults/$file"
  done

  echo ""
  echo "--- Dev variant files ---"
  for file in "${DEV_FILES[@]}"; do
    diff_file "$WORKSPACE_DIR/dev-variants/$file" "$TEMPLATES_DIR/$file" "dev-variants/$file"
  done

  echo ""
  if [[ "$DIFF_FOUND" -eq 0 ]]; then
    echo "No differences"
  else
    echo "Files with differences: $DIFF_FOUND"
  fi
  exit 0
fi

# --- Normal sync ---
echo "--- Default workspace files ---"
for file in "${DEFAULT_FILES[@]}"; do
  sync_file "$WORKSPACE_DIR/defaults/$file" "$TEMPLATES_DIR/$file" "defaults/$file"
done

echo ""
echo "--- Dev variant files ---"
for file in "${DEV_FILES[@]}"; do
  sync_file "$WORKSPACE_DIR/dev-variants/$file" "$TEMPLATES_DIR/$file" "dev-variants/$file"
done

echo ""
echo "--- Config defaults ---"
REFERENCE_DIR="$SCRIPT_DIR/reference"
if [[ -f "$REFERENCE_DIR/config/openclaw-defaults.json" ]]; then
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
