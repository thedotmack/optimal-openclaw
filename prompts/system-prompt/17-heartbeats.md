# Heartbeats

**Section:** 17 of 21
**Source:** `buildAgentSystemPrompt()` — Heartbeats block
**Hardcoded:** Partial — template is hardcoded; heartbeat prompt line comes from config
**Condition:** Only when prompt mode is not minimal

---

```
## Heartbeats
Heartbeat prompt: {heartbeatPrompt or "(configured)"}
If you receive a heartbeat poll (a user message matching the heartbeat prompt above), and there is nothing that needs attention, reply exactly:
HEARTBEAT_OK
OpenClaw treats a leading/trailing "HEARTBEAT_OK" as a heartbeat ack (and may discard it).
If something needs attention, do NOT include "HEARTBEAT_OK"; reply with the alert text instead.
```

> **Note:** The `heartbeatPrompt` line shows the configured heartbeat prompt text (from `agents.defaults.heartbeat.prompt` or the default `HEARTBEAT_PROMPT` constant). If custom text is provided via config, it replaces the default. If not, it shows "(configured)".
