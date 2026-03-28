#!/bin/sh
# install-git-hook.sh
# Run this once per project to install the pre-commit hook that auto-updates
# PROJECT_STATUS.md, README.md, and CLAUDE.md on every commit.
#
# Usage (from your project root):
#   sh ~/.claude/plugins/marketplaces/personal/plugins/project-status/scripts/install-git-hook.sh

set -e

HOOK_PATH=".git/hooks/pre-commit"

if [ ! -d ".git" ]; then
  echo "Error: run this from the root of a git repository."
  exit 1
fi

if [ -f "$HOOK_PATH" ]; then
  echo "A pre-commit hook already exists at $HOOK_PATH"
  echo "Appending project-status update block..."
  cat >> "$HOOK_PATH" << 'HOOK'

# --- project-status: auto-update PROJECT_STATUS.md, README.md, CLAUDE.md ---
STAGED_DIFF=$(git diff --cached 2>/dev/null)
STAGED_STAT=$(git diff --cached --stat 2>/dev/null)

if [ -n "$STAGED_DIFF" ]; then

  # ── 1. PROJECT_STATUS.md — create if missing, update if present ────────────
  if [ ! -f "PROJECT_STATUS.md" ]; then
    claude --print "
You are creating PROJECT_STATUS.md for the first time before a git commit.
Focus: progress tracking and tasks. Style: concise, structured.

Staged changes summary:
$STAGED_STAT

