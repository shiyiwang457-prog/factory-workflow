# Factory Workflow — Project CLAUDE.md

> This file is auto-loaded into every Claude conversation for this project.
> It enforces the Factory Workflow methodology. DO NOT delete or weaken any rule.
> Version: 1.0.0 | Source: https://github.com/anthropics/factory-workflow

---

## What is Factory Workflow

A **4-agent pipeline with 3 gates** for building commercial-grade software.
Chat is ephemeral, files are authoritative. All state persists via git + docs/.
Any new window / any developer / any new Claude session can resume from files alone.

```
Agent 1 PM        → Write PRD (requirements, non-goals, success metrics)
     ↓
  [Gate 1]        → PRD approved + LOCKED
     ↓
Agent 2A Schema   → OpenAPI contract + DB migrations + drift check
     ↓
  [Gate 2]        → Architecture review pass
     ↓
Agent 2B Dev      → Implement code (per dispatch brief, one phase at a time)
     ↓
  [Gate 3]        → QA (contract tests + e2e + visual smoke test)
     ↓
  Ship            → Tag + release + deploy
```

---

## 5 Invariants (hard constraints — violating any one = STOP and ask)

### 1. LOCKED documents are immutable
Once a document is marked LOCKED (PRD / BRAND_GUIDELINE / ARCHITECTURE):
- **Never** edit the original file
- Write a versioned copy (`BRAND_GUIDELINE_v1.1.md`) or append-only log (`PRD_v1.0_AMENDMENTS.md`)
- Add `> SUPERSEDED BY <new_path>` pointer to the original

### 2. Dispatch brief is a file, not a chat message
Every dev phase **must** have `docs/dispatch/agent2b-v{version}.{phase}.md` committed before work starts.
Contains 8 mandatory sections (see §Dispatch Brief below). Chat instructions are forbidden — files are authoritative.

### 3. Schema-First
Migrations + OpenAPI are written **before** implementation code.
- Drift check is TWO-TIER: components (field names) + paths (URL / params / response shape)
- Engine switches require empty-DB `alembic upgrade head` replay, not just static grep
- Scan existing migrations too, not only new ones

### 4. One commit = one concern
- Feature / doc / migration / refactor — each gets its own commit
- Every commit is independently revertable and independently shippable
- Commit message body **must** include non-goals (what this commit deliberately does NOT do)

### 5. Amendment numbering: grep before writing
Before writing a new Amendment, run:
```bash
grep "Amendment #" docs/prd/PRD_v*_AMENDMENTS.md
```
Use the latest number found. Never rely on memory or stale references.

---

## Gate Evidence (file-authoritative)

Every gate transition requires a **file artifact** to exist. No artifact = gate is BLOCKED.

| Gate | Required Artifact | Who produces it |
|---|---|---|
| Gate 1 (PRD lock) | `docs/prd/PRD_v{ver}.md` LOCKED | PM (Agent 1) |
| Gate 2 (Schema pass) | `docs/reviews/plan-eng-review-v{ver}.md` + clean drift | Schema (Agent 2A) |
| Gate 2.6 (Dev start) | `docs/dispatch/agent2b-v{ver}.{phase}.md` | PM / Architect |
| Gate 3 (QA pass) | `docs/reviews/qa-v{ver}-rc.md` + smoke scripts | QA (Agent 3) |
| Gate Ship | `CHANGELOG.md` updated + `docs/reviews/ship-v{ver}.md` | Ship process |

**Enforcement**: Before closing any gate, run `ls -la <artifact_path>` and include the output in your ACK. Missing artifact = STATUS: BLOCKED.

---

## Commit Discipline

- Each task = 1 commit, no batching
- Commit body must have non-goals section
- Feature / doc / migration / refactor are separate commits, never mixed
- No `--amend`, no push to remote (user says when to push)

### Self-Verify Checkpoint (before every commit)
Ask yourself:
1. Did I add anything not in the dispatch brief? (if yes, remove it)
2. Can this commit be independently reverted?
3. Are there any hardcoded secrets?

---

## Dispatch Brief — 8 Mandatory Sections

