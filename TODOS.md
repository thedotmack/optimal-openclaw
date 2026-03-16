# TODOS

## Architecture

### Restructure directories: reference/ vs workspace/

**What:** Split `prompts/` into `reference/` (read-only: system-prompt, user-messages, config, skills) and `workspace/` (editable: defaults, dev-variants). Update manifest.json paths, sync-prompts.sh source paths, all README/CLAUDE.md references.

**Why:** Users cannot tell which files are editable+syncable vs read-only documentation. Someone editing `04-safety.md` will think they're customizing safety rules — they're not. Making the boundary physical prevents this permanently.

**Context:** Currently all 50 files live under `prompts/` with no UX distinction. The `hardcoded` field in manifest.json documents editability but is invisible to someone browsing the file tree. sync-prompts.sh only touches `workspace-files/defaults/` and `workspace-files/dev-variants/`, but this isn't obvious from the directory layout. After restructure, the sync script's source paths need updating, manifest.json entries need new paths, and all three READMEs + CLAUDE.md need path updates.

**Effort:** M
**Priority:** P1
**Depends on:** None — this is the foundation; all other TODOs should follow.

### Fix MEMORY.md identity crisis

**What:** Decide whether `defaults/MEMORY.md` is a template (give it real placeholder structure) or documentation (remove it from defaults/ and document that MEMORY.md is agent-created). Also add MEMORY.md to sync-prompts.sh's DEFAULT_FILES array if it should sync.

**Why:** The file is documentation pretending to be a template. Its content says "there is no default template" while living in the templates directory. sync-prompts.sh's DEFAULT_FILES array omits it, so editing it does nothing.

**Context:** manifest.json lists MEMORY.md as a workspace default. The actual OpenClaw loader (`loadWorkspaceBootstrapFiles()`) looks for both `MEMORY.md` and `memory.md`. The file's current content describes what MEMORY.md *is* rather than providing a template. Either make it a real template with placeholder sections (Key Decisions, Preferences, Projects, People) or move it to reference/ as documentation.

**Effort:** XS
**Priority:** P2
**Depends on:** TODO #1 (directory restructure)

## Documentation

### Replace minified source references with stable names

**What:** In PROMPT-ANATOMY.md and README.md, replace all hash-suffixed filenames (`pi-embedded-Cf0EGRq3.js`, `agent-scope-XRTwmJgy.js`) and line numbers with stable function/constant names (`buildAgentSystemPrompt()`, `loadWorkspaceBootstrapFiles()`). Add a "How to find these in source" section.

**Why:** The hash-suffixed filenames change on every OpenClaw build. Line numbers in minified code are meaningless. These references are already stale or will be on the next OC update. Function/constant names are stable across versions.

**Context:** PROMPT-ANATOMY.md references `pi-embedded-Cf0EGRq3.js` (line ~23983), `agent-scope-XRTwmJgy.js` (line ~1369), `heartbeat-visibility-_K4bnQDH.js`. README.md's Source Locations table has the same references. Replace with descriptions like "Main agent runtime bundle — search for `buildAgentSystemPrompt`". Add a section explaining how to use `grep -r` to find these in any OC installation.

**Effort:** S
**Priority:** P1
**Depends on:** None

### Fix heartbeat timer inconsistency

**What:** PROMPT-ANATOMY.md says `"20m"` with parenthetical `(needs to be "10m")`. Config file says `"30m"`. Fix PROMPT-ANATOMY.md to say `"30m"` and remove the editorial parenthetical.

**Why:** Three different values for the same setting across docs is confusing and the `(needs to be "10m")` note is a personal TODO that leaked into documentation.

**Context:** `openclaw-defaults.json` defines `heartbeat.every: "30m"` — this is the source of truth. PROMPT-ANATOMY.md line 75 has `"20m" (needs to be "10m")`. `prompts/README.md` line 125 says default is 30m (correct). AGENTS.md says `~30 min` (correct). Fix PROMPT-ANATOMY.md to match the config.

**Effort:** XS
**Priority:** P1
**Depends on:** None

### DRY: Make manifest.json the single source of truth for section tables

**What:** Remove duplicate section assembly tables from PROMPT-ANATOMY.md and prompts/README.md. Replace with a summary + link to manifest.json. Optionally add a `generate-docs.sh` that renders human-readable tables from manifest.json.

**Why:** The section list appears in 4 places (manifest.json, PROMPT-ANATOMY.md, prompts/README.md, README.md) and they already drift — section counts are reported as 21, 22, and 25 across different files.

**Context:** manifest.json has 25 entries (01-20, 21a-21d, 22). PROMPT-ANATOMY.md says "21 sections" in its table. README.md says "22 numbered sections". The actual count is 25 files / 22 numbered slots (with 21 having sub-slots a-d). After dedup, manifest.json is canonical, and docs link to it or use a generated table.

**Effort:** M
**Priority:** P2
**Depends on:** TODO #1 (directory restructure changes paths in manifest.json)

## Tooling

### Add validate-manifest.sh

**What:** Bash script that validates: (1) every manifest.json entry has a matching file on disk, (2) every prompt file on disk is in manifest.json, (3) workspace files are <2MB, (4) YAML frontmatter parses cleanly. Exit 1 on any failure.

