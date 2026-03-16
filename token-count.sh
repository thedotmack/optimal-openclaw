#!/usr/bin/env bash
#
# token-count.sh — Estimate token counts for workspace files and system prompt budget.
#
# Usage:
#   ./token-count.sh
#
# Processes all files in workspace/defaults/, workspace/dev-variants/,
# and reference/system-prompt/ to estimate token usage per turn.
#
# Token estimation uses words × 1.3, which gets within ~10% for English text.
# Counts are rounded to the nearest 100 for readability.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/workspace"
REFERENCE_DIR="$SCRIPT_DIR/reference"

TOKENS_PER_WORD="1.3"

# Round a number to the nearest 100
round_to_nearest_hundred() {
  local raw_tokens="$1"
  # Use awk for portable floating-point rounding
  awk "BEGIN { printf \"%d\", int(($raw_tokens + 50) / 100) * 100 }"
}

# Count words in a file and estimate tokens
count_file_tokens() {
  local filepath="$1"
  local word_count
  word_count="$(wc -w < "$filepath" | tr -d ' ')"
  local raw_tokens
  raw_tokens="$(awk "BEGIN { printf \"%.0f\", $word_count * $TOKENS_PER_WORD }")"
  local rounded_tokens
  rounded_tokens="$(round_to_nearest_hundred "$raw_tokens")"
  echo "$word_count $rounded_tokens"
}

# Print a single file's token line and accumulate into subtotal
# Expects caller to have a local `subtotal_tokens` variable
print_file_line() {
  local filepath="$1"
  local filename
  filename="$(basename "$filepath")"

  if [[ ! -f "$filepath" ]]; then
    echo "  SKIP  $filename (not found)"
    return
  fi

  local result
  result="$(count_file_tokens "$filepath")"
  local word_count="${result%% *}"
  local rounded_tokens="${result##* }"

  printf "  %-30s ~%s tokens (%s words)\n" "$filename" "$(printf "%'d" "$rounded_tokens")" "$(printf "%'d" "$word_count")"

  # Accumulate raw (unrounded) token count for accurate subtotals
  local raw_tokens
  raw_tokens="$(awk "BEGIN { printf \"%.0f\", $word_count * $TOKENS_PER_WORD }")"
  subtotal_raw_tokens=$((subtotal_raw_tokens + raw_tokens))
}

echo "Token Count Estimates"
echo "====================="
echo ""
echo "Approximation: words × $TOKENS_PER_WORD (rounded to nearest 100)"
echo ""

# --- Workspace defaults ---
echo "--- Workspace defaults (injected every turn) ---"
subtotal_raw_tokens=0
for filepath in "$WORKSPACE_DIR/defaults/"*; do
  [[ -f "$filepath" ]] || continue
  print_file_line "$filepath"
done
workspace_defaults_raw=$subtotal_raw_tokens
workspace_defaults_rounded="$(round_to_nearest_hundred "$workspace_defaults_raw")"
echo ""
printf "  Subtotal: ~%s tokens\n" "$(printf "%'d" "$workspace_defaults_rounded")"
echo ""

# --- Dev variants ---
echo "--- Dev variant workspace files ---"
subtotal_raw_tokens=0
for filepath in "$WORKSPACE_DIR/dev-variants/"*; do
  [[ -f "$filepath" ]] || continue
  print_file_line "$filepath"
done
dev_variants_raw=$subtotal_raw_tokens
dev_variants_rounded="$(round_to_nearest_hundred "$dev_variants_raw")"
echo ""
printf "  Subtotal: ~%s tokens\n" "$(printf "%'d" "$dev_variants_rounded")"
echo ""

# --- Reference system prompt sections ---
echo "--- Reference system prompt sections (hardcoded/partial) ---"
subtotal_raw_tokens=0
for filepath in "$REFERENCE_DIR/system-prompt/"*; do
  [[ -f "$filepath" ]] || continue
  print_file_line "$filepath"
done
system_prompt_raw=$subtotal_raw_tokens
system_prompt_rounded="$(round_to_nearest_hundred "$system_prompt_raw")"
echo ""
printf "  Subtotal: ~%s tokens\n" "$(printf "%'d" "$system_prompt_rounded")"
echo ""

# --- Totals ---
echo "==========================================="

workspace_total_raw=$((workspace_defaults_raw + dev_variants_raw))
workspace_total_rounded="$(round_to_nearest_hundred "$workspace_total_raw")"

full_prompt_raw=$((workspace_defaults_raw + system_prompt_raw))
full_prompt_rounded="$(round_to_nearest_hundred "$full_prompt_raw")"

echo ""
printf "Total workspace injection per turn:  ~%s tokens\n" "$(printf "%'d" "$workspace_total_rounded")"
printf "Estimated full system prompt:         ~%s tokens\n" "$(printf "%'d" "$full_prompt_rounded")"
echo ""
echo "(Dev variants replace defaults when the dev agent is active;"
echo " they are not additive to the system prompt.)"
