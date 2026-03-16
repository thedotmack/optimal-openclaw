# OpenClaw Prompt Anatomy — Complete Map

Every single piece of text that gets injected into the system prompt or user messages, where it comes from, and when it fires.

**Source code location:** `/usr/lib/node_modules/openclaw/dist/`
**Config:** `/root/.openclaw/openclaw.json`
**Workspace files:** `/root/.openclaw/workspace-{agentId}/`

---

## 1. System Prompt Builder

**Function:** `buildAgentSystemPrompt()` 
**File:** Main agent runtime bundle (search for `buildAgentSystemPrompt`)
**Called by:** Session initialization, every API call to the LLM

This is the master function. It assembles the entire system prompt from 25 entries (sections 01--20, 21a--21d, 22), each with its own condition for inclusion. The canonical list of sections, their files, hardcoded status, and firing conditions is maintained in [`prompts/manifest.json`](prompts/manifest.json).

> **To view the full section table:** open `prompts/manifest.json` or run `./generate-docs.sh` (requires `jq`).

---

## 2. Workspace Files (Context Injection)

**Loader function:** `loadWorkspaceBootstrapFiles()`
**File:** Agent scope module (search for `loadWorkspaceBootstrapFiles`)
**Max file size:** 2MB per file (`MAX_WORKSPACE_BOOTSTRAP_FILE_BYTES`)

These files are loaded from the workspace directory and injected into `# Project Context`:

| File | Constant Name | Default Filename | Purpose |
|------|-------------|-----------------|---------|
| `AGENTS.md` | `DEFAULT_AGENTS_FILENAME` | `AGENTS.md` | Agent configuration, capabilities, session startup rules |
| `SOUL.md` | `DEFAULT_SOUL_FILENAME` | `SOUL.md` | Persona, tone, worldview, personality |
| `TOOLS.md` | `DEFAULT_TOOLS_FILENAME` | `TOOLS.md` | User-specific tool notes (cameras, SSH hosts, etc.) |
| `IDENTITY.md` | `DEFAULT_IDENTITY_FILENAME` | `IDENTITY.md` | Name, creature type, vibe, emoji |
| `USER.md` | `DEFAULT_USER_FILENAME` | `USER.md` | User info (name, pronouns, preferences) |
| `HEARTBEAT.md` | `DEFAULT_HEARTBEAT_FILENAME` | `HEARTBEAT.md` | Heartbeat task instructions |
| `BOOTSTRAP.md` | `DEFAULT_BOOTSTRAP_FILENAME` | `BOOTSTRAP.md` | First-run onboarding script |
| `MEMORY.md` | `DEFAULT_MEMORY_FILENAME` | `MEMORY.md` | Persistent memory/context index |
| `memory.md` | `DEFAULT_MEMORY_ALT_FILENAME` | `memory.md` | Alt memory filename |

**All of these are injected as-is into the system prompt under `# Project Context`.** The LLM sees them every single turn.

---

## 3. Heartbeat System

### Config
**Location:** `openclaw.json` → `agents.defaults.heartbeat.every`
**Current value:** `"30m"`
**Resolver:** `resolveHeartbeatIntervalMs()` in `heartbeat-runner.d.ts`

### Heartbeat Prompt (what gets sent as a user message)
**Constant:** `HEARTBEAT_PROMPT` (in main agent runtime bundle — search for `HEARTBEAT_PROMPT`)
**Value:** 
```
Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.
```

### Heartbeat Flow
1. Timer fires every `heartbeat.every` interval
2. OpenClaw sends `HEARTBEAT_PROMPT` as a user message to the session
3. Agent sees it, reads HEARTBEAT.md from the already-injected workspace context
4. Agent either replies `HEARTBEAT_OK` (nothing to do) or sends an alert
5. If reply contains `HEARTBEAT_OK`, it gets stripped/discarded (never sent to user)
6. If reply does NOT contain `HEARTBEAT_OK`, it's delivered as a message to the user

### Heartbeat Visibility
**File:** Heartbeat visibility module (search for `heartbeat`)
**Config:** `channels.defaults.heartbeat` and per-channel `heartbeat` settings
**Controls:** Whether heartbeat results are visible or suppressed per channel

---

## 4. Session Reset / New Session Prompt

