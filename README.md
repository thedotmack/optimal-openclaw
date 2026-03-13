# optimal-openclaw

A complete technical reference for the [OpenClaw](https://clawhub.io) agent system prompt architecture — every piece of text injected into the system prompt and user messages, where it comes from, and when it fires.

## What is OpenClaw?

OpenClaw is a Node.js-based LLM agent framework that manages AI agent personalities, workspace context, memory, and multi-channel messaging (e.g. Slack). Agents are configured via a workspace directory of Markdown files and a central `openclaw.json` config file.

## What's in This Repo

| File | Description |
|------|-------------|
| [`PROMPT-ANATOMY.md`](./PROMPT-ANATOMY.md) | Complete map of the OpenClaw system prompt pipeline |

## Prompt Anatomy Overview

[`PROMPT-ANATOMY.md`](./PROMPT-ANATOMY.md) documents the full prompt construction pipeline assembled by `buildAgentSystemPrompt()`. It covers:

1. **System Prompt Builder** — the 21 sections assembled every turn, in order (identity, tooling, safety, workspace context, runtime info, etc.)
2. **Workspace Files** — the Markdown files (`AGENTS.md`, `SOUL.md`, `IDENTITY.md`, `USER.md`, `MEMORY.md`, etc.) loaded from the workspace directory and injected into every prompt
3. **Heartbeat System** — periodic background checks sent as user messages on a configurable timer
4. **Session Reset Prompt** — the message injected on `/new` or `/reset`
5. **Post-Compaction Refresh** — context re-injection after conversation compaction
6. **Memory Flush Prompts** — triggered when the transcript exceeds soft/hard token thresholds
7. **Memory Recall Prompt** — injected when memory tools are available
8. **Skills Prompt** — XML block advertising installed ClawHub skills
9. **Inbound Context** — per-message trusted metadata (channel, surface, account, etc.)
10. **Config Reference** — the `openclaw.json` keys that affect prompt behavior

## Quick Reference: What the Agent Sees Every Turn

```
[System Prompt]
├── Identity (from IDENTITY.md)
├── ## Tooling (available tools list)
├── ## Tool Call Style
├── ## Safety
├── ## Skills (available skills XML)
├── ## Model Aliases (from config)
├── ## Workspace (working directory)
├── ## Documentation (docs path)
├── ## Current Date & Time
├── ## Workspace Files (injected)
│   └── # Project Context
│       ├── AGENTS.md
│       ├── SOUL.md
│       ├── TOOLS.md
│       ├── IDENTITY.md
│       ├── USER.md
│       ├── HEARTBEAT.md
│       ├── BOOTSTRAP.md (if present)
│       └── MEMORY.md
├── ## Silent Replies (NO_REPLY rules)
├── ## Heartbeats (HEARTBEAT_OK rules)
├── ## Runtime (model, host, channel info)
├── ## Reply Tags
├── ## Messaging (routing rules)
├── ## Inbound Context (per-message JSON metadata)
└── ## Reactions (if configured)

[User Message]
├── The actual user text
├── OR: HEARTBEAT_PROMPT (on heartbeat tick)
├── OR: BARE_SESSION_RESET_PROMPT (on /new or /reset)
├── OR: Post-compaction refresh (after compaction)
└── OR: Memory flush prompt (when transcript too large)
```

## Key Config Paths (`openclaw.json`)

| Path | Effect |
|------|--------|
| `agents.defaults.heartbeat.every` | Heartbeat interval (e.g. `"20m"`) |
| `agents.defaults.heartbeat.prompt` | Custom heartbeat prompt override |
| `agents.defaults.model` | Default LLM model |
| `agents.defaults.extraSystemPrompt` | Additional text injected into system prompt |
| `agents.defaults.memoryFlush.*` | Memory flush thresholds and prompts |
| `channels.defaults.heartbeat` | Heartbeat visibility (show/suppress per channel) |
| `agents.{agentId}.*` | Per-agent overrides of all the above |

## Source Locations

OpenClaw runs as a Node.js package. The source files referenced throughout the docs are:

| File | Purpose |
|------|---------|
| `dist/pi-embedded-Cf0EGRq3.js` | Main agent runtime (`buildAgentSystemPrompt()`, `HEARTBEAT_PROMPT`) |
| `dist/agent-scope-XRTwmJgy.js` | Workspace file loader (`loadWorkspaceBootstrapFiles()`) |
| `dist/heartbeat-visibility-_K4bnQDH.js` | Heartbeat channel visibility logic |
| `/usr/lib/node_modules/openclaw/docs` | Built-in documentation referenced in system prompt |
| `/usr/lib/node_modules/openclaw/skills/` | Built-in skills directory |

## License

MIT
