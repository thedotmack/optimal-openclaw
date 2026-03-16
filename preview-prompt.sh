#!/usr/bin/env bash
#
# preview-prompt.sh — Assemble a simulated full system prompt showing what the LLM sees each turn.
#
# Usage:
#   ./preview-prompt.sh [--workspace PATH] [--no-reference] [--token-count]
#
# Reads manifest.json to determine assembly order, then concatenates all
# system prompt sections and workspace files into a single output.
# Dynamic/partial sections include placeholder markers.
#
# Options:
#   --workspace PATH    Use a custom workspace directory instead of workspace/defaults/
#   --no-reference      Skip reference system prompt sections; only show workspace files
#   --token-count       Append approximate token count at the end
#   -h, --help          Show this help message
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/prompts/manifest.json"
REFERENCE_DIR="$SCRIPT_DIR/reference/system-prompt"
WORKSPACE_DIR="$SCRIPT_DIR/workspace/defaults"
SHOW_REFERENCE=true
SHOW_TOKEN_COUNT=false
TOKENS_PER_WORD="1.3"

# Return a dynamic placeholder marker for sections with runtime-injected content.
# Sections marked "partial" or false in manifest get these annotations.
get_dynamic_placeholder() {
  local prefix="$1"
  case "$prefix" in
    02-tooling)                              echo "[DYNAMIC: tool list filtered by policy]" ;;
    06-skills)                               echo "[DYNAMIC: available skills XML list]" ;;
    09-model-aliases)                        echo "[DYNAMIC: model alias mappings from config]" ;;
    10-current-datetime)                     echo "[DYNAMIC: current date/time and timezone]" ;;
    11-workspace)                            echo "[DYNAMIC: workspace directory path]" ;;
    12-documentation)                        echo "[DYNAMIC: documentation path]" ;;
    13-sandbox)                              echo "[DYNAMIC: sandbox container paths]" ;;
    14-authorized-senders)                   echo "[DYNAMIC: owner phone numbers]" ;;
    15-workspace-files-and-project-context)  echo "[DYNAMIC: workspace file contents injected here -- see workspace section below]" ;;
    17-heartbeats)                           echo "[DYNAMIC: heartbeat interval and config]" ;;
    18-runtime)                              echo "[DYNAMIC: agent, host, repo, os, node, model, shell, channel, capabilities, thinking]" ;;
    20-messaging)                            echo "[DYNAMIC: messaging channel config and restrictions]" ;;
    21a-voice-tts)                           echo "[DYNAMIC: TTS voice hint]" ;;
    21b-group-chat-context)                  echo "[DYNAMIC: extraSystemPrompt content]" ;;
    21c-reactions)                           echo "[DYNAMIC: reaction guidance config]" ;;
    22-inbound-context)                      echo "[DYNAMIC: per-message trusted/untrusted metadata]" ;;
    *)                                       echo "" ;;
  esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --workspace)
      WORKSPACE_DIR="$2"
      shift 2
      ;;
    --no-reference)
      SHOW_REFERENCE=false
      shift
      ;;
    --token-count)
      SHOW_TOKEN_COUNT=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--workspace PATH] [--no-reference] [--token-count]"
      echo ""
      echo "Assemble a simulated full system prompt showing what the LLM sees each turn."
      echo ""
      echo "Output goes to stdout. Pipe to less, wc, or redirect to a file."
      echo ""
      echo "Options:"
      echo "  --workspace PATH    Use a custom workspace directory (default: workspace/defaults/)"
      echo "  --no-reference      Skip reference system prompt sections; only show workspace files"
      echo "  --token-count       Append approximate token count at the end"
      echo "  -h, --help          Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0                          # Full preview to stdout"
      echo "  $0 | less                   # Page through the prompt"
      echo "  $0 --token-count            # Full preview with token estimate"
      echo "  $0 --no-reference           # Workspace files only"
      echo "  $0 --workspace ~/my-agent/  # Use custom workspace"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Validate workspace directory
if [[ ! -d "$WORKSPACE_DIR" ]]; then
  echo "Error: Workspace directory not found at $WORKSPACE_DIR" >&2
  exit 1
fi

# Validate reference directory (unless skipped)
if [[ "$SHOW_REFERENCE" == "true" && ! -d "$REFERENCE_DIR" ]]; then
  echo "Error: Reference directory not found at $REFERENCE_DIR" >&2
  exit 1
fi

