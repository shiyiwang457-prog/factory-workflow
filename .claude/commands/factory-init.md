# Factory Workflow — Initialize Project

Initialize a new project with the Factory Workflow structure.

**Project name or path**: $ARGUMENTS

## Your task

1. **Determine project location**:
   - If `$ARGUMENTS` is an absolute path, use it
   - If `$ARGUMENTS` is a project name, create at the current working directory
   - If the directory doesn't exist, create it

2. **Create the directory structure**:
   ```
   <project>/
   ├── docs/
   │   ├── prd/
   │   ├── brand/
   │   ├── dispatch/
   │   └── reviews/
   ├── CHANGELOG.md
   └── CLAUDE.md
   ```

3. **Copy the CLAUDE.md template** from this repo's `templates/CLAUDE.md` into the project root. If the template isn't accessible, use the Factory Workflow CLAUDE.md content that enforces the 5 invariants, gate evidence, commit discipline, dispatch brief format, and resume ritual.

4. **Create initial CHANGELOG.md**:
   ```markdown
   # Changelog

   All notable changes to this project will be documented in this file.

   ## [Unreleased]
   - Project initialized with Factory Workflow
   ```

5. **Initialize git** if not already a git repo:
   ```bash
   git init
   git add -A
   git commit -m "chore: initialize project with Factory Workflow structure

   - docs/prd/, docs/brand/, docs/dispatch/, docs/reviews/ directories
   - CLAUDE.md with Factory Workflow rules (5 invariants, gate evidence, commit discipline)
   - CHANGELOG.md

   Non-goals: no PRD yet, no code yet, no CI — those come in subsequent phases.

   Co-Authored-By: Factory Workflow <noreply@factory-workflow>"
   ```

6. **Report to user**:
   - Confirm directory path and structure with `ls -R`
   - State: "Project scaffolding complete. Next step: run `/factory-prd` to start the PRD phase (Agent 1)."
   - Do NOT start writing the PRD — wait for the user to invoke the next command

## Rules
- Do not create any code directories yet — that's Agent 2B's job
- Do not create PRD or ARCHITECTURE — those come from `/factory-prd` and `/factory-schema`
- Do not push to remote — user decides when
