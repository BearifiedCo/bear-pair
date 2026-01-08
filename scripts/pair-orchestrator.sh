#!/bin/bash
# Bear Pair - Main Orchestrator
# Spawns and manages Driver + Navigator Claude sessions
#
# Usage:
#   pair-orchestrator.sh start <session-id> <task>
#   pair-orchestrator.sh stop <session-id>
#   pair-orchestrator.sh force-stop <session-id>
#   pair-orchestrator.sh status <session-id>

set -euo pipefail

BEAR_PAIR_DIR="${HOME}/.bear-pair"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [bear-pair] $*"
}

create_session_dir() {
  local session_id="$1"
  local session_dir="${BEAR_PAIR_DIR}/session-${session_id}"

  mkdir -p "$session_dir"

  # Initialize empty files
  touch "${session_dir}/driver-output.log"
  touch "${session_dir}/navigator-feedback.md"
  echo '[]' > "${session_dir}/feedback-history.json"

  echo "$session_dir"
}

write_status() {
  local session_dir="$1"
  local status="$2"
  local driver_pid="${3:-}"
  local navigator_pid="${4:-}"

  cat > "${session_dir}/status.json" <<EOF
{
  "session_id": "$(basename "$session_dir" | sed 's/session-//')",
  "status": "$status",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "driver_pid": ${driver_pid:-null},
  "navigator_pid": ${navigator_pid:-null},
  "iteration": 0,
  "feedback_count": 0
}
EOF
}

start_session() {
  local session_id="$1"
  local task="$2"

  log "Starting Bear Pair session: $session_id"

  # Create session directory
  local session_dir
  session_dir=$(create_session_dir "$session_id")

  # Write task
  echo "$task" > "${session_dir}/task.md"

  # Initialize status
  write_status "$session_dir" "starting"

  # Start Driver session in tmux (with remain-on-exit for debugging)
  local driver_session="bear-driver-${session_id:0:8}"
  tmux new-session -d -s "$driver_session"
  tmux set-option -t "$driver_session" remain-on-exit on
  tmux send-keys -t "$driver_session" "bash '${SCRIPT_DIR}/driver-session.sh' '${session_id}' '${session_dir}'" Enter

  sleep 1  # Allow session to initialize

  local driver_pid
  driver_pid=$(tmux list-panes -t "$driver_session" -F '#{pane_pid}' 2>/dev/null | head -1 || echo "0")

  # Start Navigator session in tmux
  local navigator_session="bear-nav-${session_id:0:8}"
  tmux new-session -d -s "$navigator_session"
  tmux set-option -t "$navigator_session" remain-on-exit on
  tmux send-keys -t "$navigator_session" "bash '${SCRIPT_DIR}/navigator-session.sh' '${session_id}' '${session_dir}'" Enter

  sleep 1

  local navigator_pid
  navigator_pid=$(tmux list-panes -t "$navigator_session" -F '#{pane_pid}' 2>/dev/null | head -1 || echo "0")

  # Update status with PIDs
  write_status "$session_dir" "active" "$driver_pid" "$navigator_pid"

  log "Session started - Driver: $driver_session, Navigator: $navigator_session"

  # Output for command
  cat <<EOF

Bear Pair Session Started!

Driver Bear is now coding your task.
Navigator Bear is watching for issues.

Session ID: $session_id
Task: $task

Sessions:
  Driver: $driver_session
  Navigator: $navigator_session

To check status: /bear-status $session_id
To attach to Driver: tmux attach -t $driver_session
To stop: /bear-stop $session_id

EOF
}

stop_session() {
  local session_id="$1"
  local force="${2:-false}"

  log "Stopping Bear Pair session: $session_id"

  local session_dir="${BEAR_PAIR_DIR}/session-${session_id}"

  if [ ! -d "$session_dir" ]; then
    echo "Session not found: $session_id"
    exit 1
  fi

  # Read status
  local status
  status=$(jq -r '.status' "${session_dir}/status.json" 2>/dev/null || echo "unknown")

  if [ "$status" = "complete" ] && [ "$force" != "true" ]; then
    echo "Session already complete: $session_id"
    exit 0
  fi

  # Kill tmux sessions
  local driver_session="bear-driver-${session_id:0:8}"
  local navigator_session="bear-nav-${session_id:0:8}"

  tmux kill-session -t "$driver_session" 2>/dev/null || true
  tmux kill-session -t "$navigator_session" 2>/dev/null || true

  # Update status
  jq '.status = "complete"' "${session_dir}/status.json" > "${session_dir}/status.json.tmp"
  mv "${session_dir}/status.json.tmp" "${session_dir}/status.json"

  # Get stats
  local feedback_count
  feedback_count=$(jq 'length' "${session_dir}/feedback-history.json" 2>/dev/null || echo "0")

  local iteration
  iteration=$(jq -r '.iteration' "${session_dir}/status.json" 2>/dev/null || echo "0")

  cat <<EOF

Bear Pair Session Complete!

Session: $session_id
Iterations: $iteration
Navigator Catches: $feedback_count

Both bears are now hibernating.

EOF
}

show_status() {
  local session_id="$1"

  local session_dir="${BEAR_PAIR_DIR}/session-${session_id}"

  if [ ! -d "$session_dir" ]; then
    echo "Session not found: $session_id"
    exit 1
  fi

  local status_json="${session_dir}/status.json"

  if [ ! -f "$status_json" ]; then
    echo "Status file not found"
    exit 1
  fi

  local status
  status=$(jq -r '.status' "$status_json")

  local started_at
  started_at=$(jq -r '.started_at' "$status_json")

  local iteration
  iteration=$(jq -r '.iteration' "$status_json")

  local feedback_count
  feedback_count=$(jq 'length' "${session_dir}/feedback-history.json" 2>/dev/null || echo "0")

  local task
  task=$(head -1 "${session_dir}/task.md" 2>/dev/null || echo "Unknown")

  cat <<EOF

Bear Pair Status

Session: $session_id
Status: $status
Started: $started_at

Driver Bear: Working on iteration $iteration
Navigator Bear: Provided $feedback_count feedback items

Task: $task

EOF
}

# Main command dispatch
case "${1:-help}" in
  start)
    start_session "${2:-}" "${3:-}"
    ;;
  stop)
    stop_session "${2:-}"
    ;;
  force-stop)
    stop_session "${2:-}" "true"
    ;;
  status)
    show_status "${2:-}"
    ;;
  *)
    echo "Usage: pair-orchestrator.sh {start|stop|force-stop|status} <session-id> [task]"
    exit 1
    ;;
esac
