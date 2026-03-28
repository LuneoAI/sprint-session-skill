---
name: sprint-session
description: "Sprint-Lifecycle-Management for multi-terminal projects. 3 modes: :init (project kickoff with master brief + sprint plan), :work (execute sprint with context window protection + clean handoff), :review (E2E completion review). Trigger: /sprint-session, 'start new project', 'start sprint', projects > 1 sprint."
---

# Sprint-Session — Sprint Lifecycle for Multi-Terminal Projects

**Purpose:** Automatic management of Master Brief + Sprint Files for larger projects. Prevents context loss between terminals, ensures clean handoffs, protects against context window overflow.

**Core principles:**
- Master Brief = Direction (strategically stable)
- Sprint File = Progress (operationally alive)
- No sprint without a write-back entry
- No new terminal without reading both documents first
- Clean handoff > completed sprint
- After every task: commit + push = insurance

## When to activate

- New project > 1 sprint / > 1 terminal
- User provides Master Brief + Sprint Plan paths (→ :work mode)
- User says "final review" or all sprints are done (→ :review mode)
- Project involves architecture decisions, multiple systems, follow-up sprints

## When NOT to activate (use quick-fix workflow instead)

- Small one-time fixes
- Single-file changes
- Tasks without follow-up sprints

## Path Convention

```
docs/sprints/{project-name}/
├── master-brief.md           ← strategically stable
├── sprint-001.md             ← first sprint
├── sprint-002.md
├── sprint-003.md             ← current sprint
├── sprint-003b.md            ← continuation (after context window cutoff)
└── ...
```

---

## Sprint Size (Rule of Thumb)

| Tasks per Sprint | Assessment |
|------------------|-----------|
| 1-2 Tasks | Too small — handoff overhead not worth it |
| 3-6 Tasks | Sweet spot — enough substance, context window stays safe |
| 7-10 Tasks | Borderline — only if tasks are small and clear |
| 10+ Tasks | Too large — split into two sprints, context window risk too high |

If a sprint has more than 6 substantial tasks during planning → split into two sprints. Two clean sprints are better than one overstuffed sprint that hits the context window limit.

---

## Resilience — Protection Against Disconnects + Power Outages

### Auto-Commit + Push After Every Task (MANDATORY)

After every completed task (not just at sprint end):

```bash
git add -A && git commit -m "Sprint {N} Task {X}: {short description}" && git push
```

**Why:** Session can break at any time — mobile internet, power outage, tunnel disconnect. What's pushed is safe. What's only local is at risk.

**Rules:**
- Commit message always starts with Sprint number + Task number
- Push after EVERY commit, not just at the end
- Also commit + push sprint documents (master-brief.md, sprint-NNN.md)
- On disconnect, the last push is the recovery point

### Disconnect Recovery Protocol

When the user opens a new terminal after a disconnect:

**User says:** "Session broke off, where are we?" or pastes the two links.

**Claude does:**
1. `git log --oneline -20` → check recent commits
2. `git status` → find uncommitted changes
3. Read sprint file → what was planned vs. what is committed
4. Report to user: "Sprint N was at Task X. Tasks 1-3 are committed + pushed. Task 4 was half done — I see uncommitted changes in [files]. Should I finish Task 4 or reset?"
5. If uncommitted changes look clean → commit + push
6. If uncommitted changes are inconsistent → `git stash` and start fresh

**Important:** No chat history needed. Git history + sprint documents are the source of truth.

### When User is on Mobile / Unstable Connection

When the user says "I'm mobile" or "on the road":
- **Commit more frequently** — after every substantial file change, not just after tasks
- **Plan shorter sprints** — 3-4 tasks instead of 5-6
- **Write handoff documents earlier** — start preparing at 50% of the sprint
- **Don't start long build processes** that leave inconsistencies on abort

---

## Mode 1: :init — Project Kickoff

**Trigger:** Starting a new larger project.

### Flow

1. **Start brainstorming** → clarify vision, goals, architecture
2. **Break project into** Waves → Stages → Sprints
   - Small projects (1-3 waves): plan EVERYTHING in detail
   - Complex projects (4+ waves): Waves 1-2 in detail, rest as rough goals only
