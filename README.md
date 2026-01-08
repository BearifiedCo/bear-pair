# Bear Pair

**Part of [Bear Suite](https://github.com/BearifiedCo/bear-suite) — The intelligent AI collaboration toolkit**

Real-time dual Claude orchestration for AI pair programming.

**By [BearifiedCo](https://bearified.co)** | MIT License

---

## The Problem

Solo developers miss the benefits of pair programming—a second set of eyes catching errors in real-time, not after the fact.

## The Solution

Two Claude instances running simultaneously:
- **Driver Bear** — Writes code, implements features
- **Navigator Bear** — Watches in real-time, catches errors, suggests improvements

**Philosophy**: *"Two perspectives are better than one."*

Bear Pair brings the proven methodology of pair programming to AI-assisted development. Just as human pairs catch more bugs and produce better code, dual Claude orchestration provides continuous review and real-time feedback.

---

## How It Works

```
┌─────────────────┐     watches      ┌─────────────────┐
│   Driver Bear   │ ──────────────▶  │  Navigator Bear │
│   (codes)       │                  │  (reviews)      │
│                 │ ◀────────────── │                  │
└─────────────────┘   interrupts     └─────────────────┘
                      with issues
```

1. Start a Bear Pair session with `/bear-pair`
2. Driver Bear receives the coding task
3. Navigator Bear watches Driver's output in real-time
4. When Navigator spots an issue, it interrupts with feedback
5. Driver incorporates feedback and continues
6. Cycle continues until task complete

---

## Installation

### From Source

```bash
# Clone the plugin
git clone https://github.com/BearifiedCo/bear-pair.git

# Use with Claude Code
claude --plugin-dir /path/to/bear-pair
```

### Add to Your Project

```bash
cp -r bear-pair ~/.claude/plugins/
```

---

## Commands

### `/bear-pair <task>`

Start a Bear Pair session.

```
/bear-pair "Add input validation to the login form"
```

### `/bear-status`

Check the status of an active session.

```
/bear-status
```

### `/bear-stop`

End the Bear Pair session gracefully.

```
/bear-stop
```

---

## Bear Personalities

### Driver Bear

- Determined and focused
- Acknowledges feedback graciously
- Stays in flow, doesn't over-explain
- *"Good catch, Navigator!"*

### Navigator Bear

- Watchful and alert
- Helpful, not nitpicky
- Concise in feedback
- *"Hold up, Driver—I see an issue..."*

---

## Architecture

```
~/.bear-pair/
└── session-{uuid}/
    ├── task.md              # Original task
    ├── driver-output.log    # Driver's stdout
    ├── navigator-feedback.md # Navigator's feedback
    ├── feedback-history.json # All feedback given
    └── status.json          # Session state
```

**Technical implementation:**
- tmux session orchestration
- File-based IPC for real-time communication
- Hooks for automatic feedback injection

---

## Requirements

- macOS (darwin)
- tmux
- Claude Code

---

## Bear Suite Integration

Bear Pair works seamlessly with [Bear Call](https://github.com/BearifiedCo/bear-call) for critical escalations:

```
Bear Pair running
        ↓
Navigator catches critical issue
        ↓
/bear-escalate "Security vuln in auth code" --urgency critical
        ↓
Human's phone rings (Bear Call)
        ↓
Human provides guidance
        ↓
Bears continue with input
```

**Commands:**
- `/bear-escalate <reason> --urgency <level>` — Navigator escalates to human via voice call

**Install both for full Bear Suite:**
```bash
claude --plugin-dir ~/plugins/bear-pair --plugin-dir ~/plugins/bear-call
```

---

## When to Use Bear Pair

**Ideal for:**
- Complex refactoring requiring careful review
- Implementing features with security implications
- Code that needs real-time validation
- Learning new patterns with continuous feedback
- High-stakes changes where errors are costly

**Not designed for:**
- Quick one-line fixes
- Simple file operations
- Tasks that don't benefit from review

---

## Development

### Plugin Structure

```
bear-pair/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── bear-pair.md
│   ├── bear-status.md
│   ├── bear-stop.md
│   └── bear-escalate.md
├── skills/
│   ├── driver-persona/
│   │   └── SKILL.md
│   └── navigator-persona/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── scripts/
│   ├── pair-orchestrator.sh
│   ├── driver-session.sh
│   ├── navigator-session.sh
│   ├── check-navigator-feedback.sh
│   └── session-init.sh
└── README.md
```

---

## Future: Cross-Machine Mode

Bear Pair can be extended to work across machines using Tailscale:

- Driver on Mac Mini M4 Pro
- Navigator on MacBook Pro M3 Pro
- SSH + tmux communication

---

## License

MIT License — Free to use, modify, and distribute.

---

## Credits

**[BearifiedCo](https://bearified.co)** — Making AI development friendlier, one bear at a time.

**Inspired by:**
- [Ralph Wiggum Technique](https://ghuntley.com/ralph/) by Geoffrey Huntley
- Traditional pair programming practices
- The belief that two perspectives are better than one

---

*"Two bears are smarter than one. Let's pair up!"*
