---
name: bear-escalate
description: Navigator Bear detected a critical issue - escalate to human via Bear Call
argument-hint: "<reason> [--urgency critical|high]"
allowed-tools:
  - Bash
  - Read
---

# Bear Pair → Bear Call Escalation

When Navigator Bear catches a critical issue that needs immediate human attention, trigger a Bear Call.

## When to Use

Navigator Bear should escalate when:
- Security vulnerability detected in Driver's code
- Production-breaking bug about to be committed
- Architecture decision needs human sign-off
- Something feels wrong but can't be auto-fixed

## Execution

```bash
# Check if Bear Call is available
if [ -f ~/claude-cto/voice-calling/escalate.sh ]; then
  ~/claude-cto/voice-calling/escalate.sh \
    --reason "Navigator Bear Alert: <issue-description>" \
    --urgency <critical|high>
else
  echo "Bear Call not available - logging issue locally"
  echo "[$(date)] ESCALATION: <issue-description>" >> ~/.bear-pair/escalations.log
fi
```

## Urgency Selection

| Situation | Urgency |
|-----------|---------|
| Security vulnerability | critical |
| Data loss risk | critical |
| Production breaking | critical |
| Major bug | high |
| Architecture concern | high |
| Code smell / debt | (don't call, just log) |

## Bear Suite Integration

This creates a feedback loop:
1. Human starts Bear Pair session
2. Driver codes, Navigator watches
3. Navigator catches critical issue
4. Bear Call alerts human
5. Human provides guidance
6. Bears continue with human input

## Response Format

After calling:
- "Navigator Bear is calling in the human! Issue: <description>"
- Report call status
- Continue pair session (don't stop - human may respond via call)
