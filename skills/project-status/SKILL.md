---
name: project-status
description: "Use this skill when the user runs /project-status, asks 'what is the project status', 'catch me up', 'where are we', 'what has been done', 'what is left to build', 'what should we work on', or wants to start a new session with project context."
allowed-tools: [Read, Glob, Bash, Write]
---

Read the file `PROJECT_STATUS.md` from the current working directory (the project root).

## If the file EXISTS

Present its contents as a clean, easy-to-scan brief. Preserve the status icons (✅/🚧/❌) and table formatting. Do not truncate any sections.

## If the file does NOT exist

Auto-generate it by scanning the project. Follow these steps:

1. Read `package.json` (or `pyproject.toml`, `Cargo.toml`, `go.mod` — whichever exists) to identify the project name, tech stack, and dependencies.
2. Run `git log --oneline -10` to see recent commit history.
3. Use Glob to discover the top-level source structure (e.g., `src/**/*.ts`, `src/**/`, or equivalent for the language).
4. Read any existing `README.md` for project overview context.
5. Identify key entry points, navigation/routing files, service/API files, state management, and types.

Then write a filled-in `PROJECT_STATUS.md` to the project root using this structure:

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
- **Entry point**: [detected]
- **[Layer name]**: [path] — [what it does]
(add all meaningful layers: navigation, features, services, state, types, config, utils, DB)

---

## Feature Status

| Feature | Status | Notes |
|---------|--------|-------|
| [Feature] | 🚧 | [Detected from directory/file names — mark ❌ if only a placeholder] |

**Legend**: ✅ Done · 🚧 In progress · ❌ Not started

---

## Backend / Infrastructure

| Item | Status | Notes |
|------|--------|-------|
| [Service/config] | ✅ | [What it does] |

---

## Last Session
**Date**: [today's date]
- Auto-generated from project scan — update with what was actually done this session.

---

## Known Issues / Open TODOs
- [ ] Review auto-generated feature statuses above — mark items accurately

---

## Next Priorities
1. [Derived from git log or left as placeholder]
```

After writing the file, present the generated content as a brief to the user and say:
> `PROJECT_STATUS.md` has been auto-generated from your project structure. Review the feature statuses and update anything that's inaccurate — then it's ready to use every session.

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
