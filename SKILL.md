---
name: factory-workflow
description: |
  Commercial-grade development workflow for solopreneurs and small teams.
  Two modes: fast (6 gates, 1 window, sub-agents) and full (14 gates, multi-window).
  File-authoritative state, strict commit discipline, auto-detects project state,
  enforces gate artifacts, routes to gstack skills.
---

# factory-workflow — Commercial Dev Orchestration Skill

## Meta-Rules (read before anything else)

1. **Files are authoritative** — Every decision / tool invocation / gate transition must be persisted to a file. Chat promises don't count
2. **No artifact = BLOCKED** — Before closing any gate, must `ls -la <artifact_path>` to prove it exists. "Should be there" is not accepted
3. **1 commit = 1 concern** — Feature / doc / migration / refactor each get their own commit. Every commit message includes non-goals
4. **LOCKED = immutable** — PRD / BRAND changes go through Amendments, never in-place edits
5. **Two modes exist** — `factory_mode: fast` (default) or `factory_mode: full`. Read from project CLAUDE.md. Rules below apply differently per mode

### Fast vs Full Mode

| | **Fast** (default) | **Full** |
|---|---|---|
| **When** | MVP, new projects, < 100 DAU | Paid users, > 100 DAU, money paths |
| **Gates** | 6 essential | 14 full |
| **Windows** | 1 main + sub-agents | 4 independent windows |
| **Brief** | 4 sections (scope / non-goals / commits / progress) | 8 sections (full) |
| **PM role** | PM-lite: can read git diff directly | PM-strict: STOP reports must be reformatted |
| **Walkthrough** | Skip (PM is the builder) | Mandatory |
| **AUDIT trigger** | Off | 3 consecutive all-green |
| **Switch** | Set `factory_mode: full` in CLAUDE.md | Set `factory_mode: fast` in CLAUDE.md |

---

## Preamble (runs every invocation)

