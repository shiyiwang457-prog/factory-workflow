# Factory Workflow

A [gstack](https://github.com/anthropics/claude-code) skill that turns Claude Code into a **gate-enforced development pipeline** for commercial-grade software.

## What it does

4-agent pipeline with 14 quality gates. Files are authoritative, chat is ephemeral. Any new session can resume from file state alone.

```
Agent 1 (PM)        →  PRD + commercial decisions
     ↓
  [Gate 1]          →  PRD approved + LOCKED
     ↓
Agent 2A (Schema)   →  OpenAPI + migrations + two-tier drift check
     ↓
  [Gate 2]          →  Architecture review, 0 schema drift
     ↓
Agent 2B (Dev)      →  Code per dispatch brief (1 commit = 1 task)
     ↓
  [Gate 3]          →  QA (contract tests + pixel smoke + VLM visual)
     ��
  Ship              →  Tag + CHANGELOG + deploy
```

Each gate requires a **file artifact** in `docs/reviews/` to close. No artifact = BLOCKED.

## Install

### Into a specific project

```bash
# Clone this repo
git clone https://github.com/shiyiwang457-prog/factory-workflow.git /tmp/factory-workflow

# Copy into your project's skill directory
mkdir -p /path/to/your-project/.claude/skills/factory-workflow
cp /tmp/factory-workflow/SKILL.md /path/to/your-project/.claude/skills/factory-workflow/
cp -r /tmp/factory-workflow/templates /path/to/your-project/.claude/skills/factory-workflow/
```

### Globally (available in all projects)

```bash
git clone https://github.com/shiyiwang457-prog/factory-workflow.git ~/.claude/skills/factory-workflow
```

### Verify

Open Claude Code and type `/factory-workflow` — it should auto-detect your project state and route to the correct mode.

## Usage

```
/factory-workflow              # Auto-detect state → route to correct mode
/factory-workflow new project  # Bootstrap a new project
/factory-workflow resume       # Resume from file state in a new session
/factory-workflow gate 2       # Check Gate 2 evidence
```

The skill auto-detects 6 modes:

| Mode | Trigger | What happens |
|---|---|---|
| **BOOTSTRAP** | No CLAUDE.md | Creates project structure + CLAUDE.md |
| **RESUME** | Existing project | Reads files, reports status, waits for confirmation |
| **GATE_TRANSITION** | Closing a gate | Verifies artifact with `ls -la`, ACK or BLOCK |
| **PHASE_OPEN** | Starting dev work | Creates dispatch brief + gstack relevance check |
| **VARIANCE** | Deviation found | Routes to `/office-hours` or `/investigate` |
| **AUDIT** | 3 consecutive all-green | Forces gstack usage check |

## 14 Gates

| Gate | L1/L2 | What it checks |
|---|---|---|
| Gate 1 PRD | **L1** | PRD locked + walkthrough completed |
| Gate 1.5 Analytics | **L1** | Success metrics declared |
| Gate 2 Schema | L2 | OpenAPI aligned, 0 drift (two-tier check) |
| Gate 2.1 Auth | L2 | 100% auth coverage on paid routes |
| Gate 2.2 Contract | L2 | Contract tests pass |
| Gate 2.3 Pricing | L2 | Single pricing source, no drift |
| Gate 2.4 Brand | L2 | Brand guidelines verified |
| Gate 2.5 Money Surface | **L1** | PM approves money-touching paths |
| Gate 2.6 Phase Open | L2 | Dispatch brief committed + gstack check |
| Gate 3 Pixel Smoke | L2 | Cost-aware 3-step QA funnel |
| Gate Brand/UX | **L1** | Brand guidelines locked |
| Gate 3.5 Paywall | **L1** | PM approves paywall UX |
| Gate Ship | **L1** | PM approves release |
| Gate T+7 | **L1** | Post-ship metrics + retrospective |

**L1** = PM must personally approve. **L2** = fully automated.

## gstack Integration

Factory Workflow routes to these gstack skills at specific trigger points:

| Skill | When |
|---|---|
| `/office-hours` | PRD decisions, money surface, paywall, strategy |
| `/plan-eng-review` | Schema phase, brief creation/revision |
| `/qa` | RC pre-ship, smoke tests |
| `/ship` | Tag, release, deploy |
| `/investigate` | Unknown root cause, external dependency issues |
| `/retro` | Post-ship T+7, lesson extraction |

**Works without gstack too** — if a skill isn't available, the pipeline still runs with the rules embedded in SKILL.md. gstack just makes execution more standardized.

## Key Principles

1. **Files are authoritative** — Every decision persists in a committed file. Chat is disposable.
2. **No artifact = BLOCKED** — Gates check with `ls -la`. Missing file = can't proceed.
3. **1 commit = 1 concern** — Feature/doc/migration/refactor separated. Non-goals in every commit message.
4. **LOCKED = immutable** — PRD changes go through numbered Amendments, never in-place edits.
5. **Schema-First** — Two-tier drift check (field names + API paths) before any code.
6. **Smooth = suspicious** — 3 all-green passes trigger mandatory audit.
7. **PM reads no code** — STOP reports are translated to business language.

## Templates Included

| Template | Purpose |
|---|---|
| `CLAUDE.md.template` | Project CLAUDE.md with all workflow rules |
| `dispatch-brief.md.template` | 8-section dispatch brief for dev phases |
| `gate-artifact.md.template` | Gate evidence document structure |
| `stop-report.md.template` | PM-readable STOP report format |

## Origin

Built through real production use across multiple commercial projects. Every rule exists because its absence caused a documented failure. The rules are strict by design — loosening them recreates the problems they solved.

## License

MIT
