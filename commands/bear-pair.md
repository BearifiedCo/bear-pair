---
name: bear-pair
description: Start a Bear Pair session with Driver and Navigator bears for real-time AI pair programming
argument-hint: "<task description>"
allowed-tools:
  - Bash
  - Read
  - Write
---

# Bear Pair - Start Session

Start a real-time AI pair programming session with two Claude instances working together.

## How It Works

1. **Driver Bear** receives the coding task and implements it
2. **Navigator Bear** watches Driver's output in real-time
3. Navigator catches errors, security issues, and anti-patterns
4. Navigator's feedback appears in Driver's session
5. Both bears work together until task is complete

## Execution Steps

To start a Bear Pair session:

1. Create a unique session ID using `uuidgen`
2. Create the session directory at `~/.bear-pair/session-{id}/`
3. Write the task to `~/.bear-pair/session-{id}/task.md`
4. Initialize status.json with session metadata
5. Execute the orchestrator script:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/pair-orchestrator.sh start "$SESSION_ID" "$TASK"
```

## Output Format

On successful start:

```
Bear Pair Session Started!

Driver Bear is now coding your task.
Navigator Bear is watching for issues.

Session ID: {id}
Task: {task}

To check status: /bear-status
To stop: /bear-stop
```

## Tips

- Keep task descriptions clear and specific
- Bear Pair works best for implementation tasks
- Navigator catches issues in real-time, not after completion
- Both bears have distinct, helpful personalities
