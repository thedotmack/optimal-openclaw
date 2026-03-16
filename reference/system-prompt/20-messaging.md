# Messaging

**Section:** 20 of 21
**Source:** `buildMessagingSection()`
**Hardcoded:** Partial — core rules are hardcoded; message tool hints are dynamic
**Condition:** Only when prompt mode is not minimal

---

```
## Messaging
- Reply in current session → automatically routes to the source channel (Signal, Telegram, etc.)
- Cross-session messaging → use sessions_send(sessionKey, message)
- Sub-agent orchestration → use subagents(action=list|steer|kill)
- Runtime-generated completion events may ask for a user update. Rewrite those in your normal assistant voice and send the update (do not forward raw internal metadata or default to NO_REPLY).
- Never use exec/curl for provider messaging; OpenClaw handles all routing internally.
```

### Message Tool Section (conditional — only if `message` tool is available)

```
### message tool
- Use `message` for proactive sends + channel actions (polls, reactions, etc.).
- For `action=send`, include `to` and `message`.
- If multiple channels are configured, pass `channel` ({channel_options}).
- If you use `message` (`action=send`) to deliver your user-visible reply, respond with ONLY: NO_REPLY (avoid duplicate replies).
```

### Inline Buttons (conditional)

When inline buttons are enabled:

```
- Inline buttons supported. Use `action=send` with `buttons=[[{text,callback_data,style?}]]`; `style` can be `primary`, `success`, or `danger`.
```

When inline buttons are not enabled:

```
- Inline buttons not enabled for {channel}. If you need them, ask to set {channel}.capabilities.inlineButtons ("dm"|"group"|"all"|"allowlist").
```
