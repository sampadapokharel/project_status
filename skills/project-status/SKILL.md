---
name: project-status
description: "Use this skill when the user runs /project-status, asks 'what is the project status', 'catch me up', 'where are we', 'what has been done', 'what is left to build', 'what should we work on', or wants to start a new session with project context."
allowed-tools: [Read, Glob, Bash, Write]
---

First, check which of the following files exist in the current working directory (the project root):
- `PROJECT_STATUS.md`
- `README.md`
- `CLAUDE.md`

Note which are present and which are missing before taking any action.

---

## If PROJECT_STATUS.md EXISTS

1. Read and present its contents as a clean, easy-to-scan brief. Preserve table formatting. Do not truncate any sections.

2. If `README.md` or `CLAUDE.md` are missing, generate them **using only the content of `PROJECT_STATUS.md` as context** — no repo scan, no Glob, no git log needed. PROJECT_STATUS.md already contains the tech stack, architecture, and feature context required.

   **Generating README.md from PROJECT_STATUS.md** (only if missing):
   - Derive project name and description from the Project Overview section
   - Derive tech stack from the Tech Stack section
   - Derive key features from the Feature Status table (prose only)
   - Derive Getting Started commands from any mentioned entry points or tech (infer standard commands for the detected stack if not explicit)
   - Use the format in the "README.md format" section below

   **Generating CLAUDE.md from PROJECT_STATUS.md** (only if missing):
   - Derive Key Architecture bullets from the Key Architecture section
   - Derive Conventions from the Tech Stack and any structural details
   - Use the format in the "CLAUDE.md format" section below

3. If any files were generated, report them:
   > The following files were auto-generated from `PROJECT_STATUS.md`:
   > [list each generated file with a one-line description of what to review]

---

## If PROJECT_STATUS.md does NOT exist

### Step 1 — Comprehensive project scan

Gather the following (reuse this data for all files that need to be generated):

1. Read `package.json` (or `pyproject.toml`, `Cargo.toml`, `go.mod` — whichever exists) to identify the project name, tech stack, dependencies, and scripts.
2. Run `git log --oneline -10` to see recent commit history.
3. Use Glob to discover the full source structure. Then read the actual files for any of the following that exist: entry point, router/navigation config, database/auth/storage client files (e.g. `supabase.ts`, `firebase.ts`), API service files, state store files, type definition files, environment/config files, middleware.
4. If `README.md` exists, read it for project overview context.
5. From what you read, map every significant file to its purpose — this becomes the Key Architecture section.

### Step 2 — Generate PROJECT_STATUS.md

Write `PROJECT_STATUS.md` to the project root using this structure:

```markdown
# [Project Name] — Status

> **How to use**: At the start of each Claude Code session, run `/project-status`.
> Claude reads this file and briefs itself instantly — no codebase scanning needed.
> At the end of each session, update **Last Session**, **Next Priorities**, and any status flags that changed.

---

## Project Overview
[1-2 sentence description derived from package.json + README]

## Tech Stack
[Key frameworks and versions from package.json]

## Key Architecture
- **Entry point**: [exact file path — e.g. `src/index.ts`, `App.tsx`]
- **[Layer name]**: [exact file or directory path] — [what it does]

(This section must be thorough. List every meaningful file and directory Claude would need to navigate the project without scanning. Include: routing/navigation, each external service client (auth, database, storage, payments, etc.), state management files, API layer, type definitions, config/env setup, middleware, and any other non-obvious files. Use specific file paths like `src/services/supabase.ts` — not just `src/services/`.)

---

## Feature Status

| Feature | Status | Notes |
|---------|--------|-------|
| [Feature] | In Progress | [Detected from directory/file names — mark Not Started if only a placeholder] |

**Legend**: Done · In Progress · Not Started

---

## Backend / Infrastructure

| Item | Status | Notes |
|------|--------|-------|
| [Service/config] | Done | [What it does] |

---

## Last Session
**Date**: [today's date]
- Auto-generated from project scan — update with what was actually done this session.

---

## Known Issues / Open TODOs
- [ ] [Detected issue — include `file:line` reference where possible]

---

## Next Priorities
1. [Derived from git log or left as placeholder]
```

When populating **Known Issues / Open TODOs**, detect real issues from the scan and include specific file paths and line references. Look for:
- `TODO`, `FIXME`, or `throw new Error('not implemented')` comments in source files
- Features listed as directories/files with no implementation (empty or stub files)
- Routes defined but missing handler files
- Environment variables referenced in config but not documented

