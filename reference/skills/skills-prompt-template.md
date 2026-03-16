# Skills Prompt Template

**Source:** `formatSkillsForPrompt()` from `@mariozechner/pi-coding-agent`
**Injected into:** System prompt via `buildSkillsSection()`
**Condition:** Only when skills are available

---

## Format

The skills prompt consists of two parts:

### 1. Skills Section Header (from `buildSkillsSection()`)

See [`../system-prompt/06-skills.md`](../system-prompt/06-skills.md) for the full header text.

### 2. Skills XML Block (from `formatSkillsForPrompt()`)

```xml


The following skills provide specialized instructions for specific tasks.
Use the read tool to load a skill's file when the task matches its description.
When a skill file references a relative path, resolve it against the skill directory (parent of SKILL.md / dirname of the path) and use that absolute path in tool commands.

<available_skills>
  <skill>
    <name>weather</name>
    <description>Check weather conditions and forecasts</description>
    <location>/usr/lib/node_modules/openclaw/skills/weather/SKILL.md</location>
  </skill>
  <skill>
    <name>github</name>
    <description>GitHub operations and issue management</description>
    <location>/usr/lib/node_modules/openclaw/skills/github/SKILL.md</location>
  </skill>
  <!-- ... more skills ... -->
</available_skills>
```

## Built-in Skills

The following skills are bundled with OpenClaw (from `/usr/lib/node_modules/openclaw/skills/`):

| Skill | Directory |
|-------|-----------|
| 1password | `skills/1password/` |
| apple-notes | `skills/apple-notes/` |
| apple-reminders | `skills/apple-reminders/` |
| bear-notes | `skills/bear-notes/` |
| blogwatcher | `skills/blogwatcher/` |
| blucli | `skills/blucli/` |
| bluebubbles | `skills/bluebubbles/` |
| camsnap | `skills/camsnap/` |
| canvas | `skills/canvas/` |
| clawhub | `skills/clawhub/` |
| coding-agent | `skills/coding-agent/` |
| discord | `skills/discord/` |
| eightctl | `skills/eightctl/` |
| gemini | `skills/gemini/` |
| gh-issues | `skills/gh-issues/` |
| gifgrep | `skills/gifgrep/` |
| github | `skills/github/` |
| gog | `skills/gog/` |
| goplaces | `skills/goplaces/` |
| healthcheck | `skills/healthcheck/` |
| himalaya | `skills/himalaya/` |
| imsg | `skills/imsg/` |
| mcporter | `skills/mcporter/` |
| model-usage | `skills/model-usage/` |
| nano-banana-pro | `skills/nano-banana-pro/` |
| nano-pdf | `skills/nano-pdf/` |
| node-connect | `skills/node-connect/` |
| notion | `skills/notion/` |
| obsidian | `skills/obsidian/` |
| openai-image-gen | `skills/openai-image-gen/` |
| openai-whisper | `skills/openai-whisper/` |
| openai-whisper-api | `skills/openai-whisper-api/` |
| openhue | `skills/openhue/` |
| oracle | `skills/oracle/` |
| ordercli | `skills/ordercli/` |
| peekaboo | `skills/peekaboo/` |
| sag | `skills/sag/` |
| session-logs | `skills/session-logs/` |
| sherpa-onnx-tts | `skills/sherpa-onnx-tts/` |
| skill-creator | `skills/skill-creator/` |
| slack | `skills/slack/` |
| songsee | `skills/songsee/` |
| sonoscli | `skills/sonoscli/` |
| spotify-player | `skills/spotify-player/` |
| summarize | `skills/summarize/` |
| things-mac | `skills/things-mac/` |
| tmux | `skills/tmux/` |
| trello | `skills/trello/` |
| video-frames | `skills/video-frames/` |
| voice-call | `skills/voice-call/` |
| wacli | `skills/wacli/` |
| weather | `skills/weather/` |
| xurl | `skills/xurl/` |

> **Note:** Each skill has a `SKILL.md` file that describes how to use it. Skills with `disableModelInvocation` set are excluded from the prompt. Additional skills can be installed from ClawHub.
