# Factory Workflow — Gate Check

Check whether a gate's required artifacts exist and the gate can be closed.

**Gate to check** (e.g., "gate-1", "gate-2", "gate-3", "gate-ship", or "all"): $ARGUMENTS

## Gate Evidence Table

Check each gate's required artifacts:

### Gate 1 — PRD Lock
```bash
ls -la docs/prd/PRD_v*.md
grep -l "STATUS: LOCKED" docs/prd/PRD_v*.md
ls -la docs/prd/PRD_v*_AMENDMENTS.md
```
- [ ] PRD exists and is LOCKED
- [ ] Amendments file exists

### Gate 2 — Schema Pass
```bash
ls -la docs/openapi_v*.yaml
ls -la docs/reviews/plan-eng-review-v*.md
```
- [ ] OpenAPI spec exists
- [ ] Architecture review exists
- [ ] Drift check passes (two-tier: components + paths)

### Gate 2.6 — Dev Start
```bash
ls -la docs/dispatch/agent2b-v*.md
```
- [ ] Dispatch brief exists and is committed
- [ ] Brief has all 8 sections

### Gate 3 — QA Pass
```bash
ls -la docs/reviews/qa-v*-rc.md
grep "QA_PASS\|QA_FAIL" docs/reviews/qa-v*-rc.md
```
- [ ] QA report exists
- [ ] Verdict is QA_PASS
- [ ] Smoke test scripts are committed

### Gate Ship
```bash
ls -la docs/reviews/ship-v*.md
ls -la CHANGELOG.md
git tag -l "v*"
```
- [ ] Ship review exists
- [ ] CHANGELOG.md updated
- [ ] Git tag created

## Output format

For each gate, report:
```
Gate {N}: {PASS / BLOCKED / NOT_APPLICABLE}
  Evidence: {ls output}
  Missing: {what's missing, if any}
```

If any gate is BLOCKED, state what action is needed to unblock it.

## Audit trigger

If the last 3 gates all passed without any issues, flag this:
```
⚠️ AUDIT: 3 consecutive clean passes. Verify this isn't rubber-stamping.
Check: have all relevant review artifacts been actually read and verified?
```