```bash
set +e
_CWD=$(pwd)
_PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$_CWD")
_PROJECT_NAME=$(basename "$_PROJECT_ROOT")
_BRANCH=$(git -C "$_PROJECT_ROOT" branch --show-current 2>/dev/null || echo "unknown")

echo "=== Factory Workflow v1.1 — Project State ==="
echo "PROJECT: $_PROJECT_NAME"
echo "ROOT: $_PROJECT_ROOT"
echo "BRANCH: $_BRANCH"

# Detect factory_mode from CLAUDE.md
_FACTORY_MODE="fast"
if [ -f "$_PROJECT_ROOT/CLAUDE.md" ]; then
  _MODE_LINE=$(grep -i 'factory_mode' "$_PROJECT_ROOT/CLAUDE.md" 2>/dev/null | head -1)
  if echo "$_MODE_LINE" | grep -qi 'full'; then
    _FACTORY_MODE="full"
  fi
fi
echo "FACTORY_MODE: $_FACTORY_MODE"
echo ""

echo "=== Adoption check ==="
if [ -f "$_PROJECT_ROOT/CLAUDE.md" ]; then
  if grep -q "Factory Workflow" "$_PROJECT_ROOT/CLAUDE.md" 2>/dev/null; then
    echo "ADOPTED: yes (CLAUDE.md references Factory Workflow)"
  else
    echo "ADOPTED: partial (CLAUDE.md exists, no Factory Workflow reference)"
  fi
else
  echo "ADOPTED: NO — CLAUDE.md missing"
fi

if [ -d "$_PROJECT_ROOT/docs/reviews" ]; then
  _REVIEW_COUNT=$(ls "$_PROJECT_ROOT/docs/reviews" 2>/dev/null | grep -v '^\.' | wc -l | tr -d ' ')
  echo "REVIEWS: $_REVIEW_COUNT artifacts in docs/reviews/"
else
  echo "REVIEWS: NO docs/reviews/ directory"
fi

if [ -d "$_PROJECT_ROOT/docs/prd" ]; then
  _LATEST_PRD=$(ls -1t "$_PROJECT_ROOT/docs/prd"/PRD_v*.md 2>/dev/null | head -1)
  echo "LATEST_PRD: $(basename "$_LATEST_PRD" 2>/dev/null || echo none)"
else
  echo "LATEST_PRD: none (no docs/prd/)"
fi

if [ -d "$_PROJECT_ROOT/docs/dispatch" ]; then
  _LATEST_BRIEF=$(ls -1t "$_PROJECT_ROOT/docs/dispatch"/agent2b-*.md 2>/dev/null | head -1)
  echo "LATEST_BRIEF: $(basename "$_LATEST_BRIEF" 2>/dev/null || echo none)"
fi

echo ""
echo "=== Recent git ==="
git -C "$_PROJECT_ROOT" log --oneline -6 2>/dev/null || echo "not a git repo"

echo ""
echo "=== Last 3 gate transitions (inferred from docs/reviews/ mtime) ==="
if [ -d "$_PROJECT_ROOT/docs/reviews" ]; then
  ls -lt "$_PROJECT_ROOT/docs/reviews"/*.md 2>/dev/null | head -3 | awk '{print $NF, "("$6, $7, $8")"}'
fi

echo ""
echo "=== Pending gate check (mode: $_FACTORY_MODE) ==="
if [ -n "$_LATEST_PRD" ]; then
  _VER=$(basename "$_LATEST_PRD" .md | sed 's/PRD_//')
  echo "Checking for $_VER artifacts:"
  if [ "$_FACTORY_MODE" = "fast" ]; then
    # Fast mode: 6 essential gates only
    for _G in plan-eng-review qa ship; do
      _ART="$_PROJECT_ROOT/docs/reviews/${_G}-${_VER}.md"
      if [ -f "$_ART" ]; then
        echo "  OK ${_G}-${_VER}.md"
      else
        echo "  XX ${_G}-${_VER}.md"
      fi
    done
    # PRD check (file existence, not review artifact)
    if grep -q "LOCKED" "$_LATEST_PRD" 2>/dev/null; then
      echo "  OK PRD LOCKED"
    else
      echo "  XX PRD not LOCKED"
    fi
    # Dispatch brief check
    if [ -n "$_LATEST_BRIEF" ]; then
      echo "  OK dispatch brief exists"
    else
      echo "  XX no dispatch brief"
    fi
  else
    # Full mode: all 14 gates
    for _G in office-hours-prd analytics-plan plan-eng-review auth-surface money-surface paywall-mental qa ship post-ship-t7; do
      _ART="$_PROJECT_ROOT/docs/reviews/${_G}-${_VER}.md"
      if [ -f "$_ART" ]; then
        echo "  OK ${_G}-${_VER}.md"
      else
        echo "  XX ${_G}-${_VER}.md"
      fi
    done
  fi
fi

echo ""
if [ "$_FACTORY_MODE" = "full" ]; then
  echo "=== Streak audit (full mode only) ==="
  if [ -d "$_PROJECT_ROOT/docs/reviews" ]; then
    _24H_ARTIFACTS=$(find "$_PROJECT_ROOT/docs/reviews" -name "*.md" -mtime -1 2>/dev/null | wc -l | tr -d ' ')
    echo "Artifacts written in last 24h: $_24H_ARTIFACTS"
    if [ "$_24H_ARTIFACTS" = "0" ]; then
      _LAST_COMMITS=$(git -C "$_PROJECT_ROOT" log --oneline -3 2>/dev/null | wc -l | tr -d ' ')
      if [ "$_LAST_COMMITS" -ge "3" ]; then
        echo "WARNING: AUDIT TRIGGER: 3+ commits recently, 0 gate artifacts in 24h — gstack may be underused"
      fi
    fi
  fi
else
  echo "=== Streak audit: skipped (fast mode) ==="
fi
```

Report preamble output to the user, then route to a Mode based on the output.

---

## Mode Routing

Route to one of 6 modes based on preamble output:

| Preamble State | Mode | Action |
|---|---|---|
| `ADOPTED: NO` | **BOOTSTRAP** | New project, create CLAUDE.md + docs/ structure first |
| `ADOPTED: yes` + no pending ops | **RESUME** | Read git log + latest brief + latest artifact, report position + next step |
| User is closing a gate | **GATE_TRANSITION** | Force ls artifact (fast: 6 gates / full: 14 gates) |
| User is opening a new sub-phase | **PHASE_OPEN** | Write dispatch brief (fast: 4 sections / full: 8 sections) |
| STOP report mentions deviation / uncertainty | **VARIANCE** | Route to `/office-hours` or `/investigate` |
| 3 consecutive green with no artifact | **AUDIT** | Force stop (full mode only, skipped in fast mode) |

---

## Mode 1: BOOTSTRAP (first-time adoption)

**Trigger**: `ADOPTED: NO` + user says "new project X" / "add Factory Workflow to this project"

**Actions**:

1. Run `mkdir -p <root>/docs/{prd,dispatch,brand,reviews,retro}` to create scaffolding
2. Write `<root>/CLAUDE.md` from `templates/CLAUDE.md.template` — replace `{{PROJECT_NAME}}`, `{{PROJECT_TYPE}}`, `{{CURRENT_VERSION}}`, `{{NEXT_VERSION}}` with actual values (ask user if unclear)
3. Write `<root>/docs/reviews/.gitkeep` as gate evidence container
4. Check `.gitignore` — if `*.md` exclusion exists, add `!CLAUDE.md` exception
5. Standalone commit: `docs: bootstrap Factory Workflow — CLAUDE.md routing + docs/reviews/`
6. Switch to Mode PHASE_OPEN, first phase is Gate 1 PRD

