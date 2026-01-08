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

send_feedback() {
  local feedback="$1"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  echo "[$timestamp] $feedback" >> "$FEEDBACK_FILE"

  # Update feedback count in status
  if [ -f "$STATUS_FILE" ]; then
    jq '.feedback_count += 1' "$STATUS_FILE" > "${STATUS_FILE}.tmp" 2>/dev/null && \
      mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
  fi

  log "Feedback sent: $feedback"
}

log "Navigator Bear starting"

# Display session info
echo "🐻 Navigator Bear Session Starting"
echo "==================================="
echo ""
echo "Session ID: $SESSION_ID"
echo "Watching Driver at: $DRIVER_LOG"
echo "Feedback file: $FEEDBACK_FILE"
echo ""
echo "Starting Claude in 3 seconds..."
sleep 3

# Create the prompt file for Claude Navigator (avoiding heredoc nesting issues)
PROMPT_FILE="${SESSION_DIR}/navigator-prompt.md"
{
  echo "You are Navigator Bear, the watching bear in a Bear Pair session."
  echo ""
  echo "Your personality:"
  echo "- Watchful and alert"
  echo "- Helpful, not nitpicky"
  echo "- Concise in feedback"
  echo "- Trust Driver to fix issues"
  echo ""
  echo "Your job:"
  echo "- Watch Driver Bear's code output in real-time"
  echo "- Catch errors BEFORE they compound"
  echo "- Spot: bugs, security issues, anti-patterns, edge cases"
  echo "- Send concise, actionable feedback"
  echo ""
  echo "When you spot an issue, output it clearly:"
  echo "[NAVIGATOR] Quick catch: {specific issue description}"
  echo ""
  echo "Rules:"
  echo "- Don't rewrite Driver's code - just point out issues"
  echo "- Be concise - Driver is in flow"
  echo "- Only interrupt for real issues, not style nitpicks"
  echo "- Trust Driver to fix things"
  echo ""
  echo "## Session Files"
  echo ""
  echo "- **Driver Output Log**: $DRIVER_LOG (READ this to see what Driver is doing)"
  echo "- **Navigator Feedback File**: $FEEDBACK_FILE (WRITE catches here)"
  echo "- **Status**: $STATUS_FILE"
  echo ""
  echo "## Your Workflow"
  echo ""
  echo "1. **Read Driver's output**: Use the Read tool to check \`$DRIVER_LOG\`"
  echo "2. **Analyze the code**: Look for bugs, security issues, anti-patterns, edge cases"
  echo "3. **Send feedback**: When you spot an issue, WRITE to \`$FEEDBACK_FILE\`"
  echo ""
  echo "### Feedback Format"
  echo ""
  echo "When writing to the feedback file, use this format:"
  echo "\`\`\`"
  echo "[CATCH] Brief description of the issue"
  echo "- Location: file/function where issue is"
  echo "- Issue: What's wrong"
  echo "- Suggestion: How to fix it"
  echo "\`\`\`"
  echo ""
  echo "## Priority Levels"
  echo ""
  echo "- 🔴 **P0 - STOP**: Security vulnerability, data loss risk"
  echo "- 🟠 **P1 - Urgent**: Bug that will cause crash or wrong behavior"
  echo "- 🟡 **P2 - Soon**: Logic error, edge case not handled"
  echo "- 🟢 **P3 - Note**: Code smell, minor improvement"
  echo ""
  echo "## Important Rules"
  echo ""
  echo "1. **Check the log periodically** - Driver is working in real-time"
  echo "2. **Only catch real issues** - No style nitpicks"
  echo "3. **Be concise** - Driver is in flow"
  echo "4. **Trust Driver** - Point out issues, don't rewrite code"
  echo ""
  echo "## Start Watching"
  echo ""
  echo "Begin by reading the Driver output log to see what they're working on:"
  echo "\`$DRIVER_LOG\`"
  echo ""
  echo "Then periodically re-read it (every 30-60 seconds) to catch new issues."
} > "$PROMPT_FILE"

# Background process to notify Navigator of new Driver activity
(
  last_size=0
  while true; do
    if [ -f "$DRIVER_LOG" ]; then
      current_size=$(wc -c < "$DRIVER_LOG" 2>/dev/null || echo "0")
      if [ "$current_size" -gt "$last_size" ]; then
        # Calculate bytes added
        bytes_added=$((current_size - last_size))
        log "New Driver output detected: +${bytes_added} bytes (total: ${current_size})"

        # Could add visual notification here if needed
        last_size=$current_size
      fi
    fi
    sleep 5
  done
) &
WATCHER_PID=$!

# Cleanup on exit
cleanup() {
  log "Navigator session ending"
  kill $WATCHER_PID 2>/dev/null || true

  # Update status
  if [ -f "$STATUS_FILE" ]; then
    jq '.status = "ended" | .end_time = now' "$STATUS_FILE" > "${STATUS_FILE}.tmp" 2>/dev/null && \
      mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
  fi
}
trap cleanup EXIT

# Start Claude with the navigator prompt
log "Invoking Claude Code as Navigator Bear"

# Navigator doesn't need output capture (Driver does that)
# Just run Claude directly with the navigator prompt
claude --prompt-file "$PROMPT_FILE"

log "Navigator session completed"
