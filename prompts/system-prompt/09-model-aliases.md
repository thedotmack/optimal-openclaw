# Model Aliases

**Section:** 9 of 21
**Source:** `buildAgentSystemPrompt()` — Model Aliases block
**Hardcoded:** Partial — header is hardcoded; aliases come from config
**Condition:** Only if `modelAliasLines` are provided and prompt mode is not minimal

---

```
## Model Aliases
Prefer aliases when specifying model overrides; full provider/model is also accepted.
```

Followed by the alias lines from config, e.g.:

```
- fast → anthropic/claude-3-5-haiku-latest
- smart → anthropic/claude-sonnet-4-20250514
- reasoning → anthropic/claude-sonnet-4-20250514
```

> **Note:** The actual alias mappings are configured in `openclaw.json` under `agents.defaults.modelAliases` or per-agent overrides. The `buildModelAliasLines()` function formats them for prompt injection.
