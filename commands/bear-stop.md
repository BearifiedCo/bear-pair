---
name: bear-stop
description: Stop an active Bear Pair session gracefully
argument-hint: "[session-id]"
allowed-tools:
  - Bash
  - Read
---

# Bear Pair - Stop Session

Gracefully stop an active Bear Pair session.

## Execution Steps

To stop a session:

1. If session-id provided, use that. Otherwise, find the most recent active session
2. Execute the orchestrator stop command:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/pair-orchestrator.sh stop "$SESSION_ID"
```

3. The orchestrator will:
   - Signal Driver and Navigator to stop
   - Wait for graceful shutdown
   - Generate final summary
   - Clean up session files

## Output Format

```
Bear Pair Session Complete!

Session: {session_id}
Duration: {duration}
Iterations: {n}
Navigator Catches: {m}

Final Stats:
- Issues caught by Navigator: {count}
- Files modified: {count}
- Task status: {complete|partial}

Both bears are now hibernating.
```

## Force Stop

If a session is stuck, force stop:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/pair-orchestrator.sh force-stop "$SESSION_ID"
```

## Tips

- Allow sessions to complete naturally when possible
- Force stop only if session is unresponsive
- Session data preserved in `~/.bear-pair/session-{id}/`