**Forbidden**: Bootstrap commit must NOT contain any feature / config / refactor changes

---

## Mode 2: RESUME (session handover)

**Trigger**: `ADOPTED: yes` + user says "continue X" / pastes resume ritual

**Actions**:

1. Read 6 items in order:
   - `git log --oneline -12`
   - Latest dispatch brief (§6 progress + §7 pending)
   - Latest `PRD_v*_AMENDMENTS.md`
   - Latest `PRD_v*.md` relevant sections
   - Latest `BRAND_v*.md` (if exists)
   - Project memory (if exists)

2. From preamble's pending gate check output, find the first XX (missing) gate — that's the next step

3. Give user a structured report:
   ```
   [Current State]
   - Last commit: <hash> <msg>
   - Latest PRD: PRD_v1.2.md (LOCKED | DRAFT)
   - Current phase: v1.2.A.1 (per brief §6)
   - Last ACK'd gate: Gate 2.1 auth-surface
   - Pending decisions (brief §7): <list>

   [Next Step]
   Next gate to close: Gate 2.5 Money Surface (L1, requires your approval)
   Action: invoke /office-hours to run money surface audit
   Output artifact: docs/reviews/money-surface-v1.2.md

   Do not start working — waiting for your confirmation.
   ```

4. Wait for user confirmation, then switch to appropriate Mode

---

## Mode 3: GATE_TRANSITION (closing a gate)

**Trigger**: User says "Gate X ACK" / STOP report claims a gate is done

**Iron rule**: **No ls, no ACK.**

**Actions**:

1. Look up the gate in the Gate Table (see below) to find the artifact path
2. Run `ls -la <artifact_path>`
3. If **missing**:
   ```
   STATUS: BLOCKED
   REASON: Gate X artifact <path> does not exist, cannot close gate
   ATTEMPTED: ls -la <path>
   RECOMMENDATION: Run <corresponding skill> first, produce artifact, then come back
   ```
   No bypass accepted.
4. If **exists**:
   ```
   Gate X ACK
   Gate evidence: ls -la <path>
   <full ls output>

   Next gate: <next_gate>
   ```
5. Append a row to dispatch brief §6 Progress record
6. If this is an L1 gate, must AskUserQuestion for PM approval (orchestrator cannot decide for PM)

### Gate 1 PRD Special Rule: Mandatory PRD Walkthrough

**Hard constraint**: Before Gate 1 PRD can close, there **must** be a PM-led **PRD Walkthrough session**. This prevents "Gate 1 gets closed by incremental ACKs without PM ever reading the full PRD."

**Session format**:

1. After Agent 1 finishes `PRD_v{ver}.md`, mark it `DRAFT` (do NOT lock yet)
2. Walk through the PRD section by section with the PM
3. For each section, ask PM 3 things:
   - Do you understand the business meaning of this section?
   - Anything to add / remove / change?
   - Any missing requirements?
4. Summarize in `docs/reviews/prd-walkthrough-v{ver}.md`
5. Apply walkthrough feedback, then LOCK the PRD
6. Gate 1 requires BOTH walkthrough artifact AND LOCKED PRD

**No cross-version inheritance**: Each new version needs a fresh walkthrough.

---

## Mode 4: PHASE_OPEN (starting a new sub-phase)

**Trigger**: User says "start v1.2.A.1" / previous phase STOP + "next step?"

**Actions**:

1. Check if previous phase's Gate 2.6 is closed (if not → bounce to GATE_TRANSITION)
   - In full mode, also check Gate 2.5 (Money Surface)
2. Write `docs/dispatch/agent2b-v{ver}.{phase}.md`
3. Commit brief: `docs(dispatch): <ver>.<phase> <scope>`
4. In fast mode: proceed to dev execution immediately (sub-agent or same window)
   In full mode: switch back to RESUME mode and wait for Dev window to pick up

### Fast Mode Brief (4 sections)

```markdown
# Brief — {PROJECT} v{VER}.{PHASE}

## §1 Scope + Non-goals
### Must ship
- [reference PRD FR-xxx]

### Non-goals
- [explicitly out of scope]

## §2 Commit Plan
| # | Commit message | Files | DoD |
|---|---|---|---|
| 1 |  |  |  |

## §3 Progress
| Step | Commit | Status | Notes |
|---|---|---|---|

## §4 Variance (if any)
| # | Issue | Status | Resolution |
|---|---|---|---|
```

Fast brief is ~30 lines. Scope and non-goals are merged. No §0 gstack check (fast mode trusts the builder). No §2 Hard constraints (PRD is the source). No §5 Escalation (builder knows when to stop). No §8 Handoff (single window, no handoff needed).

### Full Mode Brief (8 sections)

