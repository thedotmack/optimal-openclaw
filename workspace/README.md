# Workspace Files

These are the template files that OpenClaw uses to initialize new agent workspaces. They are loaded from the workspace directory and injected into the system prompt under `# Project Context` every turn.

## Default Templates (`defaults/`)

| File | Purpose |
|------|---------|
| `AGENTS.md` | Agent configuration, session startup rules, memory system, group chat behavior |
| `SOUL.md` | Persona, tone, worldview, personality |
| `TOOLS.md` | User-specific tool notes (camera names, SSH hosts, etc.) |
| `IDENTITY.md` | Agent name, creature type, vibe, emoji, avatar |
| `USER.md` | User info (name, pronouns, timezone, preferences) |
| `HEARTBEAT.md` | Heartbeat task instructions (empty = skip heartbeat API calls) |
| `BOOTSTRAP.md` | First-run onboarding script (deleted after first run) |
| `BOOT.md` | Startup hook instructions (requires `hooks.internal.enabled`) |
| `MEMORY.md` | Persistent memory/context index (no default template — agent-maintained) |

## Dev Variants (`dev-variants/`)

Pre-configured workspace files for the OpenClaw development agent (C-3PO):

| File | Purpose |
|------|---------|
| `AGENTS.dev.md` | Dev agent workspace config with C-3PO origin story |
| `SOUL.dev.md` | C-3PO debug companion soul |
| `TOOLS.dev.md` | Dev agent tool notes |
| `IDENTITY.dev.md` | C-3PO identity record |
| `USER.dev.md` | Clawdributors user profile |

## How These Are Used

1. On first workspace creation, OpenClaw copies templates from `docs/reference/templates/` to the workspace directory
2. Every session turn, all workspace files are loaded by `loadWorkspaceBootstrapFiles()`
3. Files are injected as-is into the system prompt under `# Project Context`
4. Max file size: 2MB per file (`MAX_WORKSPACE_BOOTSTRAP_FILE_BYTES`)
5. Files with YAML frontmatter are supported (frontmatter is metadata, not injected)

## Editing

Edit these files to customize the default agent behavior. After editing, use the `sync-prompts.sh` script in the repository root to sync changes back to an OpenClaw installation.
