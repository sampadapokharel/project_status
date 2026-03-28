#!/usr/bin/env bash
# install.sh — One-shot setup for the project-status Claude Code plugin.
#
# Usage (from inside the cloned repo, or with a path):
#   bash install.sh
#
# What it does:
#   1. Validates the repo is in the expected location
#   2. Creates the personal marketplace index (marketplace.json) if absent
#   3. Merges a "personal" entry into known_marketplaces.json if absent
#   4. Runs: claude plugin install project-status@personal
#
# Safe to re-run — every step is idempotent.

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${GREEN}[install]${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}[install]${NC} %s\n" "$*"; }
fatal() { printf "${RED}[install] ERROR:${NC} %s\n" "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$SCRIPT_DIR"

CLAUDE_PLUGINS_DIR="$HOME/.claude/plugins"
MARKETPLACE_DIR="$CLAUDE_PLUGINS_DIR/marketplaces/personal"
MARKETPLACE_JSON="$MARKETPLACE_DIR/.claude-plugin/marketplace.json"
KNOWN_MARKETPLACES="$CLAUDE_PLUGINS_DIR/known_marketplaces.json"
EXPECTED_PLUGIN_PATH="$MARKETPLACE_DIR/plugins/project-status"

# ---------------------------------------------------------------------------
# Verify this looks like the right repo
# ---------------------------------------------------------------------------

if [[ ! -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]]; then
  fatal "Cannot find .claude-plugin/plugin.json next to install.sh.
  Run this script from inside the cloned project-status repo."
fi

# ---------------------------------------------------------------------------
# Locate the claude CLI
# ---------------------------------------------------------------------------

CLAUDE_BIN=""
for candidate in \
    "$(command -v claude 2>/dev/null || true)" \
    "$HOME/.local/bin/claude" \
    "/usr/local/bin/claude" \
    "/opt/homebrew/bin/claude"; do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    CLAUDE_BIN="$candidate"
    break
  fi
done

if [[ -z "$CLAUDE_BIN" ]]; then
  fatal "claude CLI not found.
  Install Claude Code and ensure the 'claude' binary is in your PATH, then re-run."
fi

info "Using claude CLI at: $CLAUDE_BIN"

# ---------------------------------------------------------------------------
# Step 0 — Validate repo location
# ---------------------------------------------------------------------------

ACTUAL_PATH="$(cd "$PLUGIN_ROOT" && pwd)"
EXPECTED_PATH="$(mkdir -p "$EXPECTED_PLUGIN_PATH" 2>/dev/null; cd "$EXPECTED_PLUGIN_PATH" && pwd)"

if [[ "$ACTUAL_PATH" != "$EXPECTED_PATH" ]]; then
  warn "This repo is not cloned to the expected location."
  warn "  Current : $ACTUAL_PATH"
  warn "  Expected: $EXPECTED_PATH"
  warn ""
  warn "Re-clone with:"
  warn "  git clone https://github.com/sampadapokharel/claude_project_status \\"
  warn "    \"$EXPECTED_PLUGIN_PATH\""
  warn ""
  read -r -p "Continue anyway? (y/N) " CONFIRM
  [[ "${CONFIRM,,}" == "y" ]] || exit 1
fi

# ---------------------------------------------------------------------------
# Step 1 — Create marketplace.json if absent
# ---------------------------------------------------------------------------

if [[ -f "$MARKETPLACE_JSON" ]]; then
  info "marketplace.json already exists — skipping."
else
  info "Creating marketplace index at: $MARKETPLACE_JSON"

  mkdir -p "$(dirname "$MARKETPLACE_JSON")"

  OWNER_NAME="$(git config --global user.name 2>/dev/null || echo "")"
  if [[ -z "$OWNER_NAME" ]]; then
    OWNER_NAME="$USER"
  fi

  python3 - "$MARKETPLACE_JSON" "$OWNER_NAME" <<'PYEOF'
import json, sys

path, owner = sys.argv[1], sys.argv[2]
data = {
    "name": "personal",
    "description": "Personal plugins",
    "owner": {"name": owner},
    "plugins": [
        {
            "name": "project-status",
            "description": (
                "Provides a /project-status command that reads PROJECT_STATUS.md "
                "to instantly brief Claude on any project's current state — "
                "no codebase scanning required."
            ),
            "author": {"name": owner},
            "source": "./plugins/project-status",
            "category": "productivity",
        }
    ],
}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
print(f"  Written: {path}")
PYEOF

  info "marketplace.json created."
fi

# ---------------------------------------------------------------------------
# Step 2 — Merge "personal" entry into known_marketplaces.json
# ---------------------------------------------------------------------------

info "Checking known_marketplaces.json ..."

NOW_ISO="$(python3 -c 'import datetime; print(datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.000Z"))')"

python3 - "$KNOWN_MARKETPLACES" "$MARKETPLACE_DIR" "$NOW_ISO" <<'PYEOF'
import json, sys, os

known_path, install_location, now = sys.argv[1], sys.argv[2], sys.argv[3]

if os.path.isfile(known_path):
    with open(known_path) as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"ERROR: {known_path} is not valid JSON: {e}", file=sys.stderr)
            sys.exit(1)
else:
    data = {}

if "personal" in data:
    print("  'personal' entry already present — no changes needed.")
    sys.exit(0)

data["personal"] = {
    "source": {"source": "local"},
    "installLocation": install_location,
    "lastUpdated": now,
}

os.makedirs(os.path.dirname(known_path), exist_ok=True)
with open(known_path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")

print(f"  Added 'personal' entry to {known_path}")
PYEOF

# ---------------------------------------------------------------------------
# Step 3 — Install the plugin
# ---------------------------------------------------------------------------

info "Running: claude plugin install project-status@personal"

if "$CLAUDE_BIN" plugin install project-status@personal --yes 2>/dev/null; then
  :
else
  "$CLAUDE_BIN" plugin install project-status@personal
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

printf "\n"
info "=================================================="
info " project-status plugin installed successfully."
info "=================================================="
printf "\n"
printf "  Next step: reload VS Code / Claude Code.\n"
printf "    Cmd+Shift+P → Developer: Reload Window\n"
printf "\n"
printf "  Then open any project and run:  /project-status\n"
printf "\n"
printf "  Optional — auto-update PROJECT_STATUS.md before every git commit:\n"
printf "    sh %s/scripts/install-git-hook.sh\n" "$PLUGIN_ROOT"
printf "  (run from your project root, once per project)\n"
printf "\n"