Use `templates/dispatch-brief.md.template` with all 8 sections:
§0 Gate evidence ledger + gstack relevance check, §1 Scope, §2 Hard constraints, §3 Commit plan, §4 DoD, §5 Escalation triggers, §6 Progress, §7 Variance, §8 Handoff notes.

---

## Mode 5: VARIANCE (deviation / decision needed)

**Trigger**: STOP report contains "found X inconsistent with PRD" / "root cause unknown" / "quota exhausted" / "decision needed"

**Actions**:

1. Identify variance type:
   - **Strategic / commercial / pricing / PMF** → route to `/office-hours`
   - **Root cause unknown / tech debt / external dependency** → route to `/investigate`
2. Produce artifact:
   - office-hours conclusion → `docs/reviews/office-hours-<topic>-v{ver}.md`
   - investigate conclusion → `docs/reviews/investigate-<topic>-v{ver}.md`
3. Write to `docs/prd/PRD_v{ver}_AMENDMENTS.md`:
   - First grep for latest amendment number (never rely on memory)
   - Amendment body must reference artifact path
4. Switch to GATE_TRANSITION to close the variance gate

---

## Mode 6: AUDIT (forced self-check)

**Trigger**: Preamble reports "3+ commits recently, 0 gate artifacts in 24h" or 3 consecutive all-green STOP/ACK

**Actions**:

1. Stop — do not accept any new phase requests
2. Run `find docs/reviews -name "*.md" -mtime -7 | wc -l`
3. List last 3 commits + which gate artifact each should have produced
4. For each commit ask: "Which gate should this have triggered? Where is the artifact?"
5. Fill in missing artifacts (may need to retroactively invoke gstack skills)
6. Write audit report to `docs/reviews/audit-<date>.md`
7. Tell user: "Pipeline was running too smoothly, which is a dereliction signal. Fill in these N artifacts before continuing."

---

## Gate Table

### Fast Mode Gates (6 essential)

These gates are always enforced, regardless of mode:

| Gate | Required Artifact | Skill |
|---|---|---|
| **Gate 1 PRD** | `docs/prd/PRD_v{ver}.md` LOCKED | (PM writes directly) |
| **Gate 2 Schema** | `docs/openapi_v{ver}.yaml` + `docs/reviews/plan-eng-review-v{ver}.md` | `/plan-eng-review` |
| **Gate 2.6 Phase open** | `docs/dispatch/agent2b-v{ver}.{phase}.md` | (orchestrator) |
| **Gate 3 Smoke** | `docs/reviews/qa-v{ver}-rc.md` | `/qa` |
| **Gate Ship** | `CHANGELOG.md` + annotated tag + `docs/reviews/ship-v{ver}.md` | `/ship` |
| **Variance Gate** | `docs/prd/PRD_v{ver}_AMENDMENTS.md` | `/office-hours` or `/investigate` |

### Full Mode Gates (14 — adds 8 more)

These gates are ONLY enforced when `factory_mode: full`:

| Gate | L1/L2 | Required Artifact | Skill |
|---|---|---|---|
| Gate 1 Walkthrough | **L1** | `docs/reviews/prd-walkthrough-v{ver}.md` | `/office-hours` |
| Gate 1.5 Analytics | **L1** | `docs/reviews/analytics-plan-v{ver}.md` | `/office-hours` |
| Gate 2.1 Auth surface | L2 | `docs/reviews/auth-surface-v{ver}.md` (100% coverage) | (CI script) |
| Gate 2.2 Contract test | L2 | `backend/tests/test_v{ver}_contract.py` + CI pass | (pytest) |
| Gate 2.3 Pricing single source | L2 | `shared/pricing.json` + drift check pass | (CI script) |
| Gate 2.4 Brand verify | L2 | `scripts/verify-brand.ts` pass | (CI script) |
| Gate 2.5 Money Surface | **L1** | `docs/reviews/money-surface-v{ver}.md` (PM signed off) | `/office-hours` |
| Gate Brand/UX | **L1** | `docs/brand/BRAND_v{ver}.md` LOCKED | `/design-consultation` |
| Gate 3.5 Paywall Mental | **L1** | `docs/reviews/paywall-mental-v{ver}.md` (PM signed off) | `/office-hours` |
| Gate T+7 | **L1** | `docs/reviews/post-ship-t7-v{ver}.md` (metrics + retro) | `/retro` + `/office-hours` |

**Enforcement**: Before closing any gate, `ls -la <artifact_path>` to prove it exists. Missing = BLOCKED. In fast mode, only check the 6 essential gates. In full mode, check all 14.

### Gate 3 Cost-Aware Execution Order

Token-efficient QA funnel — if step N fails, do NOT proceed to step N+1:

