# Example: What a Sprint Handoff Looks Like

This is what Claude Code outputs at the end of a sprint. You copy the two links into your next terminal.

---

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SPRINT 1 COMPLETED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## What I completed

| # | Task | Status |
|---|------|--------|
| 1 | Project setup + folder structure | ✅ done |
| 2 | Database schema + migrations | ✅ done |
| 3 | Auth endpoints (register, login, me) | ✅ done |
| 4 | Tests (8 tests, all green) | ✅ done |

## What works now
- POST /api/auth/register creates users with hashed passwords
- POST /api/auth/login returns JWT for valid credentials
- GET /api/auth/me returns user data (protected by auth middleware)
- 8 tests passing: 4 happy-path, 4 error cases
- Migrations run cleanly from scratch

## What the next sprint does
- Sprint 2: Full CRUD for projects + tasks
- Then Sprint 3: React frontend skeleton
- Overall: 1/8 sprints done (12%)

## Your two links

Terminal done. Open a new terminal and enter:

> Here is the Master Brief: `docs/sprints/taskflow/master-brief.md`
> And here the Sprint Plan: `docs/sprints/taskflow/sprint-002.md`
> Read both, then execute Sprint 2.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## What a partial completion looks like (context window limit)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SPRINT 3 PARTIALLY COMPLETED
 (Context window limit reached)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## What I completed

| # | Task | Status |
|---|------|--------|
| 1 | React project setup + routing | ✅ done |
| 2 | Login page + auth flow | ✅ done |
| 3 | Dashboard layout | ⚠️ partial (sidebar done, main area pending) |
| 4 | Project list component | ⬜ not started |

## What works now
- React app loads, routing works
- Login page authenticates against API and stores JWT
- Sidebar navigation renders project list

## What the next sprint does
- Sprint 3b: Finish dashboard layout + project list component
- I cut off cleanly rather than risk errors

## Your two links

Terminal done. Open a new terminal and enter:

> Here is the Master Brief: `docs/sprints/taskflow/master-brief.md`
> And here the Sprint Plan: `docs/sprints/taskflow/sprint-003b.md`
> Read both, then execute Sprint 3b.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
