# OpenClaw Prompts — Complete Extracted Reference

Every prompt, hardcoded string, and configurable text from the [OpenClaw](https://clawhub.io) agent framework, extracted into individual files for easy review and editing.

## Directory Structure

```
prompts/
├── manifest.json                                    # Index of all prompts with metadata
└── README.md                                        # This file

reference/                                           # Read-only documentation (not syncable)
├── system-prompt/                                   # System prompt sections (assembled every turn)
│   ├── 01-identity.md                               # Identity line
│   ├── 02-tooling.md                                # Tool availability + summaries
│   ├── 03-tool-call-style.md                        # Tool call narration rules
│   ├── 04-safety.md                                 # Safety rules
│   ├── 05-cli-quick-reference.md                    # OpenClaw CLI commands
│   ├── 06-skills.md                                 # Skills section + XML format
│   ├── 07-memory-recall.md                          # Memory recall instructions
│   ├── 08-self-update.md                            # Self-update rules
│   ├── 09-model-aliases.md                          # Model alias mappings
│   ├── 10-current-datetime.md                       # Date/time injection
│   ├── 11-workspace.md                              # Working directory info
│   ├── 12-documentation.md                          # Docs path + links
│   ├── 13-sandbox.md                                # Sandbox runtime info
│   ├── 14-authorized-senders.md                     # Owner identity
│   ├── 15-workspace-files-and-project-context.md    # Workspace file injection
│   ├── 16-silent-replies.md                         # NO_REPLY rules
│   ├── 17-heartbeats.md                             # HEARTBEAT_OK rules
│   ├── 18-runtime.md                                # Runtime info line
│   ├── 19-reply-tags.md                             # Reply tag format
│   ├── 20-messaging.md                              # Message routing rules
│   ├── 21a-voice-tts.md                             # TTS hint
│   ├── 21b-group-chat-context.md                    # Group/subagent context
│   ├── 21c-reactions.md                             # Reaction guidance
│   ├── 21d-reasoning-format.md                      # Reasoning tag format
│   └── 22-inbound-context.md                        # Per-message metadata
├── user-messages/                                   # Prompts sent as user messages
│   ├── heartbeat-prompt.md                          # HEARTBEAT_PROMPT
│   ├── session-reset-prompt.md                      # BARE_SESSION_RESET_PROMPT
│   ├── post-compaction-refresh.md                   # Post-compaction context
│   └── memory-flush-prompts.md                      # Memory flush prompts
├── skills/                                          # Skills prompt format
│   └── skills-prompt-template.md                    # XML format + built-in skills list
└── config/                                          # Config-driven prompt settings
    └── openclaw-defaults.json                       # Default config values

workspace/                                           # Editable templates (synced via sync-prompts.sh)
├── README.md                                        # Overview of workspace files
├── defaults/                                        # Default templates
│   ├── AGENTS.md                                    # Agent config + session rules
│   ├── SOUL.md                                      # Persona + personality
│   ├── TOOLS.md                                     # User tool notes
│   ├── IDENTITY.md                                  # Agent identity
│   ├── USER.md                                      # User profile
│   ├── HEARTBEAT.md                                 # Heartbeat tasks
│   ├── BOOTSTRAP.md                                 # First-run onboarding
│   ├── BOOT.md                                      # Startup hook
│   └── MEMORY.md                                    # Memory index (placeholder)
└── dev-variants/                                    # Dev agent (C-3PO) templates
    ├── AGENTS.dev.md
    ├── SOUL.dev.md
    ├── TOOLS.dev.md
    ├── IDENTITY.dev.md
    └── USER.dev.md
```

## How to Use

### Reviewing Prompts

Each file contains the **actual prompt text** extracted from the OpenClaw source code, enclosed in code blocks. Files include:

- **Section number and name** — matching the assembly order in `buildAgentSystemPrompt()`
- **Source location** — which function/constant generates the text
- **Hardcoded status** — whether the text is hardcoded, dynamic, or partially both
- **Condition** — when the section is included in the prompt
- **The actual prompt text** — in fenced code blocks, ready to review

### Editing Prompts

1. Edit workspace template files in `workspace/defaults/` or `workspace/dev-variants/`
2. Run `./sync-prompts.sh` to sync changes back to your OpenClaw installation
3. Restart OpenClaw to pick up changes

**Note:** Files in `reference/` are read-only documentation of hardcoded/dynamic prompt sections. Only `workspace/` files are syncable.

### What's in `manifest.json`

A machine-readable index of every prompt file with metadata about its source, condition, and configurability. Useful for building tooling around prompt management.

## Prompt Assembly Order

The system prompt is assembled by `buildAgentSystemPrompt()` from 25 entries (sections 01--20, 21a--21d, 22). The canonical section list -- including file paths, hardcoded status, and firing conditions -- lives in [`manifest.json`](manifest.json).

> **To view the full section table:** open `manifest.json` or run `./generate-docs.sh` from the repo root (requires `jq`).

## User-Message Prompts

These are sent as user messages (not in the system prompt):

| Prompt | File | Trigger |
|--------|------|---------|
| Heartbeat | `heartbeat-prompt.md` | Timer (default: 30m) |
| Session Reset | `session-reset-prompt.md` | `/new` or `/reset` |
| Post-Compaction | `post-compaction-refresh.md` | Conversation compaction |
| Memory Flush | `memory-flush-prompts.md` | Transcript exceeds threshold |

## Source

Extracted from OpenClaw `2026.3.13` installed via `npm install -g openclaw`.