| Step | Cost | Content | On Failure |
|---|---|---|---|
| **Step 1** | $0 text | Contract test (pytest) + Brand verify + type check | Red → bounce back to Dev |
| **Step 2** | $0 script | `dev_scripts/{phase}_smoke_*.py` pixel-level curl+PIL assertions | Red → bounce back to Dev |
| **Step 3** | $$$ VLM | Only if steps 1+2 green → `/qa` + browser visual VLM review | Red → screenshot + bounce |

**Hard rule**: Agent 3 must record in `docs/reviews/qa-v{ver}-rc.md` which steps ran and which didn't. Skipping steps = violation.

---

## Concurrency Tier (progressive hardening)

Prevents premature optimization. Agent 2A must read `concurrency_tier` from project CLAUDE.md before writing schema/backend code.

| Tier | Business State | Must Have | Must NOT Have (until upgrade) |
|---|---|---|---|
| **T0_MVP** | < 100 DAU | DB transaction on money/quota paths + N+1 static audit | Redis cache, distributed locks, k6 load test, read replicas |
| **T1_BETA** | 100-1K DAU | T0 + in-memory cache (30s TTL) + `SELECT FOR UPDATE` on money paths | k6 load test, microservices, distributed locks |
| **T2_PROD** | 1K-10K DAU | T1 + Redis cache + rate limiting | Read replicas, chaos engineering |
| **T3_SCALE** | > 10K DAU | T2 + k6 (P95 < 800ms, error < 0.1%) + read replicas | No restrictions |

**Tier upgrades** require: quantitative trigger met → Variance Gate → PM approval → Agent 2A re-scans historical tech debt ledger → dedicated phase for backfilling.

Agent 2A's `docs/reviews/plan-eng-review-v*.md` must include `[Architecture Tier Check]`:
```markdown
## [Architecture Tier Check]
- Current tier: T0_MVP
- Implemented safeguards: DB transaction on money path (commit abc123)
- Tech debt ledger (legitimately skipped): Redis cache / distributed locks / k6 — deferred until DAU > 100 sustained 2 weeks
```
Missing any of these 3 lines → Gate 2 blocked.

---

## Agent Topology (4 agents + boundaries)

This skill orchestrates 4 agents. Each is an independent Claude session — they do NOT share chat context, communicating ONLY through files.

### Agent 1 — PM Orchestrator (main window, this skill)
- **Role**: L1 gate decisions, mode routing, audit triggers, STOP report reformatting
- **Can read**: All `docs/` + `git log` + CLAUDE.md + project memory
- **Can write**: `docs/reviews/<L1-gate>-v*.md`, `docs/prd/PRD_v*_AMENDMENTS.md`, `docs/retro/`, `CLAUDE.md`
- **Can invoke**: `/office-hours`, `/retro`, `/ship` (L1 approval only)
- **Forbidden**: Editing `backend/*.py` / `src/*.tsx` / migrations / feature code; deciding L1 gates without PM

### Agent 2A — Schema/Plan Architect (separate window)
- **Role**: Gate 2 (schema drift), Gate 2.6 (phase open), writes dispatch briefs
- **Can read**: PRD, BRAND, existing OpenAPI, alembic history, prior briefs
- **Can write**: `docs/openapi_v*.yaml`, `backend/alembic/versions/*.py`, `docs/dispatch/agent2b-*.md`, `docs/reviews/plan-eng-review-*.md`
- **Can invoke**: `/plan-eng-review`
- **Forbidden**: Writing feature code; editing LOCKED PRD; deciding variances

### Agent 2B — Dev Executor (separate window)
- **Role**: Execute dispatch brief §3 Commit plan row by row
- **Can read**: Dispatch brief, PRD, BRAND, source code
- **Can write**: `backend/`, `src/`, `scripts/`, `tests/`, `dev_scripts/`, feature commits
- **Can invoke**: `/investigate` (on STOP), `/qa` (in-phase smoke), `/review` (self-review)
- **Forbidden**: Editing LOCKED docs; deciding variances on their own; mixing commit scopes

### Agent 3 — QA/Ship (may share window with 2B or separate)
- **Role**: Gate 3 Pixel smoke, Gate Ship L2 execution
- **Can read**: Brief §4 DoD, all L2 gate artifacts, CHANGELOG
- **Can write**: `dev_scripts/*smoke*.py`, `docs/reviews/qa-*-rc.md`, `CHANGELOG.md`, `git tag`
- **Can invoke**: `/qa`, `/ship`, `/design-review`, `/canary`
- **Forbidden**: Pushing tags without PM L1 approval; skipping RC preview

### Agent Permission Matrix

