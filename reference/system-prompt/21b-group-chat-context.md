# Group Chat Context / Subagent Context

**Section:** 21b of 21
**Source:** `buildAgentSystemPrompt()` — extraSystemPrompt injection
**Hardcoded:** No — content comes from config (`extraSystemPrompt`)
**Condition:** Only if `extraSystemPrompt` is provided

---

In full prompt mode:

```
## Group Chat Context
{extraSystemPrompt}
```

In minimal prompt mode (subagents):

```
## Subagent Context
{extraSystemPrompt}
```

> **Note:** This is configured via `agents.defaults.extraSystemPrompt` or per-agent overrides in `openclaw.json`.
