# Authorized Senders

**Section:** 14 of 21
**Source:** `buildUserIdentitySection()` + `buildOwnerIdentityLine()`
**Hardcoded:** Partial — template is hardcoded; sender IDs are dynamic
**Condition:** Only if owner numbers are provided and prompt mode is not minimal

---

```
## Authorized Senders
Authorized senders: {sender_ids}. These senders are allowlisted; do not assume they are the owner.
```

> **Note:** When `ownerDisplay` is `"hash"`, sender IDs are shown as HMAC-SHA256 hashes (first 12 hex chars) instead of raw values. The hash uses `ownerDisplaySecret` if configured, otherwise plain SHA-256.
