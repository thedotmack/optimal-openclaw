#!/usr/bin/env bash
# generate-docs.sh — Render a human-readable section table from prompts/manifest.json
# Requires: jq (https://jqlang.github.io/jq/)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="$SCRIPT_DIR/prompts/manifest.json"

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed. Install it with: brew install jq" >&2
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest.json not found at $MANIFEST" >&2
  exit 1
fi

echo "System Prompt Sections (from prompts/manifest.json)"
echo "===================================================="
echo ""
printf "%-5s  %-50s  %-10s  %s\n" "#" "Section" "Hardcoded" "Condition"
printf "%-5s  %-50s  %-10s  %s\n" "-----" "--------------------------------------------------" "----------" "----------------------------------------"

jq -r '.categories["system-prompt"].files[] |
  (.file | capture("(?<num>[0-9]+[a-d]?)\\-") | .num) as $num |
  [$num, .section, (.hardcoded | tostring), .condition] |
  @tsv' "$MANIFEST" | while IFS=$'\t' read -r num section hardcoded condition; do
  printf "%-5s  %-50s  %-10s  %s\n" "$num" "$section" "$hardcoded" "$condition"
done

echo ""
echo "User-Message Prompts"
echo "===================="
echo ""
printf "%-40s  %-40s  %s\n" "File" "Trigger" "Configurable"
printf "%-40s  %-40s  %s\n" "----------------------------------------" "----------------------------------------" "----------------------------------------"

jq -r '.categories["user-messages"].files[] |
  [.file, .trigger, (.configurable // "N/A" | tostring)] |
  @tsv' "$MANIFEST" | while IFS=$'\t' read -r file trigger configurable; do
  printf "%-40s  %-40s  %s\n" "$file" "$trigger" "$configurable"
done

echo ""
echo "Workspace Files (defaults)"
echo "=========================="
echo ""
printf "%-12s  %s\n" "Filename" "Purpose"
printf "%-12s  %s\n" "------------" "------------------------------------------------------------"

jq -r '.categories["workspace-files"].defaults[] |
  [.filename, .purpose] |
  @tsv' "$MANIFEST" | while IFS=$'\t' read -r filename purpose; do
  printf "%-12s  %s\n" "$filename" "$purpose"
done
