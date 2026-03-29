# project-status — Claude Code Plugin

Never lose context between Claude Code sessions. Run `/project-status` at the start of any session and Claude instantly knows what's built, what's broken, and what's next — no codebase scanning, no re-explaining.

## Why Use It

Every new Claude Code session starts cold. Without context, Claude scans files, asks questions, and wastes the first few minutes just catching up.

With this plugin:
- `/project-status` → Claude reads one file and is immediately ready to work
- Every `git commit` → `PROJECT_STATUS.md`, `README.md`, and `CLAUDE.md` auto-update
- The longer you use it, the more accurate and useful the context becomes

## When to Use It

- **Start of every session** — run `/project-status` before anything else
- **New projects** — Claude auto-generates all missing docs if they don't exist yet
- **Team projects** — the files travel with the repo, so any collaborator gets instant context too

## How It Works

Each project has three auto-managed files:

- **`PROJECT_STATUS.md`** — the source of truth for Claude. Contains project overview, tech stack, key architecture paths, feature status table, last session summary, and next priorities.
- **`README.md`** — human-facing project docs. Auto-generated if missing.
- **`CLAUDE.md`** — developer architecture reference for Claude. Auto-generated if missing.

`/project-status` reads these files and briefs Claude in seconds. Here's what happens depending on what exists:

| Files present | What the skill does |
|---|---|
| All three | Reads and presents `PROJECT_STATUS.md` — no scanning |
| `PROJECT_STATUS.md` only | Presents it, then generates `README.md` and `CLAUDE.md` from its content |
| None | Full project scan → generates all three |
| Only `README.md` | Full scan → generates `PROJECT_STATUS.md` and `CLAUDE.md`; updates README if outdated |

The pre-commit hook keeps everything current automatically — on every commit, Claude analyzes the diff and updates:
- `PROJECT_STATUS.md` — Last Session + changed status flags
- `README.md` — Features or setup sections (when features/deps change)
- `CLAUDE.md` — Architecture sections (when new files or patterns are added)

## Install

**Step 1 — Clone:**

```bash
git clone https://github.com/sampadapokharel/project_status \
  ~/.claude/plugins/marketplaces/personal/plugins/project-status
```

**Step 2 — Run the installer:**

```bash
bash ~/.claude/plugins/marketplaces/personal/plugins/project-status/install.sh
```

**Step 3 — Reload VS Code:**

`Cmd+Shift+P` → **Developer: Reload Window**

`/project-status` is now available in every project.

## Per-Project Hook Setup

Run this once from each project root to enable auto-updating docs on every commit:

```bash
sh ~/.claude/plugins/marketplaces/personal/plugins/project-status/scripts/install-git-hook.sh
```

Or just run `/project-status` — it will detect if the hook is missing and offer to install it for you.

Requires `claude` CLI in your PATH (comes with Claude Code).

## Usage

```
/project-status
```

That's it. Run it at the start of every session.
