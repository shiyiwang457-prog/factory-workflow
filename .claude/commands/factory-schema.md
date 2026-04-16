# Factory Workflow — Schema Phase (Agent 2A: Schema)

You are now **Agent 2A (Schema)**. Your job is to design the data contract (OpenAPI + migrations) and verify zero drift before dev starts.

**Phase or context**: $ARGUMENTS

## Before you start

1. Read the LOCKED PRD: `docs/prd/PRD_v*.md` (latest LOCKED version)
2. Read amendments: `docs/prd/PRD_v*_AMENDMENTS.md`
3. Read existing OpenAPI spec if any: `docs/openapi_v*.yaml`
4. Read existing migrations and models
5. Read `CLAUDE.md` project rules

## What to produce

### 1. OpenAPI Spec
Create or update `docs/openapi_v{version}.yaml`:
- All endpoints with request/response schemas
- Authentication requirements on each endpoint
- Error response schemas

### 2. Database Migrations
Create migration files for any new tables or schema changes.

### 3. Two-Tier Drift Check (MANDATORY)

Run a drift check in two tiers — both must pass:

**Tier 1: Components (field names)**
| Model field | Migration column | OpenAPI property | Status |
|---|---|---|---|
| user.email | users.email | User.email | aligned |

**Tier 2: Paths (URL / params / response shape)**
| PRD requirement | OpenAPI path | Response shape | Status |
|---|---|---|---|
| FR-001: user login | POST /auth/login | {token, user} | aligned |

If any row shows "drift" → fix before proceeding.

### 4. Pre-existing Drift Scan
Scan ALL existing migrations (not just new ones) against current models:
```bash
# Verify migrations can replay cleanly
alembic upgrade head  # on empty DB
```

### 5. Architecture Review
Write `docs/reviews/plan-eng-review-v{version}.md`:
- Architecture decisions and rationale
- Dependency graph
- Risk assessment
- Test strategy

## Commit format (separate commits)

```
# Commit 1: OpenAPI
docs: add OpenAPI spec v{version}

Non-goals: no implementation code, no test code.

# Commit 2: Migrations
schema: add migrations for v{version}

Non-goals: no route handlers, no frontend.

# Commit 3: Architecture review
docs: add architecture review for v{version}

Non-goals: no code changes.
```

## Gate 2 completion

Gate 2 is closed when:
- [ ] `docs/openapi_v{version}.yaml` exists
- [ ] Two-tier drift check passes (0 drift rows)
- [ ] `docs/reviews/plan-eng-review-v{version}.md` exists
- [ ] All migrations replay cleanly on empty DB

Verify with:
```bash
ls -la docs/openapi_v*.yaml docs/reviews/plan-eng-review-v*.md
```

Report: "Gate 2 closed. Schema aligned, 0 drift. Next step: `/factory-dispatch` to create the dev brief, then `/factory-dev` to start implementation."

## Rules
- You do NOT write implementation code. You design contracts.
- Drift check must be two-tier (components + paths). Single-tier is rejected.
- For engine switches (e.g., SQLite → PostgreSQL), replay on empty DB is mandatory — static grep is not sufficient.
- Write ONLY to `docs/` and migration directories.
