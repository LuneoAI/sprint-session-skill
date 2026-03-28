# sprint-session

A Claude Code skill for managing multi-sprint projects across multiple terminal sessions without losing context.

## The Problem

When a project spans many sprints and terminal sessions, context is lost:

- A later sprint only sees the last small task
- The actual goal fades
- Architecture decisions are forgotten
- The next terminal doesn't know where to pick up
- The context window fills up and output quality degrades silently

## The Solution

Two documents and three modes.

**Two documents:**
- **Master Brief** — the strategic north star (vision, architecture, priorities, decisions). Updated rarely, stays lean.
- **Sprint File** — the operational record per sprint (tasks, results, what's next). Updated after every sprint.

**Three modes:**

| Mode | When | What it does |
|------|------|-------------|
| `:init` | New project | Brainstorming → Master Brief + first Sprint Plan |
| `:work` | Each sprint | Read both docs → execute → handoff to next terminal |
| `:review` | End of wave/project | E2E review across all sprints |

## How It Works

```
Terminal 1:  /sprint-session:init
             Brainstorming → Master Brief + Sprint-001
                  ↓ copy-paste the two links

Terminal 2:  Sprint 1 → Handoff + Sprint-002
                  ↓ copy-paste

Terminal 3:  Sprint 2 → Handoff + Sprint-003
                  ↓ copy-paste

Terminal 4:  Sprint 3 (context tight → clean abort) + Sprint-003b
                  ↓ copy-paste

Terminal N:  /sprint-session:review → E2E check → Project ✅
```

**For you this means:** You only copy-paste two file paths into the next terminal. Claude Code does the rest.

## Key Features

- **Context Window Protection** — 20% reserve rule, automatic clean abort before quality degrades
- **Auto-Commit After Every Task** — survives disconnects, power outages, unstable connections
- **Quality Baseline** — defines code standards once, every sprint retro checks against it
- **Decision Log** — records WHY architecture decisions were made, prevents silent undermining
- **Scope Creep Detection** — automatic alert when project exceeds 150% of planned sprints
- **Wave Reviews** — lightweight consistency checks between waves, not just at the end
- **Rollback Strategy** — graduated response from bug fix to git revert, never destroys history
- **Multi-Terminal Awareness** — checks for conflicts before pushing when multiple terminals are active
- **Mobile/Disconnect Recovery** — git history + sprint documents reconstruct exact state, no chat history needed

## Installation

Copy the skill folder into your Claude Code skills directory:

```bash
# Clone the repo
git clone https://github.com/LuneoAI/sprint-session-skill.git

# Copy the skill into your Claude Code setup
cp -r sprint-session-skill/sprint-session ~/.claude/skills/
```

That's it. The skill is now available as `/sprint-session` in Claude Code.

## Quick Start

### Starting a new project
```
You: /sprint-session:init
You: "I want to build a task management API with React frontend"
```

Claude Code will brainstorm with you, then generate:
- `docs/sprints/task-manager/master-brief.md`
- `docs/sprints/task-manager/sprint-001.md`

### Running a sprint
Open a new terminal and paste the two links from the handoff:

```
You: Here is the Master Brief: docs/sprints/task-manager/master-brief.md
     And here the Sprint Plan: docs/sprints/task-manager/sprint-001.md
     Read both, then execute Sprint 1.
```

### After a disconnect
```
You: "Session broke off, where are we?"
```
Claude checks git log + sprint files and tells you exactly what's done and what's missing.

### Final review
```
You: /sprint-session:review
```

## When to Use This

**Yes:**
- Project larger than one sprint
- Multiple sessions or terminals needed
- Architecture decisions involved
- Risk of context being lost across sessions

**No (use a simpler workflow instead):**
- Small one-time fixes
- Single-file changes
- Tasks without follow-up sprints

## Examples

See the [`examples/`](examples/) folder for:
- A complete Master Brief example
- A Sprint Plan example
- A completed sprint with handoff

## How It Compares

| Approach | Context across sessions | Quality tracking | Disconnect recovery | Scope control |
|----------|------------------------|------------------|--------------------|----|
| No system (most users) | ❌ Lost | ❌ None | ❌ Start over | ❌ None |
| Copy-paste chat history | ⚠️ Partial | ❌ None | ⚠️ Manual | ❌ None |
| CLAUDE.md notes | ⚠️ Basic | ❌ None | ⚠️ Manual | ❌ None |
| **sprint-session** | ✅ Full | ✅ Quality Baseline + Decision Log | ✅ Auto-commit + recovery protocol | ✅ Scope creep detection |

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI, desktop app, or IDE extension)
- Git (for auto-commit and recovery features)
- A remote git repository (for push-based resilience)

## License

MIT — use it, modify it, share it.

## Credits

Created by **Marco C. Lorenz** — former IT forensics court expert and founder of an IT data forensics enterprise.

This skill was not built from a software developer's perspective. It was built from real-world practice — managing complex systems, ensuring traceability, and maintaining quality across large-scale operations. The same principles that govern forensic evidence chains (documentation, verification, audit trails) turned out to be exactly what's missing when AI coding assistants work on multi-session projects.

**sprint-session** bridges the gap between structured systems work and software development. It brings the rigor of systematic process management into the world of AI-assisted coding — without the overhead of enterprise tooling.

Built and maintained by [Luneo AI](https://github.com/LuneoAI).
