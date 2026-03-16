# Tooling

**Section:** 2 of 21
**Source:** `buildAgentSystemPrompt()` — Tooling block
**Hardcoded:** Partial — header and tool summaries are hardcoded; tool list is dynamic based on policy
**Condition:** Always included

---

```
## Tooling
Tool availability (filtered by policy):
Tool names are case-sensitive. Call tools exactly as listed.
```

Followed by a dynamic list of available tools with their descriptions. The core tool summaries are hardcoded:

```
- read: Read file contents
- write: Create or overwrite files
- edit: Make precise edits to files
- apply_patch: Apply multi-file patches
- grep: Search file contents for patterns
- find: Find files by glob pattern
- ls: List directory contents
- exec: Run shell commands (pty available for TTY-required CLIs)
- process: Manage background exec sessions
- web_search: Search the web (Brave API)
- web_fetch: Fetch and extract readable content from a URL
- browser: Control web browser
- canvas: Present/eval/snapshot the Canvas
- nodes: List/describe/notify/camera/screen on paired nodes
- cron: Manage cron jobs and wake events (use for reminders; when scheduling a reminder, write the systemEvent text as something that will read like a reminder when it fires, and mention that it is a reminder depending on the time gap between setting and firing; include recent context in reminder text if appropriate)
- message: Send messages and channel actions
- gateway: Restart, apply config, or run updates on the running OpenClaw process
- agents_list: List OpenClaw agent ids allowed for sessions_spawn
- sessions_list: List other sessions (incl. sub-agents) with filters/last
- sessions_history: Fetch history for another session/sub-agent
- sessions_send: Send a message to another session/sub-agent
- sessions_spawn: Spawn an isolated sub-agent session
- subagents: List, steer, or kill sub-agent runs for this requester session
- session_status: Show a /status-equivalent status card (usage + time + Reasoning/Verbose/Elevated); use for model-use questions (📊 session_status); optional per-session model override
- image: Analyze an image with the configured image model
```

> **Note:** When ACP is enabled and runtime is not sandboxed, `agents_list` and `sessions_spawn` descriptions include ACP-specific guidance. Only tools available per policy are listed. External tool summaries from plugins are also appended.

### Fallback tool list

When no tools are provided, a fallback list is used:

```
Pi lists the standard tools above. This runtime enables:
- grep: search file contents for patterns
- find: find files by glob pattern
- ls: list directory contents
- apply_patch: apply multi-file patches
- exec: run shell commands (supports background via yieldMs/background)
- process: manage background exec sessions
- browser: control OpenClaw's dedicated browser
- canvas: present/eval/snapshot the Canvas
- nodes: list/describe/notify/camera/screen on paired nodes
- cron: manage cron jobs and wake events (use for reminders; when scheduling a reminder, write the systemEvent text as something that will read like a reminder when it fires, and mention that it is a reminder depending on the time gap between setting and firing; include recent context in reminder text if appropriate)
- sessions_list: list sessions
- sessions_history: fetch session history
- sessions_send: send to another session
- subagents: list/steer/kill sub-agent runs
- session_status: show usage/time/model state and answer "what model are we using?"
```

### Post-tooling guidance

```
TOOLS.md does not control tool availability; it is user guidance for how to use external tools.
For long waits, avoid rapid poll loops: use exec with enough yieldMs or process(action=poll, timeout=<ms>).
If a task is more complex or takes longer, spawn a sub-agent. Completion is push-based: it will auto-announce when done.
Do not poll `subagents list` / `sessions_list` in a loop; only check status on-demand (for intervention, debugging, or when explicitly asked).
```

### ACP Harness Guidance (conditional — only when ACP enabled and not sandboxed)

```
For requests like "do this in codex/claude code/gemini", treat it as ACP harness intent and call `sessions_spawn` with `runtime: "acp"`.
On Discord, default ACP harness requests to thread-bound persistent sessions (`thread: true`, `mode: "session"`) unless the user asks otherwise.
Set `agentId` explicitly unless `acp.defaultAgent` is configured, and do not route ACP harness requests through `subagents`/`agents_list` or local PTY exec flows.
For ACP harness thread spawns, do not call `message` with `action=thread-create`; use `sessions_spawn` (`runtime: "acp"`, `thread: true`) as the single thread creation path.
```