Format each item as: `- [ ] [description] (\`path/to/file:line\`)`

### Step 3 — Generate or update README.md

- **If missing**: generate from scratch using scan data (see README.md format below)
- **If exists but outdated** (scan reveals changed tech stack, features, or commands): update only the stale sections
- **If exists and current**: leave unchanged

### Step 4 — Generate or update CLAUDE.md

- **If missing**: generate from scratch using scan data (see CLAUDE.md format below)
- **If exists but outdated** (scan reveals changed architecture paths or conventions): update Key Architecture and Conventions
- **If exists and current**: leave unchanged

### Step 5 — Report and present

After writing all files, report which were generated or updated:
> The following files were auto-generated from your project structure:
> - `PROJECT_STATUS.md` — review feature statuses and update anything inaccurate.
> [If generated:] - `README.md` — review features list and getting-started commands before publishing.
> [If generated:] - `CLAUDE.md` — review architecture paths and conventions for accuracy.
> [If updated:] - `README.md` — stale sections updated based on current project scan.
> [If updated:] - `CLAUDE.md` — architecture updated based on current project scan.

Only list files actually written or changed. Then present `PROJECT_STATUS.md` as a clean brief.

---

## README.md format

```markdown
# [Project Name]

[1-2 sentence description — human-facing, for someone discovering the project for the first time]

## Tech Stack

[List of key technologies and frameworks with versions]

## Key Features

[Bullet list of features derived from top-level directory names, route files, or feature folders. Write each as a short human-facing phrase. No status language.]

## Getting Started

### Prerequisites

[Any runtime or toolchain prerequisites inferred from the project manifest]

### Installation

```bash
[Install command from the scripts section of the project manifest — e.g. npm install]
```

### Running the project

```bash
[Primary dev/run command from the scripts section of the project manifest]
```

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.
```

**README.md rules:**
- Human-facing prose only — write for someone discovering the project for the first time
- No status icons (✅/🚧/❌) and no in-progress language anywhere
- Pull commands directly from the `scripts` section of `package.json` (or equivalent) — never invent commands
- Omit sections that cannot be determined from the scan rather than leaving placeholders

---

## CLAUDE.md format

```markdown
# [Project Name] — Architecture

## Key Architecture

- `[path]` — [what it does / what lives here]
(one bullet per meaningful directory or file: entry points, routing, features, services, state, types, config, utils, DB layer, migrations)

## Conventions

- [TypeScript config — e.g. "TypeScript strict mode enabled (`tsconfig.json`)"]
- [Linting — e.g. "ESLint configured (`eslint.config.*`)"]
- [Testing — e.g. "Jest / Vitest test setup detected (`*.test.ts` pattern)"]
- [Package manager — e.g. "Uses pnpm (lockfile present)"]
- [Any other confirmed structural pattern]
```

**CLAUDE.md rules:**
- Developer-facing only — this file is for Claude navigating the codebase, not end users
- Bullet points only — no prose paragraphs
- Every path in Key Architecture must be a real path discovered during the scan — no generic placeholders
- Conventions must reflect what was actually detected (config files, lockfiles, test patterns) — omit any convention that cannot be confirmed

---

## Git Hook Status

After presenting the project status (whether it existed or was just generated), check whether the pre-commit hook is installed by running:

```bash
grep -q "project-status" .git/hooks/pre-commit 2>/dev/null && echo installed || echo missing
```

- **If `installed`**: append one line to your response:
  > ✅ Auto-update hook active — PROJECT_STATUS.md, README.md, and CLAUDE.md update automatically on each commit.

- **If `missing`**: append this block to your response:
  > ⚠️ Auto-update hook not installed for this project.
  > To enable automatic doc updates on every commit, run:
  > ```
  > sh ~/.claude/plugins/marketplaces/personal/plugins/project-status/scripts/install-git-hook.sh
  > ```
  > Or say **"install the hook"** and I'll run it for you.

If the user says "install the hook" (or anything similar), run:
```bash
sh ~/.claude/plugins/marketplaces/personal/plugins/project-status/scripts/install-git-hook.sh
```
Then confirm: "Hook installed. PROJECT_STATUS.md, README.md, and CLAUDE.md will now update automatically before each commit."
