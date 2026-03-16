#!/usr/bin/env bash
#
# validate-manifest.sh — Validate consistency between prompts/manifest.json and files on disk.
#
# Checks:
#   1. Every "file" entry in manifest.json points to a file that exists on disk
#   2. Every prompt-related file under reference/ and workspace/ has a manifest entry
#   3. Workspace files (under workspace/) are under 2MB (MAX_WORKSPACE_BOOTSTRAP_FILE_BYTES)
#   4. YAML frontmatter in workspace files (if present) has matching --- delimiters
#
# Exit codes:
#   0  All checks pass
#   1  One or more failures detected
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/prompts/manifest.json"
MAX_WORKSPACE_FILE_BYTES=$((2 * 1024 * 1024))  # 2MB

PASS_COUNT=0
FAIL_COUNT=0

# --- Dependency check ---
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not found." >&2
  echo "Install it with: brew install jq (macOS) or apt-get install jq (Debian/Ubuntu)" >&2
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: Manifest not found at $MANIFEST" >&2
  exit 1
fi

# --- Helpers ---
pass() {
  ((PASS_COUNT++)) || true
}

fail() {
  local message="$1"
  echo "  FAIL  $message"
  ((FAIL_COUNT++)) || true
}

# --- Check 1: Every manifest "file" entry exists on disk ---
echo "--- Check 1: Manifest entries point to existing files ---"

MANIFEST_FILES=()
while IFS= read -r filepath; do
  MANIFEST_FILES+=("$filepath")
  full_path="$SCRIPT_DIR/$filepath"
  if [[ -f "$full_path" ]]; then
    pass
  else
    fail "$filepath (listed in manifest but not found on disk)"
  fi
done < <(jq -r '
  [
    .categories["system-prompt"].files[]?.file,
    .categories["user-messages"].files[]?.file,
    .categories["workspace-files"].defaults[]?.file,
    .categories["workspace-files"]["dev-variants"][]?.file,
    .categories["skills"].files[]?.file,
    .categories["config"].files[]?.file
  ] | .[] | select(. != null)
' "$MANIFEST")

echo ""

# --- Check 2: Every file on disk has a manifest entry ---
echo "--- Check 2: Files on disk have manifest entries ---"

# Check if a path is listed in the manifest
is_in_manifest() {
  local needle="$1"
  local entry
  for entry in "${MANIFEST_FILES[@]}"; do
    if [[ "$entry" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

# Find all prompt-related files under reference/ and workspace/
# Exclude directories and README files (repo documentation, not prompt files)
while IFS= read -r disk_file; do
  # Make path relative to repo root
  relative_path="${disk_file#"$SCRIPT_DIR"/}"

  # Skip README files — they are repo documentation, not prompt content
  basename_file="$(basename "$relative_path")"
  if [[ "$basename_file" == "README.md" ]]; then
    continue
  fi

  if is_in_manifest "$relative_path"; then
    pass
  else
    fail "$relative_path (exists on disk but not listed in manifest)"
  fi
done < <(find "$SCRIPT_DIR/reference" "$SCRIPT_DIR/workspace" -type f | sort)

echo ""

# --- Check 3: Workspace files are under 2MB ---
echo "--- Check 3: Workspace file sizes (< 2MB limit) ---"

while IFS= read -r ws_file; do
  relative_path="${ws_file#"$SCRIPT_DIR"/}"
  file_size=$(wc -c < "$ws_file")

  if [[ "$file_size" -lt "$MAX_WORKSPACE_FILE_BYTES" ]]; then
    pass
  else
    size_human=$(( file_size / 1024 / 1024 ))
    fail "$relative_path (${size_human}MB exceeds 2MB limit)"
  fi
done < <(find "$SCRIPT_DIR/workspace" -type f | sort)

echo ""

# --- Check 4: YAML frontmatter in workspace files has matching delimiters ---
echo "--- Check 4: YAML frontmatter delimiters in workspace files ---"

while IFS= read -r ws_file; do
  relative_path="${ws_file#"$SCRIPT_DIR"/}"

  # Check if the file starts with --- (YAML frontmatter opener)
  first_line="$(head -n 1 "$ws_file")"
  if [[ "$first_line" == "---" ]]; then
    # Count --- lines (excluding the first) to find the closing delimiter
    closing_delimiter_found=false
    line_number=0
    while IFS= read -r line; do
      ((line_number++)) || true
      if [[ "$line_number" -gt 1 && "$line" == "---" ]]; then
        closing_delimiter_found=true
        break
      fi
    done < "$ws_file"

    if [[ "$closing_delimiter_found" == "true" ]]; then
      pass
    else
      fail "$relative_path (YAML frontmatter opened with --- but no closing --- found)"
    fi
  fi
done < <(find "$SCRIPT_DIR/workspace" -type f -name "*.md" | sort)

echo ""

# --- Summary ---
TOTAL=$((PASS_COUNT + FAIL_COUNT))
echo "=== Summary: $PASS_COUNT checks passed, $FAIL_COUNT failure(s) out of $TOTAL total ==="

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi

exit 0