3. **Generate Master Brief** (`docs/sprints/{name}/master-brief.md`)
4. **Generate first Sprint Plan** (`docs/sprints/{name}/sprint-001.md`)
5. **Output handoff message**

### Master Brief Template

```markdown
# Master Brief: {Project Name}

> Created: {Date} | Last Update: {Date}

## Vision / North Star
{What do we want to achieve and why}

## Target State
{What does the end result look like}

## Architecture Principles
{Technical guardrails}

## Priorities
1. {Highest priority}
2. ...

## Not Priority (consciously excluded)
- {What we deliberately do NOT do}

## Rules for Work
- No sprint without a write-back entry
- No new terminal without reading Master Brief + Sprint File first
- On context window limit: clean abort, don't push through
- On architecture/design ambiguity: STOP and ask

## Quality Baseline
{3-5 lines defining what "clean code" means in this project. Every sprint retro checks against this.}
- Style: {e.g. camelCase for JS, snake_case for Python}
- Architecture: {e.g. "Controller → Service → Repository, no shortcuts"}
- Tests: {e.g. "Every endpoint has at least one happy-path test"}
- UI: {e.g. "No inline styles, responsive from 768px"}

## Decisions
| # | Decision | Why | Sprint |
|---|----------|-----|--------|
| — | Filled during project lifecycle | — | — |

## Project Breakdown

### Wave 1: {Name}
| Sprint | Goal | Status | Date |
|--------|------|--------|------|
| Sprint 1 | {Goal} | ⬜ open | — |
| Sprint 2 | {Goal} | ⬜ open | — |

### Wave 2: {Name}
| Sprint | Goal | Status | Date |
|--------|------|--------|------|
| Sprint 3 | {Goal} | ⬜ open | — |

**Status Legend:** ⬜ open | 🔄 in progress | ✅ done | ⏭️ skipped

## Overall Progress
- **Total sprints:** N
- **Completed:** 0/N (0%)
- **Current wave:** 1
- **Next sprint:** Sprint 1
```

### Sprint Plan Template

```markdown
# Sprint {NNN}: {Title}

> Project: {Project Name} | Date: {Date}
> Master Brief: docs/sprints/{name}/master-brief.md

## Goal of This Sprint
{What gap is being closed}

## Context (from Master Brief)
{Relevant excerpt — what does this terminal need to know}

## Tasks
{Detailed task list}

## Acceptance Criteria
- [ ] {What must be green at the end}

## After This Sprint
- Update sprint file
- Update Master Brief status table
- Prepare next sprint plan
```

---

## Mode 2: :work — Sprint Execution

**Trigger:** User provides Master Brief + Sprint Plan paths. Or this terminal should execute the next sprint from the previous terminal's handoff.

### Phase A — Read-in (MANDATORY)

1. **Read Master Brief** → understand the big picture (vision, architecture, current state)
2. **Read Sprint Plan** → understand the concrete assignment
3. **Confirm to user:** "Project understood, starting Sprint {N} — Goal: {Goal}"

### Phase B — Clarify Questions (BEFORE coding starts)

4. Review sprint plan: Is everything clear enough to start?
5. If unclear on **architecture, design, or direction**: **STOP and ask**
   - Example: "Before I start Sprint 3 — I have 2 questions:"
   - "1. Should the new endpoint go under /api/v2 or /api/v1?"
   - "2. The database migration — extend existing or create new?"
6. **Purely technical decisions** (which library, which loop type) → decide yourself
7. **Architecture + Design** (where does what live, how does data flow, what does the user see) → **always ask**

### Phase C — Execute (with Sub-agents if available)

8. Work through tasks from sprint plan
9. After every task: verify the task works as intended
10. **After every verified task: commit + push** (Sprint-N Task-X: description)
11. You may STOP and ask questions during work too
12. **Context window awareness:** Continuously estimate your own context consumption

### Phase C.1 — Multi-Terminal Awareness

When multiple terminals are active simultaneously:

13. **Check at start:** `git log --oneline -5` — is another terminal working on the same project?
14. **Check for conflicts:** Are there active changes to the same files/directories?
15. **Clarify scope:** If another terminal is active:
    - What system/directory is it editing?
    - Are there overlaps with my sprint?
    - If yes: inform user and clarify order
    - If no: continue in parallel, but clearly limit own scope