**Why:** No validation exists. A renamed file, a missing entry, or an oversized workspace file won't be caught until it breaks an agent in production. This is the foundation for CI.

**Context:** manifest.json has ~50 entries across 5 categories. Workspace files are injected into every system prompt turn and have a 2MB hard limit (`MAX_WORKSPACE_BOOTSTRAP_FILE_BYTES`). YAML frontmatter is used for metadata in workspace templates. The script should use `jq` to parse manifest.json (check for jq availability) and standard bash for file checks.

**Effort:** S
**Priority:** P1
**Depends on:** TODO #1 (directory restructure changes file paths)

### Add backup + diff + restore to sync-prompts.sh

**What:** Before overwriting, backup existing target files to `.openclaw-backup/{timestamp}/`. Add `--diff` flag to show unified diff of each file. Add `--restore` flag to undo last sync.

**Why:** Currently sync overwrites with no backup. A user who spent hours tuning AGENTS.md and accidentally syncs defaults over it loses their work. The script's own AGENTS.md template says "trash > rm (recoverable beats gone forever)."

**Context:** The sync_file() function already has the diff infrastructure (uses `diff -q` to check for changes). Extend it to: (1) create backup dir before first overwrite, (2) cp target to backup before overwrite, (3) `--diff` mode shows `diff -u` output instead of syncing, (4) `--restore` finds latest backup dir and copies files back.

**Effort:** S
**Priority:** P1
**Depends on:** None

### Add MIT LICENSE file

**What:** Create a standard MIT LICENSE file in the repo root.

**Why:** README.md claims MIT license but no LICENSE file exists. This is a legal gap that blocks serious open-source adoption.

**Context:** GitHub requires a LICENSE file to display the license badge and for dependency scanners to detect the license. The copyright holder should be the repo owner (thedotmack).

**Effort:** XS
**Priority:** P1
**Depends on:** None

## Phase 2 — Prompt Workbench

### token-count.sh — Token budget calculator

**What:** Script that counts approximate tokens for each workspace file and shows total system prompt budget. Output like: "AGENTS.md: ~3,500 tokens / SOUL.md: ~450 tokens / Total workspace injection: ~7,200 tokens per turn."

**Why:** OpenClaw users have zero visibility into how much context window their templates consume. This is the #1 power-user question: "how much of my context is the system prompt eating?"

**Context:** A simple approximation (words * 1.3) gets within 10% for English text. For accuracy, tiktoken (Python) or gpt-tokenizer (Node) can be used. The script should process all files in workspace/defaults/ and sum them. Bonus: also estimate the hardcoded system prompt sections from reference/ files.

**Effort:** S
**Priority:** P2
**Depends on:** TODO #1 (directory restructure)

### preview-prompt.sh — Assemble simulated system prompt

**What:** Assemble a simulated full system prompt from workspace templates + reference sections, outputting what the LLM actually sees each turn. Users can pipe to `wc`, `diff`, or just read it.

**Why:** "X-ray vision into your agent's mind." No OpenClaw user can currently see the assembled prompt. This makes the invisible visible.

**Context:** The assembly order is defined in manifest.json. The script would concatenate reference sections (with placeholders for dynamic values like timestamps, tool lists) and workspace files in order. Dynamic sections get placeholder markers like `[DYNAMIC: current date/time]`. Output goes to stdout so users can redirect, pipe, or page it.

**Effort:** M
**Priority:** P2
**Depends on:** TODO #1 (directory restructure), TODO #6 (manifest as canonical source)

### create-workspace.sh — Workspace starter kit

**What:** Script that scaffolds a new workspace directory from templates, prompting for agent name, user name, and timezone. Like `npm init` for OpenClaw agents.

**Why:** Makes the first-run experience tangible outside of OpenClaw itself. Users can customize templates before deploying.

**Context:** Copy workspace/defaults/ to a target directory. Prompt for agent name (fill into IDENTITY.md), user name (fill into USER.md), timezone (fill into USER.md). Skip BOOTSTRAP.md if user says this isn't a first-run. The scaffolded workspace can then be synced to OpenClaw or used as a starting point.

**Effort:** S
**Priority:** P2
**Depends on:** TODO #1 (directory restructure)

## Phase 3 — Community

### Example persona gallery

**What:** A `gallery/` directory with 3-4 example SOUL.md + IDENTITY.md combos showing different agent personalities (professional assistant, snarky sidekick, research partner, creative collaborator).

**Why:** Inspires customization and shows what's possible. The default templates are good but seeing alternatives sparks creativity.

**Context:** Each gallery entry would be a subdirectory with SOUL.md + IDENTITY.md + a brief README explaining the persona. Users could copy a gallery entry into their workspace as a starting point.

**Effort:** S
**Priority:** P3
**Depends on:** None

## Housekeeping

### Delete stale branch

**What:** Delete local branch `copilot/create-file-structure-for-prompts` — it's already merged via PR #2.

**Why:** Branch hygiene. Stale branches clutter `git branch` output.

**Context:** The branch was used for PR #2 which merged to main. Both local and remote refs exist.

**Effort:** XS
**Priority:** P3
**Depends on:** None

## Completed
