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
PROMPT_FILE="${SESSION_DIR}/driver-prompt.md"

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

# Main - start Claude with the Driver prompt
log "Starting Claude as Driver Bear"

# Display session info
echo "🐻 Driver Bear Session Starting"
echo "================================"
echo ""
echo "Session ID: $SESSION_ID"
echo "Task: $TASK"
echo ""
echo "Output logged to: $OUTPUT_LOG"
echo "Navigator feedback from: $FEEDBACK_FILE"
echo ""
echo "Starting Claude in 3 seconds..."
sleep 3

# Create the prompt file for Claude (avoiding heredoc nesting issues)
{
  echo "You are Driver Bear, the coding bear in a Bear Pair session."
  echo ""
  echo "Your personality:"
  echo "- Determined and focused"
  echo "- Acknowledge Navigator feedback graciously"
  echo "- Stay in flow, don't over-explain"
  echo "- Confident but receptive to catches"
  echo ""
  echo "Your task:"
  echo "$TASK"
  echo ""
  echo "Navigator Bear is watching your work in real-time. When you see feedback appear, acknowledge it and incorporate the fix."
  echo ""
  echo "Let me get coding!"
  echo ""
  echo "## Session Files"
  echo ""
  echo "- **Driver Output Log**: $OUTPUT_LOG (Navigator is watching this)"
  echo "- **Navigator Feedback**: $FEEDBACK_FILE (check this for catches)"
  echo "- **Status**: $STATUS_FILE"
  echo ""
  echo "## Important"
  echo ""
  echo "1. Navigator Bear is watching your output in real-time via the log file"
  echo "2. Check $FEEDBACK_FILE periodically for Navigator catches"
  echo "3. When you see feedback, acknowledge and incorporate the fix"
  echo "4. Stay focused on the task - Navigator handles the watching"
  echo ""
  echo "Now, let's get coding on: **$TASK**"
} > "$PROMPT_FILE"

# Start background feedback monitor that injects feedback into terminal
(
  while true; do
    if [ -f "$FEEDBACK_FILE" ] && [ -s "$FEEDBACK_FILE" ]; then
      feedback=$(cat "$FEEDBACK_FILE")
      if [ -n "$feedback" ]; then
        # Display feedback prominently
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║  🐻 NAVIGATOR FEEDBACK                                       ║"
        echo "╠══════════════════════════════════════════════════════════════╣"
        echo "$feedback" | while IFS= read -r line; do
          printf "║  %-60s ║\n" "$line"
        done
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""

        # Archive feedback
        timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        if [ -f "${SESSION_DIR}/feedback-history.json" ]; then
          jq --arg ts "$timestamp" --arg fb "$feedback" \
            '. += [{"timestamp": $ts, "feedback": $fb}]' \
            "${SESSION_DIR}/feedback-history.json" > "${SESSION_DIR}/feedback-history.json.tmp" 2>/dev/null && \
            mv "${SESSION_DIR}/feedback-history.json.tmp" "${SESSION_DIR}/feedback-history.json"
        fi

        # Clear current feedback
        : > "$FEEDBACK_FILE"
      fi
    fi
    sleep 2
  done
) &
FEEDBACK_MONITOR_PID=$!

# Cleanup on exit
cleanup() {
  log "Driver session ending"
  kill $FEEDBACK_MONITOR_PID 2>/dev/null || true

  # Update status
  if [ -f "$STATUS_FILE" ]; then
    jq '.status = "ended" | .end_time = now' "$STATUS_FILE" > "${STATUS_FILE}.tmp" 2>/dev/null && \
      mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
  fi
}
trap cleanup EXIT

# Start Claude with the driver prompt, capturing output to log
log "Invoking Claude Code as Driver Bear"

# Use script command to capture output while keeping terminal interactive
# -F flushes output after each write for real-time monitoring
if command -v script &> /dev/null; then
  # macOS/BSD script syntax
  if [[ "$OSTYPE" == "darwin"* ]]; then
    script -F "$OUTPUT_LOG" claude --prompt-file "$PROMPT_FILE"
  else
    # Linux script syntax
    script -f "$OUTPUT_LOG" -c "claude --prompt-file '$PROMPT_FILE'"
  fi
else
  # Fallback: run Claude directly with tee (less ideal for real-time)
  claude --prompt-file "$PROMPT_FILE" 2>&1 | tee -a "$OUTPUT_LOG"
fi

log "Driver session completed"