| Path / Resource | Agent 1 PM | Agent 2A Plan | Agent 2B Dev | Agent 3 QA |
|---|:---:|:---:|:---:|:---:|
| `docs/prd/PRD_v*.md` (LOCKED) | read | read | read | read |
| `docs/prd/PRD_v*_AMENDMENTS.md` | **read/write** | read | read | read |
| `docs/brand/BRAND_v*.md` | **read/write** | read | read | read |
| `docs/openapi_v*.yaml` | read | **read/write** | read | read |
| `docs/dispatch/agent2b-*.md` | read | **read/write** | read(§1-5) / write(§6-7) | read |
| `docs/reviews/*-L1-*.md` | **read/write** | read | read | read |
| `docs/reviews/plan-eng-review-*.md` | read | **read/write** | read | read |
| `docs/reviews/qa-*-rc.md` | read | read | read | **read/write** |
| `backend/`, `src/` (feature) | no | no | **read/write** | read |
| `backend/alembic/versions/` | no | **read/write** | read | read |
| `dev_scripts/*smoke*.py` | no | no | read | **read/write** |
| `git tag` | approve | no | no | execute (after approval) |

**Memory write permission**: Only Agent 1 writes to project memory. Agents 2A/2B/3 report lessons in STOP reports, Agent 1 decides what to persist.

---

## Handoff Contracts (inter-agent file handshake protocol)

4 agents share NO chat context — they communicate ONLY through files. Every handoff requires a file artifact.

### Contract A: Agent 1 → Agent 2A (open phase)
- **Trigger**: Agent 1 decides to open a new sub-phase (Mode PHASE_OPEN)
- **Input**: Agent 1 writes `docs/dispatch/agent2b-v{ver}.{phase}.md` §1 Scope + §2 Hard constraints + §5 Escalation triggers (empty §3 for 2A to fill)
- **Channel**: File + git commit (`docs(dispatch): v{ver}.{phase} scope draft`)
- **Agent 2A pickup signal**: Latest dispatch brief has empty §3

### Contract B: Agent 2A → Agent 2B (issue brief)
- **Trigger**: Agent 2A completes §3 Commit plan + §4 DoD + §0 gstack check
- **Input**: Complete dispatch brief (all 8 sections filled)
- **Channel**: git commit (`docs(dispatch): v{ver}.{phase} ready for exec`)
- **Agent 2B pickup signal**: `git log --oneline -5` shows "ready for exec" + brief §3 non-empty

### Contract C: Agent 2B → Agent 1 (STOP feedback)
- **Trigger**: Agent 2B completes a commit / hits variance / finishes phase
- **Input**: STOP report, strictly formatted per `templates/stop-report.md.template`
- **Channel**: Agent 2B cannot write memory directly; STOP report goes to Agent 1, who reformats for PM
- **Agent 1 duty**: Any STOP containing code / line numbers / technical terms MUST be reformatted into 3-paragraph PM-readable structure before showing to PM

### Contract D: Agent 2B → Agent 3 (RC handoff)
- **Trigger**: Agent 2B completes all §3 commits, Gates 2.1-2.4 all green
- **Input**: Brief §6 all done, all L2 gate artifacts exist
- **Channel**: git commit + `docs/reviews/agent2b-handoff-v{ver}.{phase}.md` handoff memo
- **Agent 3 pickup signal**: Handoff memo exists + all L2 artifact `ls` succeeds

### Contract E: Agent 3 → Agent 1 (ship approval request)
- **Trigger**: Agent 3 completes Gate 3 Pixel smoke + RC artifact
- **Input**: `docs/reviews/qa-v{ver}-rc.md` + visual evidence
- **Channel**: AskUserQuestion (Agent 1 prompts PM), options: A) approve ship / B) bounce back / C) E-VAR
- **Agent 1 duty**: MUST AskUserQuestion, cannot approve Gate Ship on PM's behalf

### Contract F: Any Agent → Agent 1 (variance escalation)
- **Trigger**: Agent 2A/2B/3 discovers PRD/BRAND inconsistency / external dep down / root cause unknown
- **Input**: STOP report + explicit `VARIANCE: <type>` tag
- **Channel**: Immediately stop work, return to Agent 1 for Mode 5 VARIANCE
- **Forbidden**: Sub-agents deciding to "work around" / "E-VAR downgrade" on their own

---

## Rule Location Quick Reference

| Rule Type | Location | Example |
|---|---|---|
| **Meta-rules** (session-level) | SKILL.md §Meta-Rules | "User is PM, not dev" |
| **Mode routing** | SKILL.md §Mode Routing + Modes 1-6 | "ADOPTED: NO → BOOTSTRAP" |
| **Gate hard constraints** | SKILL.md §Gate Table | "Gate 2.5 requires money-surface-v*.md" |
| **Agent permissions** | SKILL.md §Agent Topology | "Agent 2B cannot write migrations" |
| **Handoff protocol** | SKILL.md §Handoff Contracts | "Contract C: STOP must be reformatted" |
| **Forbidden list** | SKILL.md §Forbidden List | "No ls, no ACK" |
| **Project-specific** | Project root `CLAUDE.md` | Project-specific constraints |
| **Per-phase scope** | `docs/dispatch/agent2b-v*.{phase}.md` | "§1 Must ship / §2 constraints" |

