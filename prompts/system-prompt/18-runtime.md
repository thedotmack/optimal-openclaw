# Runtime

**Section:** 18 of 21
**Source:** `buildAgentSystemPrompt()` + `buildRuntimeLine()`
**Hardcoded:** Partial — template is hardcoded; all values are dynamic
**Condition:** Always included

---

```
## Runtime
Runtime: agent={agentId} | host={hostname} | repo={repoRoot} | os={os} ({arch}) | node={nodeVersion} | model={model} | default_model={defaultModel} | shell={shell} | channel={channel} | capabilities={capabilities} | thinking={thinkLevel}
Reasoning: {reasoningLevel} (hidden unless on/stream). Toggle /reasoning; /status shows Reasoning when enabled.
```

### Runtime Line Format

The runtime line is a pipe-delimited string of key=value pairs. Only non-empty values are included:

| Key | Source |
|-----|--------|
| `agent` | `runtimeInfo.agentId` |
| `host` | `runtimeInfo.host` |
| `repo` | `runtimeInfo.repoRoot` |
| `os` | `runtimeInfo.os` (with optional arch) |
| `node` | `runtimeInfo.node` |
| `model` | `runtimeInfo.model` |
| `default_model` | `runtimeInfo.defaultModel` |
| `shell` | `runtimeInfo.shell` |
| `channel` | From channel context |
| `capabilities` | Channel capabilities (comma-separated) or "none" |
| `thinking` | Default think level or "off" |
