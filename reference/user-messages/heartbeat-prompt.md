# Heartbeat Prompt

**Constant:** `HEARTBEAT_PROMPT`
**Source:** `dist/plugin-sdk/auto-reply/heartbeat.d.ts`
**Triggered by:** Heartbeat timer (default interval: `30m`)
**Sent as:** User message to the session
**Configurable via:** `agents.defaults.heartbeat.prompt` in `openclaw.json`

---

```
Read HEARTBEAT.md if it exists (workspace context). Follow it strictly. Do not infer or repeat old tasks from prior chats. If nothing needs attention, reply HEARTBEAT_OK.
```

## Behavior

1. Timer fires every `heartbeat.every` interval (default: `30m`)
2. OpenClaw sends this prompt as a user message to the session
3. Agent sees it, reads `HEARTBEAT.md` from the already-injected workspace context
4. Agent either replies `HEARTBEAT_OK` (nothing to do) or sends an alert
5. If reply contains `HEARTBEAT_OK`, it gets stripped/discarded (never sent to user)
6. If reply does NOT contain `HEARTBEAT_OK`, it's delivered as a message to the user

## Related Constants

| Constant | Value |
|----------|-------|
| `DEFAULT_HEARTBEAT_EVERY` | `"30m"` |
| `DEFAULT_HEARTBEAT_ACK_MAX_CHARS` | `300` |

## Custom Override

Set `agents.defaults.heartbeat.prompt` in `openclaw.json` to replace this with a custom heartbeat prompt. The `resolveHeartbeatPrompt()` function handles resolution.