**Principle**: SKILL.md holds "how to run the process" + "who can do what". Project CLAUDE.md holds "project-specific things". These two layers don't duplicate each other.

---

## Sub-agent Tactical Rules (Context Protection)

The main agent (PM / Dev main thread) is the process orchestrator — context is a scarce resource. Any "read-only recon / text condensation / parallel expert panel / full-scope audit" work MUST be delegated to sub-agents via the `Agent` tool. Main thread only receives condensed reports. This is a **Context Breakwater**.

### Hard Constraints for Main Agent

1. **Sub-agents are read-only analysis + text condensation only** — NEVER let sub-agents write code / git commit / edit LOCKED docs
2. **Every sub-agent must have a word limit** (< 200 / < 300 words / 3-paragraph), preventing report bloat from polluting main context
3. **Sub-agent output must be immediately actionable** — main agent should adopt or reject at a glance, not "re-read source to verify"
4. **Parallel spawns use single message with multiple tool calls**, serial only when there are dependencies

### 4 Standard Spawn Scenarios

#### Scene 1: Gate 2 Schema Drift Scan (read-only recon)
- **Trigger**: Agent 2A about to close Gate 2
- **Task**: Scan all migrations + models + OpenAPI, output two-tier drift checklist
- **Sub-agent prompt**: "Read-only recon. Do NOT write files or commit. Grep migrations/, models/, openapi_v*.yaml. Output two columns: A = component field name diffs, B = path URL/params/response shape diffs. Format: `[A|B] <file>:<line> — <one sentence>`. No diff = 'drift 0'. **< 200 words total**."

#### Scene 2: Gate 2.5 Money Surface Council (parallel 4 experts)
- **Trigger**: Schema closed, entering Money Surface decision
- **Task**: Spawn 4 parallel sub-agents, each playing an expert role
- **Experts**: Payment security / Pricing architect / Quota defense engineer / Business risk advisor
- **Each sub-agent**: Answer 3 questions only: 1) Biggest commercial gap? 2) Worst case if unfixed? 3) Minimum fix cost? **< 300 words**, no pleasantries.

#### Scene 3: STOP Report Sanitizer (log cleaner)
- **Trigger**: Dev agent has raw tool output, about to write STOP report for PM
- **Task**: Translate raw dev output into PM-readable 3-paragraph format
- **Sub-agent prompt**: "You are a log sanitizer. Translate this dev output into: 1) What was done (one sentence, no filenames/line numbers/code), 2) PM impact (retest UX? business risk? blocking?), 3) Gate evidence (ls commands only). **NO code snippets, line numbers, or stack traces. Strict 3 paragraphs, < 250 words.**"

#### Scene 4: AUDIT Full Deliverables Scan
- **Trigger**: Mode 6 AUDIT fires
- **Task**: Scan `docs/reviews/` for gstack invocation traces and gate evidence completeness
- **Sub-agent prompt**: "You are an auditor. `ls -la docs/reviews/` for files modified in last 24h. For each, grep for gstack skill references (`/office-hours`, `/plan-eng-review`, `/qa`, `/ship`, `/investigate`, `/retro`). Output: table with rows=artifacts, columns=skills (yes/no), final line = 'audit pass | audit fail: <what's missing>'. **< 300 words**, no explanations."

### Physical Boundaries
- Sub-agents run in the same Claude Code process, share cwd and git repo, but have NO access to main agent's chat history — spawn prompts must be self-contained
- Only the sub-agent's final message enters main context — word limit = context increment

---

## Git Exception Snapshot Isolation (Dev emergency protocol)

When Agent 2B encounters ANY of these blocking conditions, it is **absolutely forbidden** to force-commit dirty code on the main branch:

- Current approach proven unviable, needs complete rethink
- 3 consecutive commits trying to fix the same deep bug, all failed
- Project in seriously **broken state** (won't compile / test framework crashed / dependency deadlock / imports broken), unrecoverable after 30+ minutes
- Root cause unknown, needs `/investigate`

**Does NOT trigger** for: typos, linter warnings, simple bugs fixed in 1-2 attempts.

### Fault Scene Preservation SOP

```bash
git status                                                    # 1. Confirm dirty state
git checkout -b snapshot-bug-<slug>-$(date +%s)               # 2. Dirty changes follow into new branch
git add -A                                                    # 3. Track all untracked files
git commit -m "STOP_REPORT: <one-line broken state>"          # 4. Freeze the crime scene
git checkout <original-branch>                                 # 5. Return to main line
git status                                                    # 6. MUST show "working tree clean"
```

Step 6 MUST be clean. If not, preservation failed — do not proceed.

**Branch naming**: `snapshot-bug-<feature-slug>-<unix-timestamp>`

### PM Decision Options (via Mode 5 VARIANCE)

- **A) Abandon**: `git branch -D snapshot-bug-*` — destroy fault branch, main line untouched, Dev starts over
- **B) Guide**: PM provides direction via amendment, Dev continues on snapshot branch, merges back when fixed
- **C) Escalate**: Invoke `/investigate` for deep root cause analysis