**Constant:** `BARE_SESSION_RESET_PROMPT`
**Triggered by:** `/new` or `/reset` commands
**Value:**
```
A new session was started via /new or /reset. Execute your Session Startup sequence now - read the required files before responding to the user. Then greet the user in your configured persona, if one is provided. Be yourself - use your defined voice, mannerisms, and mood. Keep it to 1-3 sentences and ask what they want to do. If the runtime model differs from default_model in the system prompt, mention the default model. Do not mention internal steps, files, tools, or reasoning.
```

---

## 5. Post-Compaction Context Refresh

**Triggered by:** Session compaction (when conversation gets too long)
**Extracts from:** `AGENTS.md` sections titled "Session Startup" and "Red Lines"
**Max chars:** 2000
**Value template:**
```
[Post-compaction context refresh]

Session was just compacted. The conversation summary above is a hint, NOT a substitute for your startup sequence. Execute your Session Startup sequence now — read the required files before responding to the user.

Critical rules from AGENTS.md:

{extracted sections}
```

---

## 6. Memory Flush Prompts

**Triggered by:** When conversation transcript exceeds soft threshold (~4000 tokens) or force threshold (~2MB)
**Constants:**
- `DEFAULT_MEMORY_FLUSH_SOFT_TOKENS = 4000`
- `DEFAULT_MEMORY_FLUSH_FORCE_TRANSCRIPT_BYTES = 2MB`
- `DEFAULT_MEMORY_FLUSH_PROMPT` — the user-facing flush instruction
- `DEFAULT_MEMORY_FLUSH_SYSTEM_PROMPT` — system prompt for the flush operation

**Configurable via:** `agents.defaults.memoryFlush` in openclaw.json

---

## 7. Memory Recall Prompt

**Injected when:** Memory tools are available
**Value:**
```
## Memory Recall
Before answering anything about prior work, decisions, dates, people, preferences, or todos: run memory_search on MEMORY.md + memory/*.md; then use memory_get to pull only the needed lines. If low confidence after search, say you checked.
```

---

## 8. Skills Prompt

**Source:** Skills from `/usr/lib/node_modules/openclaw/skills/` and installed ClawHub skills
**Format:** `<available_skills>` XML block listing skill name, description, and SKILL.md location
**Injected into:** System prompt, telling agent to read SKILL.md when a task matches

---

## 9. Inbound Context (Per-Message Metadata)

**Injected as:** `## Inbound Context (trusted metadata)` 
**Contains:** JSON with schema, chat_id, account_id, channel, provider, surface, chat_type
**Purpose:** Tells the agent who sent the message and through which channel

---

## 10. Config File

**Location:** `/root/.openclaw/openclaw.json`
**Key prompt-affecting settings:**

| Path | Effect |
|------|--------|
| `agents.defaults.heartbeat.every` | Heartbeat interval |
| `agents.defaults.heartbeat.prompt` | Custom heartbeat prompt (overrides default) |
| `agents.defaults.model` | Default model for API calls |
| `agents.defaults.extraSystemPrompt` | Additional text injected into system prompt |
| `agents.defaults.memoryFlush.*` | Memory flush thresholds and prompts |
| `channels.defaults.heartbeat` | Heartbeat visibility per channel |
| `agents.{agentId}.*` | Per-agent overrides of all the above |

---

## 11. Tool Descriptions

Every tool the agent can use has a description string that's part of the API call. These come from:
- Hardcoded tool definitions in the OpenClaw source
- Dynamic tool availability filtering based on config/policy

The tool descriptions are NOT in the system prompt text — they're sent as separate `tools` parameter in the API call. But the system prompt references them in `## Tooling`.

---

## Summary: What The Agent Sees Every Turn

```
[System Prompt]
├── Identity (from IDENTITY.md)
├── ## Tooling (available tools list)
├── ## Tool Call Style (hardcoded)
├── ## Safety (hardcoded)
├── ## OpenClaw CLI Quick Reference (hardcoded)
├── ## Skills (available skills XML)
├── ## Model Aliases (from config)
├── ## Workspace (working directory)
├── ## Documentation (docs path)
├── ## Current Date & Time
├── ## Workspace Files (injected)
├──── # Project Context
├──────── AGENTS.md (full file)
├──────── SOUL.md (full file)
├──────── TOOLS.md (full file)
├──────── IDENTITY.md (full file)
├──────── USER.md (full file)
├──────── HEARTBEAT.md (full file)
├──────── BOOTSTRAP.md (full file, if exists)
├──────── MEMORY.md (full file)
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
