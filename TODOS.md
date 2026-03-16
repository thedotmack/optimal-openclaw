# TODOS

## Completed

### Restructure directories: reference/ vs workspace/
**Status:** Done (Phase 2)
Split `prompts/` into `reference/` (read-only) and `workspace/` (editable). Updated all path references in manifest.json, sync-prompts.sh, CLAUDE.md, README.md, prompts/README.md.

### Fix MEMORY.md identity crisis
**Status:** Done (Phase 3)
Converted from meta-documentation to real starter template with Key Decisions, User Preferences, Active Projects, Important Context sections. Added to sync-prompts.sh DEFAULT_FILES.

### Replace minified source references with stable names
**Status:** Done (Phase 1)
Replaced hash-suffixed filenames with stable function names in PROMPT-ANATOMY.md and README.md. Added "Finding These in OpenClaw Source" grep guide.

### Fix heartbeat timer inconsistency
**Status:** Done (Phase 1)
Fixed PROMPT-ANATOMY.md and README.md to say "30m" matching openclaw-defaults.json.

### DRY: Make manifest.json the single source of truth for section tables
**Status:** Done (Phase 4)
Removed duplicate tables from PROMPT-ANATOMY.md and prompts/README.md. Fixed section counts to "25 entries" across all docs. Added generate-docs.sh.

### Add validate-manifest.sh
**Status:** Done (Phase 3)
118 checks: manifest↔disk consistency, file sizes under 2MB limit, YAML frontmatter validation.

### Add backup + diff + restore to sync-prompts.sh
**Status:** Done (Phase 1)
Added --diff, --restore flags and automatic timestamped backup before overwrite.

### Add MIT LICENSE file
**Status:** Done (Phase 1)
MIT LICENSE created with copyright 2025 Alex Newman.

### token-count.sh — Token budget calculator
**Status:** Done (Phase 4)
Estimates tokens per workspace/reference file using words × 1.3 approximation.

### preview-prompt.sh — Assemble simulated system prompt
**Status:** Done (Phase 5)
Assembles full system prompt with dynamic placeholders. Flags: --workspace, --no-reference, --token-count.

### create-workspace.sh — Workspace starter kit
**Status:** Done (Phase 4)
Scaffolds new workspace from templates with interactive prompts for agent name, user name, timezone.

### Example persona gallery
**Status:** Done (Phase 5)
4 personas: Athena (professional), Muse (creative), Scholar (research), Guide (mentor).

### Delete stale branch
**Status:** Done (Phase 4)
Deleted local and remote `copilot/create-file-structure-for-prompts` branch.