# Determine section order from manifest.json (with jq) or fall back to sorted glob
get_reference_section_files() {
  if [[ ! -f "$MANIFEST" ]]; then
    # Fallback: no manifest found, try alternative location
    local alt_manifest="$SCRIPT_DIR/prompts/manifest.json"
    if [[ -f "$alt_manifest" ]]; then
      MANIFEST="$alt_manifest"
    fi
  fi

  if [[ -f "$MANIFEST" ]] && command -v jq &>/dev/null; then
    # Extract file paths from manifest, map reference/ paths to actual filesystem paths
    jq -r '.categories["system-prompt"].files[].file' "$MANIFEST" | while IFS= read -r relpath; do
      local fullpath="$SCRIPT_DIR/$relpath"
      if [[ -f "$fullpath" ]]; then
        echo "$fullpath"
      fi
    done
  else
    # Fallback: sorted glob of reference/system-prompt/
    for filepath in "$REFERENCE_DIR"/*.md; do
      [[ -f "$filepath" ]] || continue
      echo "$filepath"
    done
  fi
}

# Extract the section prefix (e.g., "02-tooling") from a filename
get_section_prefix() {
  local filename
  filename="$(basename "$1" .md)"
  echo "$filename"
}

# Round a number to the nearest 100
round_to_nearest_hundred() {
  local raw_tokens="$1"
  awk "BEGIN { printf \"%d\", int(($raw_tokens + 50) / 100) * 100 }"
}

# Track total output for token counting
OUTPUT=""

emit() {
  local text="$1"
  printf '%s\n' "$text"
  if [[ "$SHOW_TOKEN_COUNT" == "true" ]]; then
    OUTPUT+="$text"$'\n'
  fi
}

emit_raw() {
  local text="$1"
  printf '%s' "$text"
  if [[ "$SHOW_TOKEN_COUNT" == "true" ]]; then
    OUTPUT+="$text"
  fi
}

emit_file() {
  local filepath="$1"
  local content
  content="$(cat "$filepath")"
  printf '%s\n' "$content"
  if [[ "$SHOW_TOKEN_COUNT" == "true" ]]; then
    OUTPUT+="$content"$'\n'
  fi
}

# ============================================================
# Assembly
# ============================================================

emit "# ============================================================"
emit "# SIMULATED SYSTEM PROMPT — preview-prompt.sh"
emit "# ============================================================"
emit ""
emit "# This is an approximation of the full system prompt assembled"
emit "# by buildAgentSystemPrompt() each turn. Sections marked"
emit "# [DYNAMIC: ...] contain runtime-injected values."
emit ""

# --- Part 1: Reference system prompt sections ---
if [[ "$SHOW_REFERENCE" == "true" ]]; then
  emit "# ============================================================"
  emit "# PART 1: System Prompt Sections (reference/system-prompt/)"
  emit "# ============================================================"
  emit ""

  while IFS= read -r filepath; do
    [[ -n "$filepath" ]] || continue

    section_prefix="$(get_section_prefix "$filepath")"
    section_name="$(basename "$filepath")"

    emit "# --- $section_name ---"

    # Check if this section has dynamic content
    placeholder="$(get_dynamic_placeholder "$section_prefix")"
    if [[ -n "$placeholder" ]]; then
      emit "# $placeholder"
    fi

    emit ""
    emit_file "$filepath"
    emit ""
    emit ""
  done < <(get_reference_section_files)
fi

# --- Part 2: Workspace files ---
emit "# ============================================================"
emit "# PART 2: Workspace Files ($WORKSPACE_DIR)"
emit "# ============================================================"
emit ""
emit "# These files are injected under '# Project Context' in the"
emit "# system prompt every turn (see section 15)."
emit ""

emit "# Project Context"
emit ""
emit "The following project context files have been loaded:"
emit "If SOUL.md is present, embody its persona and tone."
emit ""

WORKSPACE_FILE_COUNT=0
for filepath in "$WORKSPACE_DIR"/*; do
  [[ -f "$filepath" ]] || continue

  filename="$(basename "$filepath")"

  emit "## $filename"
  emit ""
  emit_file "$filepath"
  emit ""
  emit ""

  ((WORKSPACE_FILE_COUNT++)) || true
done

if [[ "$WORKSPACE_FILE_COUNT" -eq 0 ]]; then
  emit "(No workspace files found in $WORKSPACE_DIR)"
  emit ""
fi

emit "# ============================================================"
emit "# END OF SIMULATED SYSTEM PROMPT"
emit "# ============================================================"

# --- Token count ---
if [[ "$SHOW_TOKEN_COUNT" == "true" ]]; then
  word_count="$(echo "$OUTPUT" | wc -w | tr -d ' ')"
  raw_tokens="$(awk "BEGIN { printf \"%.0f\", $word_count * $TOKENS_PER_WORD }")"
  rounded_tokens="$(round_to_nearest_hundred "$raw_tokens")"

  echo "" >&2
  echo "--- Token Estimate ---" >&2
  printf "Words:  %s\n" "$(printf "%'d" "$word_count")" >&2
  printf "Tokens: ~%s (words x %s, rounded to nearest 100)\n" "$(printf "%'d" "$rounded_tokens")" "$TOKENS_PER_WORD" >&2
fi
