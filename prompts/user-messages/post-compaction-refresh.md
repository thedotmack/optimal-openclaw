# Post-Compaction Context Refresh

**Function:** `readPostCompactionContext(workspaceDir, cfg, nowMs)`
**Source:** `dist/auth-profiles-*.js` — `src/auto-reply/reply/post-compaction-context.ts`
**Triggered by:** Session compaction (when conversation gets too long)
**Sent as:** System event injected into the session
**Max content chars:** 3000

---

## Default Template (when using default sections: "Session Startup" + "Red Lines")

```
[Post-compaction context refresh]

Session was just compacted. The conversation summary above is a hint, NOT a substitute for your startup sequence. Run your Session Startup sequence — read the required files before responding to the user.

Critical rules from AGENTS.md:

{extracted sections from AGENTS.md}

Current time: {formattedTime} ({userTimezone}) / {ISO UTC time}
```

## Custom Sections Template (when configured via `agents.defaults.compaction.postCompactionSections`)

```
[Post-compaction context refresh]

Session was just compacted. The conversation summary above is a hint, NOT a substitute for your full startup sequence. Re-read the sections injected below ({section_names}) and follow your configured startup procedure before responding to the user.

Injected sections from AGENTS.md ({section_names}):

{extracted sections from AGENTS.md}

Current time: {formattedTime} ({userTimezone}) / {ISO UTC time}
```

## Section Extraction

- **Default sections:** `["Session Startup", "Red Lines"]`
- **Legacy fallback sections:** `["Every Session", "Safety"]` (used if default sections not found and no custom sections configured)
- **Configurable via:** `agents.defaults.compaction.postCompactionSections` in `openclaw.json`
- Matches H2 (`##`) or H3 (`###`) headings case-insensitively
- Skips content inside fenced code blocks
- Content is truncated at 3000 chars with `...[truncated]...` marker
- `YYYY-MM-DD` placeholders are replaced with the actual date