**Forbidden**: Dev continuing to debug on snapshot branch without PM decision.

---

## STOP Report PM-Readable Rewriter

If a Dev STOP report contains code / file line numbers / technical jargon, you MUST **rewrite** before showing to user.

### Rewrite Rules

| Not Allowed | Allowed |
|---|---|
| `routes.py:47` | (remove) |
| `@login_required decorator` | "login check" |
| `Added column user.wechat_openid` | "Added WeChat ID field to user table" |
| `Fixed bug in sqlalchemy relationship` | "Data model relationship fixed" |
| `Migration 0042 applied` | "Database upgrade completed" |

### 3-Paragraph Structure (mandatory)

```markdown
**What was done**: <one sentence, no code>

**PM impact**:
- Need to retest UX? Yes / No
- New business risk? Yes / No (if yes, list clearly)
- PRD change needed? Yes / No

**Gate evidence**:
ls -la docs/reviews/<artifact>.md
<ls output>
```

If Dev STOP doesn't follow this format, rewrite it, then append:
> (note: original STOP report contained technical details, translated to PM-readable format)

---

## AskUserQuestion Rules (L1 gates only)

All L1 gate closures MUST use AskUserQuestion for PM approval. Orchestrator cannot decide for PM.

Format:

```
Re-ground: Project <name>, branch <branch>, about to close Gate X <name>
Simplify: Plain-language explanation of what this gate verifies and why PM must decide
Recommendation: <one sentence + rationale>
Options:
  A) <approve, rationale>
  B) <bounce back, rationale>
  C) <downgrade / E-VAR, rationale>
```

L2 gates do NOT need AskUserQuestion — just ls-verify and pass.

---

## Completion Protocol

Every skill run must end with a status:

- **DONE** — All requested operations complete, every step has artifact evidence
- **DONE_WITH_CONCERNS** — Complete, but PM should know about issues (list each)
- **BLOCKED** — Cannot continue; state which gate is blocked + artifact location + which skill to invoke
- **NEEDS_CONTEXT** — Missing information; state which file or user decision is needed

Format:

```
STATUS: <DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT>
GATE_CLOSED: <list of gates closed this session>
GATE_EVIDENCE: <list of artifact paths created>
NEXT_GATE: <next gate to work on>
PM_ACTION_REQUIRED: <what the user needs to do, or "none">
```

---

## Forbidden List (hard rules)

1. No ACK without `ls -la` output
2. No STOP reports with code / line numbers / technical jargon shown to PM (must rewrite)
3. No mixing feature + doc + migration + refactor in one commit
4. No in-place edits of LOCKED documents (PRD / BRAND / ARCHITECTURE)
5. No skipping L1 gates (PRD / Analytics / Money Surface / Paywall Mental / Ship / T+7)
6. No treating variance as normal phase (must go through VARIANCE mode)
7. No continuing past 3 consecutive all-green without artifact (must trigger AUDIT)
8. No deciding L1 gates without AskUserQuestion
9. No pushing tags to remote without PM approval
10. No omitting dispatch brief §0 gstack relevance check

---

## Version

- **v1.0.0** (2026-04-16) — Open source release. Generalized from v0.9.4 (battle-tested across multiple commercial projects). All personal bindings removed, all rules preserved.

## Origin

Factory Workflow was developed through real production use across multiple commercial projects by a solo PM/founder. Every rule exists because its absence caused a specific, documented failure:

- **Gate evidence** → gates were rubber-stamped when there was nothing to check
- **Dispatch briefs as files** → chat instructions were lost when sessions ended
- **Non-goals in commits** → scope creep was invisible without explicit exclusion
- **Two-tier drift check** → single-tier missed API-level mismatches
- **AUDIT mode** → gstack skills went completely unused when pipeline ran too smoothly
- **PM-readable STOP reports** → PM was shown raw code diffs and couldn't make informed decisions
- **PRD walkthrough** → Gate 1 was closed via incremental ACKs without PM ever reading the full PRD
- **Concurrency tiers** → premature optimization wasted tokens and delayed MVP
- **Snapshot isolation** → broken state on main branch blocked all other work

The rules are strict by design. Loosening them recreates the problems they solved.
