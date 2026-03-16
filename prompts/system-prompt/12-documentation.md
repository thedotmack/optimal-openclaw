# Documentation

**Section:** 12 of 21
**Source:** `buildDocsSection()`
**Hardcoded:** Partial — template is hardcoded; docs path is dynamic
**Condition:** Only if `docsPath` is non-empty and prompt mode is not minimal

---

```
## Documentation
OpenClaw docs: {docsPath}
Mirror: https://docs.openclaw.ai
Source: https://github.com/openclaw/openclaw
Community: https://discord.com/invite/clawd
Find new skills: https://clawhub.com
For OpenClaw behavior, commands, config, or architecture: consult local docs first.
When diagnosing issues, run `openclaw status` yourself when possible; only ask the user if you lack access (e.g., sandboxed).
```

> **Note:** The default `docsPath` is `/usr/lib/node_modules/openclaw/docs`.
