# Master Brief: TaskFlow API

> Created: 2026-03-15 | Last Update: 2026-03-22

## Vision / North Star
Build a task management system that teams actually want to use. Simple, fast, no feature bloat. Think "Todoist for small teams" — not "Jira lite".

## Target State
- REST API with full CRUD for projects, tasks, and team members
- React frontend with real-time updates
- Authentication via JWT
- Deploy on a single VPS with SQLite (scale later if needed)

## Architecture Principles
- API-first: Frontend consumes the same API that external integrations would use
- No ORM magic: Raw SQL with a thin query builder, migrations tracked in git
- Components over pages: Every UI element is a reusable component
- Mobile-first: Design for phones, scale up to desktop

## Priorities
1. Core task CRUD (create, read, update, delete, assign)
2. Project organization (folders, labels)
3. Real-time sync (WebSocket for live updates)
4. Team features (invite, roles, permissions)

## Not Priority (consciously excluded)
- Gantt charts or timeline views (too complex for v1)
- Email notifications (push notifications only)
- File attachments (link to external storage instead)
- SSO/SAML (JWT is enough for v1)

## Rules for Work
- No sprint without a write-back entry
- No new terminal without reading Master Brief + Sprint File first
- On context window limit: clean abort, don't push through
- On architecture/design ambiguity: STOP and ask

## Quality Baseline
- Style: camelCase for JS, 2-space indent, no semicolons (Prettier handles it)
- Architecture: Route → Controller → Service → Repository, no shortcuts
- Tests: Every endpoint has at least one happy-path test + one error test
- UI: No inline styles, Tailwind utility classes, responsive from 640px

## Decisions
| # | Decision | Why | Sprint |
|---|----------|-----|--------|
| 1 | SQLite instead of PostgreSQL | Single VPS, no external DB needed, simpler ops | Sprint 1 |
| 2 | JWT instead of sessions | Stateless API, easier for mobile clients later | Sprint 1 |
| 3 | Tailwind instead of CSS modules | Team knows it, faster to build, consistent design | Sprint 3 |

## Project Breakdown

### Wave 1: Foundation
| Sprint | Goal | Status | Date |
|--------|------|--------|------|
| Sprint 1 | DB schema + API skeleton + auth | ✅ done | 2026-03-16 |
| Sprint 2 | Full CRUD for projects + tasks | ✅ done | 2026-03-18 |
| Sprint 3 | React frontend skeleton + first pages | ✅ done | 2026-03-20 |

### Wave 2: Core Features
| Sprint | Goal | Status | Date |
|--------|------|--------|------|
| Sprint 4 | API ↔ Frontend wiring + real-time | 🔄 in progress | 2026-03-22 |
| Sprint 5 | Labels, filters, search | ⬜ open | — |
| Sprint 6 | Team invite + roles | ⬜ open | — |

### Wave 3: Polish
| Sprint | Goal | Status | Date |
|--------|------|--------|------|
| Sprint 7 | Mobile optimization + PWA | ⬜ open | — |
| Sprint 8 | Performance + deploy pipeline | ⬜ open | — |

**Status Legend:** ⬜ open | 🔄 in progress | ✅ done | ⏭️ skipped

## Overall Progress
- **Total sprints:** 8
- **Completed:** 3/8 (37%)
- **Current wave:** 2
- **Next sprint:** Sprint 4
