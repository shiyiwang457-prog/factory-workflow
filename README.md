# Factory Workflow

A structured development methodology for [Claude Code](https://claude.ai/claude-code) that turns AI pair programming into a repeatable, gate-enforced pipeline.

**The problem**: AI coding assistants are powerful but chaotic. Without structure, they skip steps, mix concerns in commits, drift from requirements, and produce work that's hard to resume across sessions.

**The solution**: Factory Workflow enforces a 4-agent pipeline with 3 quality gates, file-authoritative state, and strict commit discipline. Every decision is tracked in files, every gate requires evidence artifacts, and any new session can resume from file state alone.

## How it works

```
Agent 1 (PM)        →  Write PRD (requirements + non-goals + metrics)
      ↓
   [Gate 1]         →  PRD approved + LOCKED
      ↓
Agent 2A (Schema)   →  OpenAPI contract + DB migrations + drift check
      ↓
   [Gate 2]         →  Architecture review passes, 0 schema drift
      ↓
Agent 2B (Dev)      →  Implement code (per dispatch brief, one commit per task)
      ↓
   [Gate 3]         →  QA verification (contract tests + smoke tests)
      ↓
   Ship             →  Tag + CHANGELOG + release
```

Each gate requires a **file artifact** to close. No artifact = gate blocked = can't proceed.

## Quick start

### Option 1: Install to a project

```bash
git clone https://github.com/user/factory-workflow.git /tmp/factory-workflow
cd /path/to/your-project
/tmp/factory-workflow/install.sh .
```

This copies slash commands, templates, and creates the docs/ structure.

### Option 2: Install globally

```bash
git clone https://github.com/user/factory-workflow.git /tmp/factory-workflow
/tmp/factory-workflow/install.sh --global
```

Commands become available in all Claude Code sessions.

### Option 3: Manual

Copy `.claude/commands/factory-*.md` to your project's `.claude/commands/` directory.

## Commands

| Command | Phase | What it does |
|---|---|---|
| `/factory-init <name>` | Setup | Create project structure + CLAUDE.md |
| `/factory-prd` | Agent 1 | Write and lock the PRD |
| `/factory-schema` | Agent 2A | Design OpenAPI + migrations + drift check |
| `/factory-dispatch <phase>` | Planning | Create dispatch brief for a dev phase |
| `/factory-dev <phase>` | Agent 2B | Implement code per dispatch brief |
| `/factory-qa` | Agent 3 | Independent QA verification |
| `/factory-gate [gate]` | Audit | Check gate evidence artifacts |
| `/factory-resume` | Recovery | Resume from file state in a new session |
| `/factory-ship <version>` | Release | CHANGELOG + tag + ship review |
| `/factory-status` | Info | PM-readable project status |

## Core principles

### 1. Files are authoritative, chat is ephemeral
Every decision, requirement, and progress record lives in a committed file. Chat messages are disposable. Any new Claude session can recover full context from files alone.

### 2. Gates require evidence
Each gate transition needs a file artifact to exist (`docs/reviews/*.md`). The system checks with `ls -la` — if the file isn't there, the gate is blocked.

### 3. One commit = one concern
Features, docs, migrations, and refactors get separate commits. Every commit is independently revertable. Commit messages include non-goals (what was deliberately excluded).

### 4. LOCKED documents are immutable
Once a PRD or brand guideline is LOCKED, it's never edited in place. Changes go through numbered Amendments or versioned copies.

### 5. Schema-First
Database migrations and API contracts are designed before implementation code. A two-tier drift check (field names + API paths) must pass before dev starts.

## Project structure (after init)

```
your-project/
├── .claude/commands/        ← Slash commands
│   ├── factory-init.md
│   ├── factory-prd.md
│   ├── factory-schema.md
│   ├── factory-dispatch.md
│   ├── factory-dev.md
│   ├── factory-qa.md
│   ├── factory-gate.md
│   ├── factory-resume.md
│   ├── factory-ship.md
│   └── factory-status.md
├── docs/
│   ├── prd/                 ← PRD + amendments
│   ├── brand/               ← Brand guidelines
│   ├── dispatch/            ← Work orders for Agent 2B
│   ├── reviews/             ← Gate evidence artifacts
│   └── openapi_v*.yaml      ← API contract
├── hooks/
│   └── gate-check.sh        ← Optional: blocks edits without gate evidence
├── templates/               ← Document templates
├── CLAUDE.md                ← Project rules (auto-loaded every session)
└── CHANGELOG.md
```

## The CLAUDE.md (most important file)

The `CLAUDE.md` at your project root is loaded into **every** Claude Code conversation. It contains:

- The 5 invariants (hard rules Claude must follow)
- Gate evidence requirements
- Commit discipline rules
- Dispatch brief format (8 mandatory sections)
- Resume ritual (how to recover in a new session)
- Code execution rules (concurrency, negative assertions, inherited code)

This is what makes "the same effect for everyone" possible — the rules are enforced by prompt, not by human memory.

## Optional: Gate-check hook

Enable the hook to block source file edits when gate evidence is missing:

```json
// .claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "command": "./hooks/gate-check.sh"
    }]
  }
}
```

Set `FACTORY_GATE_MODE=advisory` for warnings instead of blocks.

## Typical workflow

```bash
# 1. Initialize
/factory-init my-saas-app

# 2. Write requirements
/factory-prd
# → produces docs/prd/PRD_v1.0.md (LOCKED)

# 3. Design schema
/factory-schema
# → produces docs/openapi_v1.0.yaml + architecture review

# 4. Plan dev work
/factory-dispatch v1.0.A
# → produces docs/dispatch/agent2b-v1.0.A.md

# 5. Implement
/factory-dev v1.0.A
# → code commits, one per task, brief §6 updated

# 6. Verify
/factory-qa
# → produces docs/reviews/qa-v1.0-rc.md

# 7. Ship
/factory-ship v1.0.0
# → CHANGELOG + tag + ship review

# --- New session? ---
/factory-resume
# → reads all files, reports status, waits for confirmation
```

## Design philosophy

This workflow was developed through real production use across multiple commercial projects. Every rule exists because its absence caused a specific, documented failure:

- **Gate evidence** exists because gates were rubber-stamped when there was nothing to check
- **Dispatch briefs as files** exist because chat-based instructions were lost when sessions ended
- **Non-goals in commits** exist because scope creep was invisible without explicit exclusion
- **Amendment numbering with grep** exists because stale references caused numbering collisions
- **Two-tier drift check** exists because single-tier checks missed API-level mismatches

The rules are strict by design. Loosening them recreates the problems they solved.

## License

MIT
