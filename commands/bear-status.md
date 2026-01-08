---
name: bear-status
description: Show status of active Bear Pair session including iteration count and feedback history
argument-hint: "[session-id]"
allowed-tools:
  - Bash
  - Read
---

# Bear Pair - Session Status

Display the current status of an active Bear Pair session.

## Execution Steps

To show session status:

1. If session-id provided, use that. Otherwise, find the most recent active session in `~/.bear-pair/`
2. Read `~/.bear-pair/session-{id}/status.json`
3. Read `~/.bear-pair/session-{id}/feedback-history.json` for feedback count
4. Display status with bear-themed messaging

## Output Format

```
Bear Pair Status

Session: {session_id}
Status: {active|paused|complete}
Started: {timestamp}

Driver Bear: Working on iteration {n}
Navigator Bear: Provided {m} feedback items

Recent Feedback:
- {feedback_1}
- {feedback_2}

Task: {task_summary}
```

## When No Session Active

```
No active Bear Pair session found.

To start a session: /bear-pair "your task here"
```

## Tips

- Use session-id to check a specific session
- Feedback history shows Navigator's catches
- Iteration count shows how many times Driver has looped