Every `docs/dispatch/agent2b-v{ver}.{phase}.md` must contain:

- **§1 Scope** — Must-ship / non-goals / boundaries (reference PRD section numbers)
- **§2 Hard constraints** — Constraint list, each citing its source (PRD / BRAND / Amendment)
- **§3 Commit plan** — Table: one row per commit (message / files changed / DoD)
- **§4 DoD checklist** — Global completion criteria (including negative assertions)
- **§5 Escalation triggers** — When to STOP and ask, never decide alone
- **§6 Progress record** — Table: Step / Commit / Status / Notes (append as you work)
- **§7 Pending variance requests** — PRD deviations awaiting approval (mark RESOLVED when done)
- **§8 Next phase handoff notes** — Memo for the next phase

---

## STOP Report Format (Dev → PM)

STOP reports must be **PM-readable** — no code, no file line numbers.

```
FORMAT:
1. What was done (one sentence, no code)
2. Impact on PM (need to retest UX? new business risk? PRD change needed?)
3. Gate evidence: ls -la <artifact_path>
```

Example:
```
✅ PPT auth gap patched — unauthenticated access now returns 401.
Impact: None for you, no UX retest needed.
Gate evidence: ls -la docs/reviews/auth-surface-v1.2.md → 2.4K, 2026-04-15
```

---

## Resume Ritual (new window / interrupted session)

When starting a new conversation for this project, read these in order before doing anything:

1. `git log --oneline -12`
2. `docs/dispatch/<current-phase-brief>.md` (§6 progress + §7 pending)
3. `docs/prd/PRD_v*_AMENDMENTS.md` (all approved deviations)
4. `docs/prd/PRD_v*.md` (relevant sections)
5. `CHANGELOG.md`

Then report:
- (a) Last commit hash + message
- (b) Pending TODOs from brief §6
- (c) Pending decisions from brief §7
- (d) Proposed next step

**Do not start working until the user confirms.**

---

## Code Execution Rules

### Concurrency primitives
When introducing Lock / asyncio.Lock / Queue:
- Must write smoke test (N >= 10 concurrent iterations)
- Lock coverage checklist: shared dict access under lock? No I/O inside lock? No nested locks?
- "Lock looks correct" is not evidence — run it

### "Existing code works, no changes needed"
When claiming existing code satisfies the requirement:
- Must run real smoke test (curl / pytest / python -c)
- Reading code and saying "looks right" is not sufficient
- STOP report must include: "Smoke: ran X, output Y, verdict Z"

### Negative assertions
Before writing `assert X not in result`:
- Must have a positive assertion first proving result is not empty
- Negative assertions on empty state pass vacuously = untested

### Inheriting old code
Before reusing v0/v1 code:
1. Read actual implementation (don't assume it matches docs)
2. Diff against new spec
3. Conflicts → register variance

---

## Project Directory Structure

```
<project-root>/
├── docs/
│   ├── prd/
│   │   ├── PRD_v1.0.md                  # LOCKED
│   │   ├── PRD_v1.0_AMENDMENTS.md       # Append-only deviation log
│   │   └── PRD_v1.1.md                  # Next version (drafting or LOCKED)
│   ├── brand/
│   │   └── BRAND_GUIDELINE_v1.0.md      # LOCKED
│   ├── dispatch/
│   │   └── agent2b-v1.1.B.md            # Current phase brief
│   ├── reviews/                          # Gate evidence artifacts
│   │   ├── plan-eng-review-v1.0.md
│   │   ├── qa-v1.0-rc.md
│   │   └── ship-v1.0.md
│   ├── openapi_v1.0.yaml                # Schema-First authority
│   └── ARCHITECTURE.md
├── CHANGELOG.md
├── CLAUDE.md                             # ← THIS FILE
└── <code directories>
```

---

## What NOT to Do

- Do not say "this window can be closed" — the user decides when to close
- Do not say "should be fine" without a verification command
- Do not mix multiple concerns in one commit
- Do not edit LOCKED documents in place
- Do not skip any gate on your own
- Do not omit the non-goals list (commit body and dispatch brief both require it)
- Do not write strategy discussions as long paragraphs — use structured sections + recommended option
