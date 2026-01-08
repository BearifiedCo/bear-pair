#!/bin/bash
# Bear Pair - Check Navigator Feedback Hook
# Called by Stop hook to ensure Navigator feedback is addressed
#
# Exit 0: Allow stop (no pending feedback)
# Exit 2: Block stop (pending feedback needs addressing)

set -euo pipefail

BEAR_PAIR_DIR="${HOME}/.bear-pair"

# Read hook input from stdin
input=$(cat)

# Find active session
find_active_session() {
  local session_dir=""

  for dir in "${BEAR_PAIR_DIR}"/session-*/; do
    if [ -d "$dir" ]; then
      local status_file="${dir}status.json"
      if [ -f "$status_file" ]; then
        local status
        status=$(jq -r '.status' "$status_file" 2>/dev/null || echo "unknown")
        if [ "$status" = "active" ]; then
          session_dir="$dir"
          break
        fi
      fi
    fi
  done

  echo "$session_dir"
}

check_pending_feedback() {
  local session_dir="$1"
  local feedback_file="${session_dir}navigator-feedback.md"

  if [ ! -f "$feedback_file" ]; then
    return 0  # No feedback file, allow stop
  fi

  if [ ! -s "$feedback_file" ]; then
    return 0  # Feedback file empty, allow stop
  fi

  # Has pending feedback
  return 1
}

# Main logic
session_dir=$(find_active_session)

if [ -z "$session_dir" ]; then
  # No active Bear Pair session, allow stop
  echo '{"decision": "approve"}'
  exit 0
fi

if check_pending_feedback "$session_dir"; then
  # No pending feedback, allow stop
  echo '{"decision": "approve", "systemMessage": "Navigator approved - no pending feedback."}'
  exit 0
else
  # Has pending feedback, block stop
  feedback=$(cat "${session_dir}navigator-feedback.md")

  cat <<EOF
{
  "decision": "block",
  "reason": "Navigator Bear has pending feedback that needs addressing",
  "systemMessage": "[NAVIGATOR FEEDBACK]\n$feedback\n\nPlease address this feedback before completing."
}
EOF
  exit 2
fi
