# Workspace Files (injected)

**Section:** 15 of 21
**Source:** `buildAgentSystemPrompt()` — Workspace Files header + Project Context
**Hardcoded:** Partial — header is hardcoded; file contents are loaded dynamically
**Condition:** Always included (header); Project Context only if context files exist

---

## Header

```
## Workspace Files (injected)
These user-editable files are loaded by OpenClaw and included below in Project Context.
```

## Project Context

When workspace files are present, they are injected under a `# Project Context` heading:

```
# Project Context

The following project context files have been loaded:
If SOUL.md is present, embody its persona and tone. Avoid stiff, generic replies; follow its guidance unless higher-priority instructions override it.
```

> **Note:** The SOUL.md hint line is only included if a file ending in `soul.md` (case-insensitive) is detected among the context files.

### Bootstrap Truncation Warning

If any workspace files were truncated during loading:

```
⚠ Bootstrap truncation warning:
- {warning_line_1}
- {warning_line_2}
```

### File Injection Format

Each workspace file is injected as:

```
## {file_path}

{file_content}
```

The files loaded (from workspace directory) are:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Agent configuration, capabilities, session startup rules |
| `SOUL.md` | Persona, tone, worldview, personality |
| `TOOLS.md` | User-specific tool notes |
| `IDENTITY.md` | Name, creature type, vibe, emoji |
| `USER.md` | User info (name, pronouns, preferences) |
| `HEARTBEAT.md` | Heartbeat task instructions |
| `BOOTSTRAP.md` | First-run onboarding script (if exists) |
| `MEMORY.md` | Persistent memory/context index |

**Max file size:** 2MB per file (`MAX_WORKSPACE_BOOTSTRAP_FILE_BYTES`)

> **Note:** All workspace files are injected as-is into the system prompt every turn. The LLM sees them in full.
