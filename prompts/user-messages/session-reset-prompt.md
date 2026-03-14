# Session Reset Prompt

**Constant:** `BARE_SESSION_RESET_PROMPT_BASE`
**Function:** `buildBareSessionResetPrompt(cfg, nowMs)`
**Source:** `dist/plugin-sdk/auto-reply/reply/session-reset-prompt.d.ts`
**Triggered by:** `/new` or `/reset` commands
**Sent as:** User message to the session

---

## Base Prompt

```
A new session was started via /new or /reset. Run your Session Startup sequence - read the required files before responding to the user. Then greet the user in your configured persona, if one is provided. Be yourself - use your defined voice, mannerisms, and mood. Keep it to 1-3 sentences and ask what they want to do. If the runtime model differs from default_model in the system prompt, mention the default model. Do not mention internal steps, files, tools, or reasoning.
```

## With Date/Time (runtime)

The `buildBareSessionResetPrompt()` function appends a current date/time line so agents know which daily memory files to read during their Session Startup sequence. Without this, agents on `/new` or `/reset` guess the date from their training cutoff.

The appended line format:

```
Current time: {formattedTime} ({userTimezone}) / {ISO UTC time}
```

Example full prompt at runtime:

```
A new session was started via /new or /reset. Run your Session Startup sequence - read the required files before responding to the user. Then greet the user in your configured persona, if one is provided. Be yourself - use your defined voice, mannerisms, and mood. Keep it to 1-3 sentences and ask what they want to do. If the runtime model differs from default_model in the system prompt, mention the default model. Do not mention internal steps, files, tools, or reasoning.
Current time: Mar 14, 2026, 9:31 AM (America/New_York) / 2026-03-14 13:31 UTC
```
