# Memory Flush Prompts

**Constants:** `DEFAULT_MEMORY_FLUSH_PROMPT`, `DEFAULT_MEMORY_FLUSH_SYSTEM_PROMPT`
**Source:** `dist/plugin-sdk/auto-reply/reply/memory-flush.d.ts`
**Triggered by:** When conversation transcript exceeds soft threshold (~4000 tokens) or force threshold (~2MB)
**Configurable via:** `agents.defaults.memoryFlush.*` in `openclaw.json`

---

## Memory Flush User Prompt

Sent as a user message to trigger the memory flush:

```
Pre-compaction memory flush. Store durable memories only in memory/YYYY-MM-DD.md (create memory/ if needed). Treat workspace bootstrap/reference files such as MEMORY.md, SOUL.md, TOOLS.md, and AGENTS.md as read-only during this flush; never overwrite, replace, or edit them. If memory/YYYY-MM-DD.md already exists, APPEND new content only and do not overwrite existing entries. Do NOT create timestamped variant files (e.g., YYYY-MM-DD-HHMM.md); always use the canonical YYYY-MM-DD.md filename. If nothing to store, reply with NO_REPLY.
```

> **Note:** At runtime, `YYYY-MM-DD` is replaced with the actual date stamp (e.g., `2026-03-14`).

## Memory Flush System Prompt

Injected as the system prompt for the flush operation:

```
Pre-compaction memory flush turn. The session is near auto-compaction; capture durable memories to disk. Store durable memories only in memory/YYYY-MM-DD.md (create memory/ if needed). Treat workspace bootstrap/reference files such as MEMORY.md, SOUL.md, TOOLS.md, and AGENTS.md as read-only during this flush; never overwrite, replace, or edit them. If memory/YYYY-MM-DD.md already exists, APPEND new content only and do not overwrite existing entries. You may reply, but usually NO_REPLY is correct.
```

## Safety Hint Constants

These hints are always included (enforced by `ensureMemoryFlushSafetyHints()`):

| Constant | Value |
|----------|-------|
| `MEMORY_FLUSH_TARGET_HINT` | `Store durable memories only in memory/YYYY-MM-DD.md (create memory/ if needed).` |
| `MEMORY_FLUSH_READ_ONLY_HINT` | `Treat workspace bootstrap/reference files such as MEMORY.md, SOUL.md, TOOLS.md, and AGENTS.md as read-only during this flush; never overwrite, replace, or edit them.` |
| `MEMORY_FLUSH_APPEND_ONLY_HINT` | `If memory/YYYY-MM-DD.md already exists, APPEND new content only and do not overwrite existing entries.` |

## Threshold Constants

| Constant | Default Value |
|----------|--------------|
| `DEFAULT_MEMORY_FLUSH_SOFT_TOKENS` | `4000` |
| `DEFAULT_MEMORY_FLUSH_FORCE_TRANSCRIPT_BYTES` | ~2MB |

## Config Override

Set `agents.defaults.memoryFlush.prompt` and `agents.defaults.memoryFlush.systemPrompt` in `openclaw.json` to replace the defaults. The safety hints are always appended even to custom prompts.
