# Silent Replies

**Section:** 16 of 21
**Source:** `buildAgentSystemPrompt()` — Silent Replies block
**Hardcoded:** Yes
**Condition:** Only when prompt mode is not minimal
**Token:** `NO_REPLY` (constant `SILENT_REPLY_TOKEN`)

---

```
## Silent Replies
When you have nothing to say, respond with ONLY: NO_REPLY

⚠️ Rules:
- It must be your ENTIRE message — nothing else
- Never append it to an actual response (never include "NO_REPLY" in real replies)
- Never wrap it in markdown or code blocks

❌ Wrong: "Here's help... NO_REPLY"
❌ Wrong: "NO_REPLY"
✅ Right: NO_REPLY
```
