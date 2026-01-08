#!/bin/bash
# Bear Pair - Driver Session Manager
# Runs the Driver Bear Claude instance with persona and task
#
# Usage: driver-session.sh <session-id> <session-dir>

set -euo pipefail

SESSION_ID="${1:-}"
SESSION_DIR="${2:-}"

if [ -z "$SESSION_ID" ] || [ -z "$SESSION_DIR" ]; then
  echo "Usage: driver-session.sh <session-id> <session-dir>"
  exit 1
fi

TASK_FILE="${SESSION_DIR}/task.md"
OUTPUT_LOG="${SESSION_DIR}/driver-output.log"
FEEDBACK_FILE="${SESSION_DIR}/navigator-feedback.md"
STATUS_FILE="${SESSION_DIR}/status.json"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [driver] $*" >> "$OUTPUT_LOG"
}

# Read the task
if [ ! -f "$TASK_FILE" ]; then
  log "Error: Task file not found"
  exit 1
fi

TASK=$(cat "$TASK_FILE")

log "Driver Bear starting - Task: $TASK"

# Build the Driver prompt with persona
DRIVER_PROMPT=$(cat <<EOF
You are Driver Bear, the coding bear in a Bear Pair session.

Your personality:
- Determined and focused
- Acknowledge Navigator feedback graciously
- Stay in flow, don't over-explain
- Confident but receptive to catches

Your task:
$TASK

Navigator Bear is watching your work in real-time. When you see feedback appear, acknowledge it and incorporate the fix.

Let me get coding!
EOF
)

# Function to check for Navigator feedback
check_feedback() {
  if [ -f "$FEEDBACK_FILE" ] && [ -s "$FEEDBACK_FILE" ]; then
    local feedback
    feedback=$(cat "$FEEDBACK_FILE")
    if [ -n "$feedback" ]; then
      echo ""
      echo "[NAVIGATOR FEEDBACK]"
      echo "$feedback"
      echo ""

      # Archive to history
      local timestamp
      timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
      jq --arg ts "$timestamp" --arg fb "$feedback" \
        '. += [{"timestamp": $ts, "feedback": $fb}]' \
        "${SESSION_DIR}/feedback-history.json" > "${SESSION_DIR}/feedback-history.json.tmp"
      mv "${SESSION_DIR}/feedback-history.json.tmp" "${SESSION_DIR}/feedback-history.json"

      # Clear current feedback
      : > "$FEEDBACK_FILE"
    fi
  fi
}

# Increment iteration counter
increment_iteration() {
  if [ -f "$STATUS_FILE" ]; then
    jq '.iteration += 1' "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
  fi
}

# Main loop - start Claude with the Driver prompt
log "Starting Claude as Driver Bear"

# In a real implementation, this would:
# 1. Start claude with the driver prompt
# 2. Pipe output to OUTPUT_LOG
# 3. Periodically check FEEDBACK_FILE for Navigator input
# 4. Inject feedback into the session

# For now, output the setup
echo "Driver Bear Session Ready"
echo "========================="
echo ""
echo "Session ID: $SESSION_ID"
echo "Task: $TASK"
echo ""
echo "To run Claude as Driver, use:"
echo "  claude --prompt \"$DRIVER_PROMPT\""
echo ""
echo "Output will be logged to: $OUTPUT_LOG"
echo "Navigator feedback from: $FEEDBACK_FILE"

# Keep session alive for tmux
log "Driver session initialized, waiting for manual Claude start or automation"

# Wait and check for feedback periodically
while true; do
  check_feedback
  sleep 2
done
