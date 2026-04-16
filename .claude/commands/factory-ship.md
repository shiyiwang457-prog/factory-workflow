# Factory Workflow — Ship

Ship the current version: update CHANGELOG, create git tag, prepare release.

**Version to ship** (e.g., "v1.0.0"): $ARGUMENTS

## Pre-ship checklist

Before shipping, verify ALL gates are closed:

```bash
# Gate 1: PRD locked
ls -la docs/prd/PRD_v*.md
grep -l "STATUS: LOCKED" docs/prd/PRD_v*.md

# Gate 2: Schema aligned
ls -la docs/openapi_v*.yaml docs/reviews/plan-eng-review-v*.md

# Gate 3: QA passed
ls -la docs/reviews/qa-v*-rc.md
grep "QA_PASS" docs/reviews/qa-v*-rc.md
```

If ANY gate artifact is missing → STOP. Report which gate is BLOCKED.

## Ship steps

### 1. Update CHANGELOG.md
Add a new version section with:
- Date
- Summary of changes (from dispatch brief §6 progress records)
- Breaking changes (if any)
- Non-goals for this release

### 2. Create ship review
Write `docs/reviews/ship-v{version}.md`:
```markdown
# Ship Review — v{version}

Date: {date}
Gate 1 (PRD): PASS — {artifact path}
Gate 2 (Schema): PASS — {artifact path}
Gate 3 (QA): PASS — {artifact path}

## Changes included
{summary from CHANGELOG}

## Known limitations
{from PRD non-goals + amendment deferrals}

## Rollback plan
{how to revert if something breaks}
```

### 3. Commit
```
docs: ship review + changelog for v{version}

Non-goals: no code changes, no tag yet (user confirms first).

Co-Authored-By: Factory Workflow <noreply@factory-workflow>
```

### 4. Present to user for approval
Show:
- CHANGELOG diff
- Ship review summary
- Gate evidence (`ls -la docs/reviews/`)
- Proposed tag: `v{version}`

**Wait for user approval before creating the tag.**

### 5. After user approves
```bash
git tag -a v{version} -m "Release v{version}

{one-line summary}

Ship review: docs/reviews/ship-v{version}.md"
```

Report:
```
Shipped v{version}.
Tag: git show v{version}
CHANGELOG: cat CHANGELOG.md
Ship review: docs/reviews/ship-v{version}.md

Remote push not done — run `git push origin main --tags` when ready.
```

## Rules
- Do NOT create the tag without user approval
- Do NOT push to remote — user decides when
- Do NOT ship if any gate is BLOCKED
- CHANGELOG must include non-goals for the release
