# Dispatch Brief: Agent 2B — Phase {PHASE}

**Created**: {date}
**PRD**: docs/prd/PRD_v{ver}.md
**OpenAPI**: docs/openapi_v{ver}.yaml
**Architecture Review**: docs/reviews/plan-eng-review-v{ver}.md

---

## §0 Gate Evidence Ledger

> Append one line per gate closure. `ls` output is proof.

| Gate | Artifact | ls output | Date |
|---|---|---|---|

## §1 Scope

### Must Ship
- {FR-xxx}: {description, reference PRD section}

### Non-Goals (this phase)
- {What this phase deliberately does NOT include}

### Boundaries
- {What's in scope vs. out of scope for this specific phase}

## §2 Hard Constraints

| # | Constraint | Source |
|---|---|---|
| 1 | {constraint description} | PRD §{X} |
| 2 | {constraint description} | BRAND §{Y} |
| 3 | {constraint description} | Amendment #{Z} |

## §3 Commit Plan

| # | Commit Message | Files Changed | DoD |
|---|---|---|---|
| 1 | `feat: {description}` | `src/...` | {how to verify} |
| 2 | `test: {description}` | `tests/...` | {test passes} |
| 3 | `docs: {description}` | `docs/...` | {file exists} |

## §4 DoD Checklist

- [ ] All commits from §3 landed
- [ ] Two-tier drift check passes (0 drift)
- [ ] All tests pass
- [ ] Negative assertions have positive preconditions
- [ ] `grep -r "TODO" src/` = 0 uncommitted TODOs
- [ ] No hardcoded secrets in committed code

## §5 Escalation Triggers

Stop and ask the user (do NOT decide alone) when:
- {Scope ambiguity not resolvable from PRD + amendments}
- {Performance concern not covered in architecture review}
- {External dependency unavailable or rate-limited}
- {Any LOCKED document needs modification}

## §6 Progress Record

> Agent 2B appends here after each commit.

| Step | Commit | Status | Notes |
|---|---|---|---|

## §7 Pending Variance Requests

> Log PRD deviations discovered during work. Mark RESOLVED when amendment is approved.

| # | Description | Status | Resolution |
|---|---|---|---|

## §8 Next Phase Handoff Notes

> Memo for whoever picks up the next phase.

{Leave blank until phase is complete.}
