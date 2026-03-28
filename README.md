# project-status — Claude Code Plugin

A Claude Code plugin that gives Claude instant project context at the start of any session — no codebase scanning. Just run `/project-status` and Claude reads `PROJECT_STATUS.md` from your project root.

## How It Works

Each project has a `PROJECT_STATUS.md` file containing:
- Project overview and tech stack
- Key architecture paths
- Feature status table (✅/🚧/❌)
- Backend/infrastructure status
- Last session summary
- Known issues and next priorities

At the start of a session: `/project-status` → Claude reads the file → instant context, ready to work.

**No `PROJECT_STATUS.md`?** Claude auto-generates one by scanning your project structure (package.json, src/ layout, git history, README) and writes it for you.

## Install (One-Time Global Setup)

**Step 1 — Clone:**

```bash
git clone https://github.com/sampadapokharel/claude_project_status \
  ~/.claude/plugins/marketplaces/personal/plugins/project-status
```

**Step 2 — Run the installer:**

```bash
bash ~/.claude/plugins/marketplaces/personal/plugins/project-status/install.sh
```

The script handles everything else: creating the marketplace index, registering the personal marketplace, and running `claude plugin install`.

**Step 3 — Reload VS Code:**

`Cmd+Shift+P` → **Developer: Reload Window**

`/project-status` is now available in every project.

## Per-Project Setup (Optional — Each New Project)

If you want to write `PROJECT_STATUS.md` yourself from a template:

```bash
# From your project root:
cp ~/.claude/plugins/marketplaces/personal/plugins/project-status/templates/PROJECT_STATUS.md ./PROJECT_STATUS.md
# Fill in the template with your project's details
```

Or just run `/project-status` — if no file exists, Claude will generate one automatically.

## Usage

```
/project-status
```

Run this at the start of any Claude Code session. Claude will:
- Read `PROJECT_STATUS.md` and brief itself instantly if the file exists
- Auto-generate `PROJECT_STATUS.md` by scanning your project if it doesn't

## Auto-Update Before Commits (Optional)

Install the pre-commit hook to have Claude automatically update the **Last Session** section and status flags before every git commit:

```bash
# From your project root:
sh ~/.claude/plugins/marketplaces/personal/plugins/project-status/scripts/install-git-hook.sh
```

After this, every `git commit` will:
1. Run Claude to read the staged diff
2. Update `PROJECT_STATUS.md` (Last Session + any changed status flags)
3. Stage the updated file alongside your commit

Requires `claude` CLI in your PATH (comes with Claude Code).

## Keeping It Current

At the end of each working session, update:
- **Last Session** — what was built or fixed
- **Next Priorities** — reorder based on what's most important now
- **Status flags** — move items from 🚧 to ✅ as features complete

Claude will remind you to do this at the end of each `/project-status` brief.
