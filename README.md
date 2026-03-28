# project-status — Claude Code Plugin

A Claude Code plugin that gives Claude instant project context at the start of any session — no codebase scanning. Just run `/project-status` and Claude reads `PROJECT_STATUS.md` from your project root.

## How It Works

Each project has a `PROJECT_STATUS.md` file you maintain. It contains:
- Project overview and tech stack
- Key architecture paths
- Feature status table (✅/🚧/❌)
- Backend/infrastructure status
- Last session summary
- Known issues and next priorities

At the start of a session: `/project-status` → Claude reads the file → instant context, ready to work.
At the end of a session: Claude updates the file to reflect what changed.

## Install (One-Time Global Setup)

```bash
mkdir -p ~/.claude/plugins/marketplaces/sampu-plugins/plugins
git clone https://github.com/sampu/claude-project-status \
  ~/.claude/plugins/marketplaces/sampu-plugins/plugins/project-status
```

The `/project-status` command is now available in every Claude Code project.

## Per-Project Setup (Each New Project)

```bash
# From your project root:
cp ~/.claude/plugins/marketplaces/sampu-plugins/plugins/project-status/templates/PROJECT_STATUS.md ./PROJECT_STATUS.md
# Fill in the template with your project's details
```

## Usage

```
/project-status
```

Run this at the start of any Claude Code session. Claude will read `PROJECT_STATUS.md` and brief itself on the project state.

If no `PROJECT_STATUS.md` exists in the project, Claude will tell you how to set one up.

## Keeping It Current

At the end of each working session, update:
- **Last Session** — what was built or fixed
- **Next Priorities** — reorder based on what's most important now
- **Status flags** — move items from 🚧 to ✅ as features complete

Claude will remind you to do this at the end of each `/project-status` brief.
