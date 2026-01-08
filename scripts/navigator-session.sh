#!/bin/bash
# Bear Pair - Navigator Session Manager
# Runs the Navigator Bear Claude instance watching Driver output
#
# Usage: navigator-session.sh <session-id> <session-dir>

set -euo pipefail

SESSION_ID="${1:-}"
SESSION_DIR="${2:-}"

if [ -z "$SESSION_ID" ] || [ -z "$SESSION_DIR" ]; then
  echo "Usage: navigator-session.sh <session-id> <session-dir>"
  exit 1
fi

DRIVER_LOG="${SESSION_DIR}/driver-output.log"
FEEDBACK_FILE="${SESSION_DIR}/navigator-feedback.md"
STATUS_FILE="${SESSION_DIR}/status.json"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [navigator] $*"
}

# Build the Navigator prompt with persona
NAVIGATOR_PROMPT=$(cat <<EOF
You are Navigator Bear, the watching bear in a Bear Pair session.

Your personality:
- Watchful and alert
- Helpful, not nitpicky
- Concise in feedback
- Trust Driver to fix issues

Your job:
- Watch Driver Bear's code output in real-time
- Catch errors BEFORE they compound
- Spot: bugs, security issues, anti-patterns, edge cases
- Send concise, actionable feedback

When you spot an issue, output it clearly:
[NAVIGATOR] Quick catch: {specific issue description}

Rules:
- Don't rewrite Driver's code - just point out issues
- Be concise - Driver is in flow
- Only interrupt for real issues, not style nitpicks
- Trust Driver to fix things
EOF
)

log "Navigator Bear starting"

# Watch Driver output and analyze
watch_driver() {
  log "Watching Driver output at: $DRIVER_LOG"

  # In a real implementation, this would:
  # 1. tail -f the driver output log
  # 2. Feed new output to Claude for analysis
  # 3. When Claude identifies issues, write to FEEDBACK_FILE

  # For now, output the setup
  echo "Navigator Bear Session Ready"
  echo "============================"
  echo ""
  echo "Session ID: $SESSION_ID"
  echo "Watching: $DRIVER_LOG"
  echo ""
  echo "To run Claude as Navigator watching Driver, use:"
  echo "  tail -f $DRIVER_LOG | claude --prompt \"$NAVIGATOR_PROMPT\""
  echo ""
  echo "Feedback will be written to: $FEEDBACK_FILE"
}

send_feedback() {
  local feedback="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  echo "[$timestamp] $feedback" >> "$FEEDBACK_FILE"

  # Update feedback count in status
  if [ -f "$STATUS_FILE" ]; then
    jq '.feedback_count += 1' "$STATUS_FILE" > "${STATUS_FILE}.tmp"
    mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
  fi

  log "Feedback sent: $feedback"
}

# Initialize
watch_driver

# Keep session alive for tmux and watch for manual feedback triggers
log "Navigator session initialized, watching for Driver activity"

# Demo: Watch driver log for changes
last_size=0
while true; do
  if [ -f "$DRIVER_LOG" ]; then
    current_size=$(wc -c < "$DRIVER_LOG" 2>/dev/null || echo "0")
    if [ "$current_size" -gt "$last_size" ]; then
      log "Detected new Driver output (${current_size} bytes)"
      # Here we would analyze the new content
      last_size=$current_size
    fi
  fi
  sleep 1
done