16. **Before every push:** `git pull --rebase` to avoid conflicts with other terminals
17. **On merge conflicts:** STOP, inform user, do not blindly resolve

### Phase D — Context Window Protection (CRITICAL)

```
WHEN context window approaches the limit:
  → DO NOT keep going and hope for the best
  → DO NOT "quickly squeeze in the last feature"
  → IMMEDIATELY abort cleanly:
    1. Complete current task or mark where you stopped
    2. Update sprint file (what's done, what's open)
    3. Update Master Brief status
    4. Write next sprint plan (sprint-NNNb for continuation)
    5. Output handoff message
```

**Rules:**
- Better to abort a sprint early than drift into chaos
- Never "quickly" do something when the window is tight
- Always reserve 20% context for handoff documents
- Rule of thumb: After 3-4 complex tasks, actively check if handoff makes sense
- On signs of stress (repetitions, forgetting, inconsistencies): STOP immediately
- Clean handoff > completed sprint

### Phase E — Close Sprint

13. Run code review + security check + gather metrics
    - **Quality Baseline check:** Verify code against the Quality Baseline in Master Brief
    - Detect drift: Did this sprint degrade style, architecture, or test coverage?
    - If yes: document as finding and correct in next sprint
14. Update sprint file
15. **Maintain Decision Log:** Were architecture or design decisions made in this sprint?
    - If yes: Add one line per decision to the `## Decisions` table in Master Brief
    - Format: What was decided | Why | In which sprint
    - Only non-trivial decisions (architecture, technology choices, conscious trade-offs)
    - Pure implementation details do NOT belong here
16. **Slim down + update Master Brief:**
    - Update status table (Sprint → ✅, update overall progress)
    - Remove obsolete information (completed detail notes, outdated assumptions)
    - Vision, goal, architecture **NEVER remove** — that stays forever
    - Decision Log and Quality Baseline **NEVER remove** — these grow with the project
    - Keep only what matters: what was defined, what needs to be done, roughly how
    - Goal: Next terminal gets a lean, precise document — not a bloated logbook
17. Generate next sprint plan
18. **Output handoff message** (see format below)

### Handoff Format (MANDATORY at the end of every session)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SPRINT {N} COMPLETED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## What I completed

| # | Task | Status |
|---|------|--------|
| 1 | {Task Name} | ✅ done |
| 2 | {Task Name} | ✅ done |
| 3 | {Task Name} | ⚠️ partial (reason) |

