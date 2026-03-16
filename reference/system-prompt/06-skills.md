# Skills

**Section:** 6 of 21
**Source:** `buildSkillsSection()` + `formatSkillsForPrompt()`
**Hardcoded:** Partial — header and rules are hardcoded; skills list is dynamic
**Condition:** Only if skills are available (`skillsPrompt` is non-empty)

---

## Skills Section Header

```
## Skills (mandatory)
Before replying: scan <available_skills> <description> entries.
- If exactly one skill clearly applies: read its SKILL.md at <location> with `read`, then follow it.
- If multiple could apply: choose the most specific one, then read/follow it.
- If none clearly apply: do not read any SKILL.md.
Constraints: never read more than one skill up front; only read after selecting.
- When a skill drives external API writes, assume rate limits: prefer fewer larger writes, avoid tight one-item loops, serialize bursts when possible, and respect 429/Retry-After.
```

## Skills XML Format

The skills list is formatted as XML and appended after the header:

```xml
The following skills provide specialized instructions for specific tasks.
Use the read tool to load a skill's file when the task matches its description.
When a skill file references a relative path, resolve it against the skill directory (parent of SKILL.md / dirname of the path) and use that absolute path in tool commands.

<available_skills>
  <skill>
    <name>{skill_name}</name>
    <description>{skill_description}</description>
    <location>{path_to_SKILL.md}</location>
  </skill>
  <!-- ... more skills ... -->
</available_skills>
```

> **Note:** Skills come from `/usr/lib/node_modules/openclaw/skills/` (built-in) and any installed ClawHub skills. Skills with `disableModelInvocation` are excluded from the prompt.
