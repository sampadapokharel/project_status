#!/bin/sh
# install-git-hook.sh
# Run this once per project to install the pre-commit hook that auto-updates PROJECT_STATUS.md.
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

# --- project-status: auto-update PROJECT_STATUS.md ---
if [ -f "PROJECT_STATUS.md" ]; then
  STAGED=$(git diff --cached --stat 2>/dev/null)
  if [ -n "$STAGED" ]; then
    claude --print "
You are updating PROJECT_STATUS.md before a git commit.

Staged changes summary:
$STAGED

Steps:
1. Read PROJECT_STATUS.md
2. Update the **Last Session** section: set the date to today and summarize what the staged changes accomplish (1-5 bullet points, past tense, concrete).
3. Update any Feature Status or Backend/Infrastructure table rows whose status changed based on the staged changes.
4. Do NOT change Next Priorities, Known Issues, or any other sections.
5. Write the updated content back to PROJECT_STATUS.md.
" > /dev/null 2>&1
    git add PROJECT_STATUS.md 2>/dev/null || true
  fi
fi
# --- end project-status ---
HOOK
  echo "Done. Hook updated."
else
  cat > "$HOOK_PATH" << 'HOOK'
#!/bin/sh
# project-status: auto-update PROJECT_STATUS.md before each commit

if [ -f "PROJECT_STATUS.md" ]; then
  STAGED=$(git diff --cached --stat 2>/dev/null)
  if [ -n "$STAGED" ]; then
    claude --print "
You are updating PROJECT_STATUS.md before a git commit.

Staged changes summary:
$STAGED

Steps:
1. Read PROJECT_STATUS.md
2. Update the **Last Session** section: set the date to today and summarize what the staged changes accomplish (1-5 bullet points, past tense, concrete).
3. Update any Feature Status or Backend/Infrastructure table rows whose status changed based on the staged changes.
4. Do NOT change Next Priorities, Known Issues, or any other sections.
5. Write the updated content back to PROJECT_STATUS.md.
" > /dev/null 2>&1
    git add PROJECT_STATUS.md 2>/dev/null || true
  fi
fi
HOOK
  chmod +x "$HOOK_PATH"
  echo "Pre-commit hook installed at $HOOK_PATH"
  echo "PROJECT_STATUS.md will be auto-updated before every commit."
fi