## What works now
- {Feature/endpoint/UI element that is now live}
- {What didn't work before and works now}

## What the next sprint does
- {Sprint N+1 goal}
- {Concrete tasks roughly}
- {What comes after that}

## Your two links

Terminal done. Open a new terminal and enter:

> Here is the Master Brief: `docs/sprints/{name}/master-brief.md`
> And here the Sprint Plan: `docs/sprints/{name}/sprint-{N+1}.md`
> Read both, then execute Sprint {N+1}.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Mode 3: :review — Review (Wave Review + Final Review)

**Trigger:** End of a wave OR completion of the entire project. Own terminal with fresh context window.

### Two Review Levels

| Level | When | Scope | Duration |
|-------|------|-------|----------|
| **Wave Review** (lightweight) | After each completed wave | Consistency + Quality Baseline | 1 terminal, fast |
| **Final Review** (comprehensive) | After the last sprint | E2E over everything | 1 terminal, thorough |

### Wave Review (after each wave)

1. **Read Master Brief** → which sprints belong to this wave
2. **Read sprint files for this wave** → what was done
3. **Consistency check:**
   - Do the sprints in this wave fit together?
   - Quality Baseline maintained? (style, architecture, tests)
   - Decisions from different sprints contradictory?
   - Any half-finished transitions between sprints?
4. **Fix found problems immediately** — small corrections directly, larger ones as tasks in next wave
5. **Update Master Brief:** Wave → ✅, document findings
6. **Plan next wave in detail** if only rough goals exist

### Final Review (after the last sprint)

1. **Read Master Brief** → all waves/sprints and their status
2. **Read all sprint files** → what was done in each sprint
3. **E2E Review** (parallel sub-agents if available):
   - Code review on ALL changes (one sub-agent per system)
   - Security audit on ALL changes
   - Quality Baseline drift across the whole project (Sprint 1 vs. last sprint)
   - Inconsistencies between sprints
   - Dead spots, gaps, half-finished transitions
   - Forgotten features (sprint plan vs. actually implemented)
   - Decision Log check: Were all decisions upheld or silently undermined?
4. **Fix found errors directly**
5. **E2E tests** where possible
6. **Generate review report**
7. **Finalize Master Brief** (Project status → ✅ if everything is clean)

---

## Planning Intelligence

**Core principle:** Plan extensively at the start — then execute fast.

**No replanning when:**
- Sprint plan is clear and detailed → start immediately
- Just because a new terminal was started → reading Master Brief + Sprint Plan is enough
- Small deviations → document in sprint plan, don't replan

**Replanning needed when (skill detects this automatically):**
- Next wave has only rough goals, no concrete tasks
  → "Wave 3 is not yet detailed — before I start Sprint 5, let me plan it through"
- Architecture decision from previous sprint changes the plan
- Sprint plan references tasks that aren't clear enough
- User explicitly says: "Adjust the plan"

### Scope Creep Detection (automatic)

**Trigger:** The skill checks overall progress in the Master Brief at every sprint close.

```
WHEN actual sprint count > 150% of originally planned count:
  → AUTOMATICALLY trigger scope check
```

**Example:** Originally 8 sprints planned, we're now at sprint 13 with no end in sight.

**Claude says:**

> ⚠️ **Scope Check:** The project has grown significantly beyond the original plan
> (originally 8 sprints, currently 13, estimated 5 more remaining).
>
> Three options:
> **A) Reduce scope** — What can we drop? What's nice-to-have?
> **B) Consciously continue** — The additional scope is justified, continue as planned.
> **C) Split the project** — Close Phase 1 here, start the rest as a separate follow-up project.
>
> Which option?

**Rules:**
- Scope check is a question, not a blocker — the user decides
- After decision: update Master Brief (new sprint count or reduced scope)
- For option C: close current project cleanly with :review, new :init for Phase 2
- Scope check at most once per wave, don't repeat at every sprint

---

## Rollback Strategy — When a Sprint Breaks Code

### Detection

After verification or code review it turns out: the sprint damaged something.

### Immediate Actions

1. **Damage assessment:** `git diff HEAD~{N}` — what was changed in this sprint?
2. **Localize:** Which file(s) are the problem? Everything or just a part?
3. **Decision:**

| Situation | Action |
|-----------|--------|
| One task introduced a bug | Fix the bug, don't roll back the entire sprint |
| Multiple tasks are broken and intertwined | `git stash` uncommitted changes, then check task-by-task |
| Sprint went in a fundamentally wrong direction | `git revert` the sprint commits (creates counter-commits, history preserved) |
| Everything is broken, nothing salvageable | Restore from last known good state (backup/snapshot if available) |

### Rules

- **Never `git reset --hard` without explicit user confirmation** — that destroys history
- **Always `git revert` instead of `git reset`** — history stays intact
- After rollback: update sprint file with "Sprint N rolled back, reason: ..."
- Write new sprint plan that accounts for the problem

---

## Parallel Sprints — Rules for Simultaneous Terminals

### When allowed

Parallel sprints are only allowed when:
- The sprints affect **different systems/directories** (e.g. backend + frontend)
- The sprints **don't modify shared files**
- Both sprints are clearly scoped to avoid conflicts

### When forbidden

- Sprints that touch the same files or same system → sequential
- Sprints that depend on each other (Sprint 3 needs result of Sprint 2) → sequential
- When in doubt → sequential. Parallelism is an optimization, not the default.

### Flow for parallel sprints

1. **Plan both sprints** before either starts
2. **Separate sprint files** (sprint-003-backend.md, sprint-003-frontend.md)
3. **Define merge point:** When do the results come together?
4. **After both complete:** Check integration (own mini-sprint or :review)
