#!/bin/bash
# Bear Pair - Session Initialization Hook
# Called on SessionStart to set up Bear Pair environment
#
# Sets environment variables and checks for active sessions

set -euo pipefail

BEAR_PAIR_DIR="${HOME}/.bear-pair"

# Ensure bear pair directory exists
mkdir -p "$BEAR_PAIR_DIR"

# Find any active sessions
find_active_sessions() {
  local count=0

  for dir in "${BEAR_PAIR_DIR}"/session-*/; do
    if [ -d "$dir" ]; then
      local status_file="${dir}status.json"
      if [ -f "$status_file" ]; then
        local status
        status=$(jq -r '.status' "$status_file" 2>/dev/null || echo "unknown")
        if [ "$status" = "active" ]; then
          count=$((count + 1))
        fi
      fi
    fi
  done

  echo "$count"
}

active_count=$(find_active_sessions)

if [ "$active_count" -gt 0 ]; then
  echo "[Bear Pair] Found $active_count active session(s). Use /bear-status to check."
fi

# Success - no blocking output
exit 0
