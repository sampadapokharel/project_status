---
name: project-status
description: "Use this skill when the user runs /project-status, asks 'what is the project status', 'catch me up', 'where are we', 'what has been done', 'what is left to build', 'what should we work on', or wants to start a new session with project context."
allowed-tools: [Read]
---

Read the file `PROJECT_STATUS.md` from the current working directory (the project root).

If the file does not exist, respond with:
"No `PROJECT_STATUS.md` found in this project. Copy the template from the plugin's `templates/PROJECT_STATUS.md` to your project root and fill it in to get started:

```bash
cp ~/.claude/plugins/marketplaces/sampu-plugins/plugins/project-status/templates/PROJECT_STATUS.md ./PROJECT_STATUS.md
```"

If it exists, present its contents as a clean, easy-to-scan brief. Preserve the status icons (✅/🚧/❌) and table formatting. Do not truncate any sections.

End your response with this note:
> **Reminder**: Update `PROJECT_STATUS.md` at the end of this session — specifically the **Last Session**, **Next Priorities**, and any status flags (✅/🚧/❌) that changed.
