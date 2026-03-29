# sprint-session

A Claude Code skill for managing multi-sprint projects across multiple terminal sessions — from sequential handoffs to fully coordinated parallel clusters.

## The Problem

When a project spans many sprints and terminal sessions, context is lost:

- A later sprint only sees the last small task
- The actual goal fades
- Architecture decisions are forgotten
- The next terminal doesn't know where to pick up
- The context window fills up and output quality degrades silently

And when projects get big enough, **the bottleneck isn't code — it's coordination.**

## The Solution

Two documents, three modes, and two execution strategies.

**Two documents:**
- **Master Brief** — the strategic north star (vision, architecture, priorities, decisions). Updated rarely, stays lean.
- **Sprint File** — the operational record per sprint (tasks, results, what's next). Updated after every sprint.

**Three modes:**

| Mode | When | What it does |
|------|------|-------------|
| `:init` | New project | Brainstorming → Master Brief + Sprint Plans + execution mode decision |
| `:work` | Each sprint | Read both docs → execute → handoff to next terminal |
| `:review` | End of wave/project | E2E review across all sprints |

**Two execution strategies:**

| Strategy | When | How |
|----------|------|-----|
| **Sequential** | Sprints depend on each other, same system, < 3 sprints | One terminal after another, copy-paste two links |
| **Cluster** | Independent sprints across different systems, 3+ sprints | Multiple terminals work in parallel, coordinated via [claude-peers](https://github.com/louislva/claude-peers-mcp) |

## How It Works

### Sequential Mode (default)

```
Terminal 1:  /sprint-session:init
             Brainstorming → Master Brief + Sprint-001
                  ↓ copy-paste the two links

Terminal 2:  Sprint 1 → Handoff + Sprint-002
                  ↓ copy-paste

Terminal 3:  Sprint 2 → Handoff + Sprint-003
                  ↓ copy-paste

Terminal N:  /sprint-session:review → E2E check → Project ✅
```

### Cluster Mode (parallel sprints)

```
Terminal 1 (Orchestrator):
    /sprint-session:init → plans all sprints + dependency graph
    Monitors workers, sends DEPENDENCY_MET signals

Terminal 2 (Worker A):  Sprint 1 (Backend)  ──→ SPRINT_DONE:1
Terminal 3 (Worker B):  Sprint 2 (Frontend) ──→ SPRINT_DONE:2
                                                      ↓
Terminal 4 (Worker C):  Sprint 3 (Integration) ← DEPENDENCY_MET:3
                                                      ↓
Terminal 1 (Orchestrator):  /sprint-session:review → E2E check → Project ✅
```

Workers discover each other automatically via the peers network. The orchestrator coordinates dependencies without you having to manually sequence anything.

**For you this means:** In sequential mode, you copy-paste two file paths. In cluster mode, you open N terminals with their sprint plans — the sessions coordinate themselves.

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
- **Cluster Coordination** — parallel sprint execution with dependency management via claude-peers

## Cluster Mode Details

### Prerequisites

- [claude-peers-mcp](https://github.com/louislva/claude-peers-mcp) installed and configured in `.mcp.json`
- All sessions running on the same machine

### Roles

| Role | Responsibility |
|------|----------------|
| **Orchestrator** | Plans sprints, creates dependency graph, monitors workers, releases blocked sprints |
| **Worker** | Executes assigned sprint, reports status, waits for dependency signals |

### Signals

| Signal | From → To | Meaning |
|--------|-----------|---------|
| `SPRINT_STARTED:{N}` | Worker → Orchestrator | Sprint begun |
| `SPRINT_DONE:{N}` | Worker → Orchestrator | Sprint complete, all tasks done |
| `SPRINT_BLOCKED:{N}:{reason}` | Worker → Orchestrator | Sprint stuck, needs help |
| `DEPENDENCY_MET:{N}` | Orchestrator → Worker | Precondition fulfilled, sprint may start |
| `SYNC_REQUEST:{details}` | Worker → Worker | Direct coordination between peers |

### Dependency Graph (in Master Brief)

```markdown
## Cluster Plan

Sprint 1 (API-Backend)    ──→ Sprint 3 (Integration-Layer)
Sprint 2 (React-Frontend) ──→ Sprint 3 (Integration-Layer)
Sprint 4 (Data-Sync)      ──→ (independent)
```

### When to Use Cluster vs. Sequential

| Criterion | → Sequential | → Cluster |
|-----------|-------------|-----------|
| Sprints depend on each other | ✅ | ❌ |
| Same system/files | ✅ | ❌ |
| Different systems | possible | ✅ better |
| Clear wave separation | possible | ✅ better |
| Maximum control | ✅ | ❌ |
| Maximum speed | ❌ | ✅ |
| Fewer than 3 sprints | ✅ | overhead not worth it |

## Installation

Copy the skill folder into your Claude Code skills directory:

```bash
# Clone the repo
git clone https://github.com/LuneoAI/sprint-session-skill.git

# Copy the skill into your Claude Code setup
cp -r sprint-session-skill/sprint-session ~/.claude/skills/
```

For cluster mode, also install claude-peers:

```bash
git clone https://github.com/louislva/claude-peers-mcp.git
bun install --cwd claude-peers-mcp
```

Add to `.mcp.json`:
```json
{
  "mcpServers": {
    "claude-peers": {
      "command": "bun",
      "args": ["./claude-peers-mcp/server.ts"]
    }
  }
}
```

That's it. The skill is now available as `/sprint-session` in Claude Code. Cluster mode activates automatically when claude-peers is available and the project has parallelizable sprints.

## Quick Start

### Starting a new project
```
You: /sprint-session:init
You: "I want to build a task management API with React frontend"
```

Claude Code will brainstorm with you, then generate:
- `docs/sprints/task-manager/master-brief.md`
- `docs/sprints/task-manager/sprint-001.md`

And ask: *"This project has 4 independent sprints across 2 systems — cluster mode or sequential?"*

### Running a sprint (sequential)
Open a new terminal and paste the two links from the handoff:

```
You: Here is the Master Brief: docs/sprints/task-manager/master-brief.md
     And here the Sprint Plan: docs/sprints/task-manager/sprint-001.md
     Read both, then execute Sprint 1.
```

### Running sprints (cluster)
The orchestrator terminal outputs which terminals to open:

```
Open Terminal A:
> Master Brief: docs/sprints/task-manager/master-brief.md
> Sprint Plan: docs/sprints/task-manager/sprint-001.md
> Mode: Cluster-Worker

Open Terminal B:
> Master Brief: docs/sprints/task-manager/master-brief.md
> Sprint Plan: docs/sprints/task-manager/sprint-002.md
> Mode: Cluster-Worker

This terminal stays Orchestrator.
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
- Multiple independent systems that could be worked on in parallel

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

| Approach | Context across sessions | Quality tracking | Disconnect recovery | Scope control | Parallel coordination |
|----------|------------------------|------------------|--------------------|----|-----|
| No system (most users) | ❌ Lost | ❌ None | ❌ Start over | ❌ None | ❌ None |
| Copy-paste chat history | ⚠️ Partial | ❌ None | ⚠️ Manual | ❌ None | ❌ None |
| CLAUDE.md notes | ⚠️ Basic | ❌ None | ⚠️ Manual | ❌ None | ❌ None |
| **sprint-session (sequential)** | ✅ Full | ✅ Quality Baseline + Decision Log | ✅ Auto-commit + recovery protocol | ✅ Scope creep detection | ❌ N/A |
| **sprint-session (cluster)** | ✅ Full | ✅ Quality Baseline + Decision Log | ✅ Auto-commit + recovery protocol | ✅ Scope creep detection | ✅ Peers + dependency graph |

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI, desktop app, or IDE extension)
- Git (for auto-commit and recovery features)
- A remote git repository (for push-based resilience)
- [Bun](https://bun.sh) + [claude-peers-mcp](https://github.com/louislva/claude-peers-mcp) (optional, for cluster mode)

## License

MIT — use it, modify it, share it.

## Background

This skill wasn't born in a software engineering lab. It grew out of practical frustration.

**Marco C. Lorenz**, the creator, comes from IT forensics — years of court expertise and building a data forensics company from the ground up. In forensics, every step must be documented, every decision traceable, every handoff clean. Evidence chains don't survive sloppy handovers.

When working with Claude Code on larger projects, the same problems appeared: context lost between sessions, decisions forgotten after a few sprints, quality drifting silently. The tools from software engineering (Jira, Confluence, CI/CD) were too heavy. The tools from AI coding (just start a new chat) were too light.

**sprint-session** is the bridge — it brings the discipline of systematic process work into AI-assisted development, using nothing but two markdown files and a clear protocol.

The cluster mode came from a simple observation: at a certain project size, the bottleneck is no longer writing code — it's coordinating who does what, when, and in which order. With claude-peers providing real-time inter-session communication, sprints that used to run sequentially can now run as a self-coordinating cluster.

The `spawn-cluster.sh` script takes it one step further: the orchestrator session spawns worker sessions automatically via tmux — no manual terminal opening required.

## Credits

Created by Marco C. Lorenz | Built and maintained by [Luneo AI](https://github.com/LuneoAI)
