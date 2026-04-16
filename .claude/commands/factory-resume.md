# Factory Workflow — Resume Session

Resume work on this project from file state. This is the **new window recovery protocol**.

**Context (optional, e.g., "phase v1.2.B")**: $ARGUMENTS

## What to do

Read these sources in order. Do NOT skip any.

### 1. Git state
```bash
git log --oneline -12
git status
git diff --stat HEAD~3..HEAD
```

### 2. Current dispatch brief
Find the latest brief:
```bash
ls -lt docs/dispatch/agent2b-v*.md | head -3
```
Read it fully — focus on:
- §6 Progress Record (what's done, what's pending)
- §7 Pending Variance Requests (open decisions)
- §8 Handoff notes from prior phase

### 3. Amendments
```bash
ls docs/prd/PRD_v*_AMENDMENTS.md
```
Read all amendments — they override the original PRD.

### 4. PRD
Read the latest LOCKED PRD for context on the overall requirements.

### 5. Gate evidence
```bash
ls -la docs/reviews/
```
Check which gates have evidence artifacts.

### 6. CHANGELOG
Read `CHANGELOG.md` for what's already shipped.

## Report format

After reading everything, report in this EXACT structure:

```
## Resume Report

### Last commit
{hash} — {message}

### Current phase
{phase identifier from dispatch brief}

### Completed
- {list of done items from §6}

### Pending
- {list of pending items from §6}

### Open decisions
- {list from §7, if any}

### Gate status
- Gate 1: {PASS/BLOCKED/N/A}
- Gate 2: {PASS/BLOCKED/N/A}
- Gate 3: {PASS/BLOCKED/N/A}

### Proposed next step
{what you think should happen next, with rationale}
```

## Rules
- Do NOT start working until the user confirms the next step
- Do NOT make assumptions about what happened in prior sessions — read the files
- If the dispatch brief's §6 shows incomplete work, propose resuming from the last DONE row
- If there's no dispatch brief, suggest running `/factory-dispatch` first
