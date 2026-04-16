# Factory Workflow — Create Dispatch Brief

Create a dispatch brief for a dev phase. The brief is the **authoritative work order** — Agent 2B follows it, not chat messages.

**Phase identifier** (e.g., "v1.1.B" or "v1.2.A.1"): $ARGUMENTS

## Before you start

1. Read the LOCKED PRD and amendments
2. Read the OpenAPI spec
3. Read the architecture review
4. Read prior dispatch briefs if any (for handoff notes)
5. Read `git log --oneline -20` for recent context

## What to produce

Create `docs/dispatch/agent2b-v{phase}.md` with ALL 8 sections:

```markdown
# Dispatch Brief: Agent 2B — Phase {phase}

Created: {date}
PRD: docs/prd/PRD_v{ver}.md
OpenAPI: docs/openapi_v{ver}.yaml

## §0 Gate Evidence Ledger
<!-- Append one line per gate closure -->
| Gate | Artifact | ls output |
|---|---|---|

## §1 Scope
### Must ship
- [reference PRD FR-xxx]

### Non-goals
- [explicitly out of scope for this phase]

### Boundaries
- [what's in vs. out for this specific phase]

## §2 Hard Constraints
| # | Constraint | Source |
|---|---|---|
| 1 | ... | PRD §X / BRAND §Y / Amendment #Z |

## §3 Commit Plan
| # | Commit message | Files changed | DoD |
|---|---|---|---|
| 1 | feat: ... | src/... | unit test passes |

## §4 DoD Checklist
- [ ] All commits from §3 landed
- [ ] No drift in two-tier check
- [ ] Negative assertions have positive preconditions
- [ ] `grep -r "TODO" src/` = 0 uncommitted TODOs

## §5 Escalation Triggers
Stop and ask the user if:
- Scope ambiguity not resolvable from PRD + amendments
- Performance concern not covered in architecture review
- External dependency unavailable or rate-limited

## §6 Progress Record
| Step | Commit | Status | Notes |
|---|---|---|---|
<!-- Agent 2B appends here as work progresses -->

## §7 Pending Variance Requests
| # | Description | Status | Resolution |
|---|---|---|---|
<!-- Log PRD deviations here, mark RESOLVED when amendment is approved -->

## §8 Next Phase Handoff Notes
<!-- Memo for whoever picks up the next phase -->
```

## Commit format

```
docs: add dispatch brief for phase {phase}

Work order for Agent 2B covering [brief scope summary].

Non-goals: no code in this commit — brief only.

Co-Authored-By: Factory Workflow <noreply@factory-workflow>
```

## Rules
- Brief must be committed BEFORE any dev work starts
- All 8 sections are mandatory. Empty sections must still have headers.
- §1 non-goals is not optional — scope without non-goals is undefined
- §3 commit plan should have one row per logical change (not one giant commit)
- Reference PRD section numbers in §1 and §2, don't paraphrase
