# Current Date & Time

**Section:** 10 of 21
**Source:** `buildTimeSection()` + session_status reference
**Hardcoded:** Partial — template is hardcoded; timezone and time are dynamic
**Condition:** Only if `userTimezone` is configured

---

When the user timezone is set, the following is included:

```
If you need the current date, time, or day of week, run session_status (📊 session_status).
```

Additionally, the time section header:

```
## Current Date & Time
Time zone: {userTimezone}
```

> **Note:** The actual time is not injected directly into the system prompt itself. Instead, agents are instructed to call `session_status` to get the current time. Date/time lines are appended to user-message prompts (session reset, post-compaction, memory flush) via `appendCronStyleCurrentTimeLine()`.

### Time Line Format (for user messages)

```
Current time: {formattedTime} ({userTimezone}) / {ISO UTC time}
```

Example:

```
Current time: Mar 14, 2026, 9:31 AM (America/New_York) / 2026-03-14 13:31 UTC
```
