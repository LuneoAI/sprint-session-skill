# Sprint 001: DB Schema + API Skeleton + Auth

> Project: TaskFlow API | Date: 2026-03-16
> Master Brief: docs/sprints/taskflow/master-brief.md

## Goal of This Sprint
Build the foundation: database schema, Express API with basic routes, and JWT authentication. After this sprint, we can create users and authenticate — nothing else yet.

## Context (from Master Brief)
- SQLite database (Decision #1)
- JWT authentication (Decision #2)
- Architecture: Route → Controller → Service → Repository
- Every endpoint needs at least one happy-path test + one error test

## Tasks

### Task 1: Project Setup
- Initialize Node.js project with Express
- Set up folder structure: `src/routes/`, `src/controllers/`, `src/services/`, `src/repositories/`
- Configure ESLint + Prettier
- Set up SQLite with better-sqlite3

### Task 2: Database Schema
- Users table: id, email, password_hash, name, created_at
- Projects table: id, name, owner_id, created_at
- Tasks table: id, project_id, title, description, status, assignee_id, created_at, updated_at
- Migration system: numbered SQL files in `migrations/`

### Task 3: Auth Endpoints
- POST /api/auth/register — create user, hash password with bcrypt
- POST /api/auth/login — verify password, return JWT
- GET /api/auth/me — return current user from JWT
- Auth middleware that extracts and verifies JWT on protected routes

### Task 4: Basic Tests
- Test auth flow: register → login → access protected route
- Test error cases: duplicate email, wrong password, expired token
- Set up test runner (vitest) with test database

## Acceptance Criteria
- [ ] `POST /api/auth/register` creates a user and returns JWT
- [ ] `POST /api/auth/login` returns JWT for valid credentials
- [ ] `GET /api/auth/me` returns user data with valid token
- [ ] `GET /api/auth/me` returns 401 without token
- [ ] All 6+ tests pass
- [ ] Database migrations run cleanly from scratch

## After This Sprint
- Update sprint file with results
- Update Master Brief status table
- Prepare sprint-002 plan (Full CRUD for projects + tasks)
