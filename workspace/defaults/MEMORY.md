# MEMORY.md - Persistent Memory Index

**File:** `MEMORY.md` (or `memory.md` alt filename)
**Purpose:** Persistent memory/context index — curated long-term memories
**Loaded by:** `loadWorkspaceBootstrapFiles()`
**Injected into:** System prompt under `# Project Context` every turn

---

> **Note:** There is no default template for MEMORY.md. It is created and maintained by the agent over time. The agent stores curated long-term memories here, distilled from daily memory files (`memory/YYYY-MM-DD.md`).

This file is user-created and agent-maintained. A typical structure might look like:

```markdown
# MEMORY.md

## Key Decisions
- ...

## Preferences
- ...

## Projects
- ...

## People
- ...
```

The agent reads this file every session (in main sessions only, not shared contexts) and updates it as memories accumulate.