Steps:
1. Read package.json (or pyproject.toml / Cargo.toml / go.mod) for project name and tech stack.
2. Run: git log --oneline -10
3. Scan top-level source structure with Glob.
4. Create PROJECT_STATUS.md using this structure:
   - Project Overview (1-2 sentences)
   - Tech Stack (key frameworks + versions)
   - Key Architecture (bullet list of paths and what they do)
   - Feature Status table (use ✅ Done / 🚧 In progress / ❌ Not started)
   - Backend / Infrastructure table
   - Last Session (today's date + bullets summarizing the staged changes)
   - Known Issues / Open TODOs
   - Next Priorities
5. Write PROJECT_STATUS.md to the project root.
" > /dev/null 2>&1
  else
    claude --print "
You are updating PROJECT_STATUS.md before a git commit.
Focus: progress tracking and tasks. Style: concise, structured.

Staged changes summary:
$STAGED_STAT

Steps:
1. Read PROJECT_STATUS.md
2. Update ONLY the **Last Session** section: set date to today, summarize what the staged changes accomplish (1-5 bullets, past tense, concrete).
3. Update any Feature Status or Backend/Infrastructure table rows whose status changed.
4. Do NOT change Next Priorities, Known Issues, or any other sections.
5. Write the updated content back to PROJECT_STATUS.md.
" > /dev/null 2>&1
  fi
  git add PROJECT_STATUS.md 2>/dev/null || true

  # ── 2. README.md — update when features or setup changes detected ───────────
  FEATURE_CHANGES=$(echo "$STAGED_STAT" | grep -E "(features/|screens/|pages/|components/|package\.json|app\.json|next\.config|requirements)" | head -5)
  if [ -n "$FEATURE_CHANGES" ]; then
    claude --print "
You are updating README.md based on feature or setup changes in this commit.
Focus: clarity for humans. Style: polished, external-facing prose. No status language (no ✅/🚧/❌).

Changed files relevant to features/setup:
$FEATURE_CHANGES

Full staged diff:
$STAGED_DIFF

Steps:
1. Read README.md. If it does not exist, create it: use the project name from package.json as the title, add a 1-2 sentence description, and a Features section.
2. If new features/screens were added: add or update the Features section with concise user-facing descriptions.
3. If setup/dependencies changed: update Getting Started or Installation section.
4. Do NOT include developer-internal status notes or in-progress language.
5. Write back to README.md (creating the file if it did not exist).
" > /dev/null 2>&1
    git add README.md 2>/dev/null || true
  fi

  # ── 3. CLAUDE.md — update when architecture or structure changes detected ───
  ARCH_CHANGES=$(echo "$STAGED_STAT" | grep -E "(src/|services/|store/|types/|config/|middleware|layout\.|new file mode)" | head -5)
  if [ -n "$ARCH_CHANGES" ]; then
    claude --print "
You are updating CLAUDE.md based on architectural changes in this commit.
Focus: helping Claude navigate and reason about this codebase. Style: bullet points, fast-parseable.

Changed files relevant to architecture/structure:
$ARCH_CHANGES

Full staged diff:
$STAGED_DIFF

Steps:
1. Read CLAUDE.md. If it does not exist, create it with a minimal structure: Project name header, Key Architecture section (bullet list of paths and what they do), and a Conventions section.
2. If new files/folders were added: update the Key Architecture section with new paths and their purpose.
3. If new services, patterns, or conventions were introduced: add concise bullet points under the relevant section.
4. Do NOT add verbose prose, external-facing content, or status language.
5. Write back to CLAUDE.md (creating the file if it did not exist).
" > /dev/null 2>&1
    git add CLAUDE.md 2>/dev/null || true
  fi

fi
# --- end project-status ---
HOOK
  echo "Done. Hook updated."
else
  cat > "$HOOK_PATH" << 'HOOK'
#!/bin/sh
# project-status: auto-update PROJECT_STATUS.md, README.md, CLAUDE.md before each commit

STAGED_DIFF=$(git diff --cached 2>/dev/null)
STAGED_STAT=$(git diff --cached --stat 2>/dev/null)

if [ -z "$STAGED_DIFF" ]; then
  exit 0
fi

# ── 1. PROJECT_STATUS.md — create if missing, update if present ──────────────
if [ ! -f "PROJECT_STATUS.md" ]; then
  claude --print "
You are creating PROJECT_STATUS.md for the first time before a git commit.
Focus: progress tracking and tasks. Style: concise, structured.

Staged changes summary:
$STAGED_STAT

Steps:
1. Read package.json (or pyproject.toml / Cargo.toml / go.mod) for project name and tech stack.
2. Run: git log --oneline -10
3. Scan top-level source structure with Glob.
4. Create PROJECT_STATUS.md using this structure:
   - Project Overview (1-2 sentences)
   - Tech Stack (key frameworks + versions)
   - Key Architecture (bullet list of paths and what they do)
   - Feature Status table (use ✅ Done / 🚧 In progress / ❌ Not started)
   - Backend / Infrastructure table
   - Last Session (today's date + bullets summarizing the staged changes)
   - Known Issues / Open TODOs
   - Next Priorities
5. Write PROJECT_STATUS.md to the project root.
" > /dev/null 2>&1
else
  claude --print "
You are updating PROJECT_STATUS.md before a git commit.
Focus: progress tracking and tasks. Style: concise, structured.

Staged changes summary:
$STAGED_STAT

Steps:
1. Read PROJECT_STATUS.md
2. Update ONLY the **Last Session** section: set date to today, summarize what the staged changes accomplish (1-5 bullets, past tense, concrete).
3. Update any Feature Status or Backend/Infrastructure table rows whose status changed.
4. Do NOT change Next Priorities, Known Issues, or any other sections.
5. Write the updated content back to PROJECT_STATUS.md.
" > /dev/null 2>&1
fi
git add PROJECT_STATUS.md 2>/dev/null || true

# ── 2. README.md — update when features or setup changes detected ─────────────
FEATURE_CHANGES=$(echo "$STAGED_STAT" | grep -E "(features/|screens/|pages/|components/|package\.json|app\.json|next\.config|requirements)" | head -5)
if [ -n "$FEATURE_CHANGES" ]; then
  claude --print "
You are updating README.md based on feature or setup changes in this commit.
Focus: clarity for humans. Style: polished, external-facing prose. No status language (no ✅/🚧/❌).

Changed files relevant to features/setup:
$FEATURE_CHANGES

Full staged diff:
$STAGED_DIFF

Steps:
1. Read README.md. If it does not exist, create it: use the project name from package.json as the title, add a 1-2 sentence description, and a Features section.
2. If new features/screens were added: add or update the Features section with concise user-facing descriptions.
3. If setup/dependencies changed: update Getting Started or Installation section.
4. Do NOT include developer-internal status notes or in-progress language.
5. Write back to README.md (creating the file if it did not exist).
" > /dev/null 2>&1
  git add README.md 2>/dev/null || true
fi

# ── 3. CLAUDE.md — update when architecture or structure changes detected ──────
ARCH_CHANGES=$(echo "$STAGED_STAT" | grep -E "(src/|services/|store/|types/|config/|middleware|layout\.|new file mode)" | head -5)
if [ -n "$ARCH_CHANGES" ]; then
  claude --print "
You are updating CLAUDE.md based on architectural changes in this commit.
Focus: helping Claude navigate and reason about this codebase. Style: bullet points, fast-parseable.

Changed files relevant to architecture/structure:
$ARCH_CHANGES

Full staged diff:
$STAGED_DIFF

Steps:
1. Read CLAUDE.md. If it does not exist, create it with a minimal structure: Project name header, Key Architecture section (bullet list of paths and what they do), and a Conventions section.
2. If new files/folders were added: update the Key Architecture section with new paths and their purpose.
3. If new services, patterns, or conventions were introduced: add concise bullet points under the relevant section.
4. Do NOT add verbose prose, external-facing content, or status language.
5. Write back to CLAUDE.md (creating the file if it did not exist).
" > /dev/null 2>&1
  git add CLAUDE.md 2>/dev/null || true
fi
HOOK
  chmod +x "$HOOK_PATH"
  echo "Pre-commit hook installed at $HOOK_PATH"
  echo "PROJECT_STATUS.md, README.md, and CLAUDE.md will auto-update before every commit."
fi
