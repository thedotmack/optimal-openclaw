# Identity Line

**Section:** 1 of 21
**Source:** `buildAgentSystemPrompt()` — first line
**Hardcoded:** Partially — the template is hardcoded, content comes from the prompt mode
**Condition:** Always included

---

```
You are a personal assistant running inside OpenClaw.
```

> **Note:** When `promptMode` is `"none"`, only this line is returned and no other sections are included. The identity line from `IDENTITY.md` (e.g., "You are {name}, {description}") is injected separately via workspace files under `# Project Context` (see section 13).
