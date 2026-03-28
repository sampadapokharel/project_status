# [Project Name] — Status

> **How to use**: At the start of each Claude Code session, run `/project-status`.
> Claude reads this file and briefs itself instantly — no codebase scanning needed.
> At the end of each session, update **Last Session**, **Next Priorities**, and any status flags that changed.

---

## Project Overview
[1-2 sentences: what the app does, who it's for, main value prop]

## Tech Stack
[e.g. React Native · TypeScript · Supabase · Zustand · Expo]

## Key Architecture
<!-- Critical paths Claude should know upfront — prevents needing to explore -->
- **Entry point**: `App.tsx` / `index.ts`
- **Features**: `src/features/[name]/` — screens, components, hooks per feature
- **Services**: `src/services/` — external API and backend calls
- **State**: `src/store/` — Zustand stores
- **Types**: `src/types/index.ts`
- **Config**: `src/config/` — constants, environment config
- **Navigation**: `src/app/navigation/`

[Add or remove paths as needed for your project structure]

---

## Feature Status

| Feature | Status | Notes |
|---------|--------|-------|
| [Feature 1] | ✅ | Done and fully wired up |
| [Feature 2] | 🚧 | Started — [what's missing or incomplete] |
| [Feature 3] | ❌ | Not started |

**Legend**: ✅ Done · 🚧 In progress · ❌ Not started

---

## Backend / Infrastructure

| Item | Status | Notes |
|------|--------|-------|
| [Database / API setup] | ✅/🚧/❌ | |
| [Authentication] | ✅/🚧/❌ | |
| [Data services] | ✅/🚧/❌ | |
| [State management] | ✅/🚧/❌ | |
| [Migrations / schema] | ✅/🚧/❌ | [Note if applied to DB or not] |

---

## Last Session
<!-- Update this after every session with significant work -->
**Date**: [YYYY-MM-DD]
- [What was built or fixed]
- [What was wired up end-to-end]
- [Any architectural decisions made]

---

## Known Issues / Open TODOs
- [ ] [Issue or incomplete item — include `file:line` if known]
- [ ] [Pre-requisite that must be done before testing, e.g. apply DB migrations]

---

## Next Priorities
<!-- Keep this ordered — top item is what to work on first next session -->
1. [Highest priority]
2. [Second priority]
3. [Third priority]
