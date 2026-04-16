# Factory Workflow — Project Status

Show a comprehensive, PM-readable status of the current project.

**Scope (optional, e.g., "gates only" or "full")**: $ARGUMENTS

## Gather data

Run these in parallel:

```bash
# Git state
git log --oneline -10
git status --short
git tag -l "v*" --sort=-version:refname | head -5

# Documents
ls -la docs/prd/PRD_v*.md 2>/dev/null
ls -la docs/dispatch/agent2b-v*.md 2>/dev/null
ls -la docs/reviews/ 2>/dev/null
ls -la docs/openapi_v*.yaml 2>/dev/null

# Current brief progress
# (read the latest brief's §6 if it exists)
```

## Report format

```
## Project Status

### Version
Current: {latest tag or "no release yet"}
Working on: {version from latest brief}

### Pipeline Position
Agent 1 (PM):     {DONE / IN_PROGRESS / NOT_STARTED}
Agent 2A (Schema): {DONE / IN_PROGRESS / NOT_STARTED}
Agent 2B (Dev):    {DONE / IN_PROGRESS / NOT_STARTED} — Phase {X}
Agent 3 (QA):      {DONE / IN_PROGRESS / NOT_STARTED}

### Gates
| Gate | Status | Evidence |
|---|---|---|
| Gate 1 (PRD) | {PASS/BLOCKED/N/A} | {path or "missing"} |
| Gate 2 (Schema) | {PASS/BLOCKED/N/A} | {path or "missing"} |
| Gate 3 (QA) | {PASS/BLOCKED/N/A} | {path or "missing"} |
| Gate Ship | {PASS/BLOCKED/N/A} | {path or "missing"} |

### Current Phase Progress
{table from brief §6, or "no active brief"}

### Open Decisions
{from brief §7, or "none"}

### Recent Commits
{last 5 commits, one line each}
```

Do NOT editorialize. Report facts from files. If something is missing, say "missing" — don't guess.
