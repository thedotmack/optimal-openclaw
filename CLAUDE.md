# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**optimal-openclaw** is a technical reference and customization repo for the [OpenClaw](https://clawhub.io) agent framework's prompt system. It contains every piece of text injected into OpenClaw's system prompt and user messages — extracted, documented, and editable. There is no build system, no compiled code, and no tests. The repo is entirely Markdown files, JSON, and one Bash script.

## Key Commands

```bash
# Sync edited workspace templates back to a local OpenClaw installation
./sync-prompts.sh

# Preview what would change without modifying anything
./sync-prompts.sh --dry-run

# Target a specific OpenClaw installation
./sync-prompts.sh --openclaw-path /path/to/openclaw

# After syncing, restart OpenClaw to pick up changes
openclaw gateway restart
```

## Architecture

### Prompt Assembly Pipeline

OpenClaw's `buildAgentSystemPrompt()` assembles the system prompt from 22 numbered sections every turn. These are documented in `prompts/system-prompt/01-identity.md` through `22-inbound-context.md`. Section numbers define assembly order — preserve them when editing.

`PROMPT-ANATOMY.md` is the master reference for the full pipeline.

### Directory Layout

- **`prompts/system-prompt/`** — 22 numbered sections assembled into the system prompt. Each file documents one section's content, whether it's hardcoded vs. configurable, and under what conditions it fires.
- **`prompts/workspace-files/defaults/`** — Template workspace files (AGENTS.md, SOUL.md, IDENTITY.md, USER.md, etc.) that get injected whole into the system prompt every turn. These are the primary files users customize.
- **`prompts/workspace-files/dev-variants/`** — Dev agent (C-3PO) variants of workspace files.
- **`prompts/user-messages/`** — Prompts sent as user messages (heartbeat, session reset, post-compaction, memory flush). Not part of the system prompt.
- **`prompts/config/`** — `openclaw-defaults.json` reference for config-driven prompt behavior.
- **`prompts/skills/`** — XML template format for skill injection.
- **`prompts/manifest.json`** — Machine-readable index of all prompts with metadata (conditions, configurability, triggers).

### Hardcoded vs. Configurable vs. Dynamic

Each system prompt section in `manifest.json` has a `hardcoded` field:
- `true` — Text is baked into OpenClaw source; editing here is documentation only
- `false` — Fully user-configurable (e.g., `extraSystemPrompt`)
- `"partial"` — Template with dynamic values filled at runtime (e.g., tool lists, model names, timestamps)

Workspace files (`prompts/workspace-files/`) are fully user-editable and sync back via `sync-prompts.sh`.

## Editing Guidelines

- Keep `manifest.json` synchronized when adding or restructuring prompt files.
- Workspace files are injected whole every turn — keep them focused and concise to avoid bloating the context window.
- System prompt section numbering (01–22) reflects assembly order. Don't renumber without understanding downstream dependencies.
- Always `--dry-run` before syncing to a live installation.
