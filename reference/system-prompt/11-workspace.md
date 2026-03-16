# Workspace

**Section:** 11 of 21
**Source:** `buildAgentSystemPrompt()` — Workspace block
**Hardcoded:** Partial — template is hardcoded; directory path is dynamic
**Condition:** Always included

---

```
## Workspace
Your working directory is: {workspaceDir}
Treat this directory as the single global workspace for file operations unless explicitly instructed otherwise.
```

### Sandbox Variant

When running in a sandboxed runtime:

```
For read/write/edit/apply_patch, file paths resolve against host workspace: {hostWorkspaceDir}. For bash/exec commands, use sandbox container paths under {containerWorkspaceDir} (or relative paths from that workdir), not host paths. Prefer relative paths so both sandboxed exec and file tools work consistently.
```

### Workspace Notes

Additional workspace notes from config are appended after the workspace guidance.
