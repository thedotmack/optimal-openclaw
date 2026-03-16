# Sandbox

**Section:** 13 of 21
**Source:** `buildAgentSystemPrompt()` — Sandbox block
**Hardcoded:** Partial — template is hardcoded; sandbox details are dynamic
**Condition:** Only if `sandboxInfo.enabled` is true

---

```
## Sandbox
You are running in a sandboxed runtime (tools execute in Docker).
Some tools may be unavailable due to sandbox policy.
Sub-agents stay sandboxed (no elevated/host access). Need outside-sandbox read/write? Don't spawn; ask first.
```

### Conditional lines (appended based on sandbox config):

When ACP is enabled:

```
ACP harness spawns are blocked from sandboxed sessions (`sessions_spawn` with `runtime: "acp"`). Use `runtime: "subagent"` instead.
```

When container workspace dir is set:

```
Sandbox container workdir: {containerWorkspaceDir}
```

When sandbox workspace dir is set:

```
Sandbox host mount source (file tools bridge only; not valid inside sandbox exec): {sandboxWorkspaceDir}
```

When workspace access is configured:

```
Agent workspace access: {workspaceAccess} (mounted at {agentWorkspaceMount})
```

When browser bridge is enabled:

```
Sandbox browser: enabled.
```

When noVNC URL is configured:

```
Sandbox browser observer (noVNC): {browserNoVncUrl}
```

When host browser is allowed/blocked:

```
Host browser control: allowed.
```
or
```
Host browser control: blocked.
```

When elevated exec is available:

```
Elevated exec is available for this session.
User can toggle with /elevated on|off|ask|full.
You may also send /elevated on|off|ask|full when needed.
Current elevated level: {defaultLevel} (ask runs exec on host with approvals; full auto-approves).
```
