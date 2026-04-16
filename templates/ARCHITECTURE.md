# Architecture — {PROJECT_NAME}

**Version**: {version}
**Date**: {date}
**Status**: DRAFT / LOCKED

---

## Overview

{High-level description of the system architecture. What are the major components and how do they interact?}

## System Diagram

```
{ASCII diagram of components and their connections}
```

## Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Frontend | {e.g., React, Next.js} | {why this choice} |
| Backend | {e.g., Flask, FastAPI} | {why} |
| Database | {e.g., PostgreSQL, SQLite} | {why} |
| Auth | {e.g., JWT, session-based} | {why} |
| Hosting | {e.g., Fly.io, Vercel} | {why} |

## Data Model

{Key entities and their relationships. Reference `docs/openapi_v*.yaml` for the full schema.}

## API Design

{Overview of API structure. Reference `docs/openapi_v*.yaml` for endpoints.}

## Security

- Authentication: {approach}
- Authorization: {approach}
- Data protection: {approach}

## Performance Considerations

- {Expected load}
- {Caching strategy}
- {Known bottlenecks}

## Deployment

- {Environment setup}
- {CI/CD pipeline}
- {Rollback procedure}

## Decision Log

| # | Decision | Rationale | Date | Alternatives Considered |
|---|---|---|---|---|
| D-001 | {decision} | {why} | {date} | {what else was considered} |
