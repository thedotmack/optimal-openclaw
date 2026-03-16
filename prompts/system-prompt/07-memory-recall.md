# Memory Recall

**Section:** 7 of 21
**Source:** `buildMemorySection()`
**Hardcoded:** Yes (with one dynamic line based on citations mode)
**Condition:** Only if memory tools are available (`memory_search` or `memory_get`)

---

```
## Memory Recall
Before answering anything about prior work, decisions, dates, people, preferences, or todos: run memory_search on MEMORY.md + memory/*.md; then use memory_get to pull only the needed lines. If low confidence after search, say you checked.
```

### Citations Mode Variants

When `memoryCitationsMode` is `"off"`:

```
Citations are disabled: do not mention file paths or line numbers in replies unless the user explicitly asks.
```

Otherwise (default):

```
Citations: include Source: <path#line> when it helps the user verify memory snippets.
```
