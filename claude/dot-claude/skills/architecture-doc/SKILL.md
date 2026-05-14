---
name: architecture-doc
description: "Use this skill at the start of a new project (or when adding a major subsystem) to produce an ARCHITECTURE.md through a structured interview. Trigger when the user says things like 'create ARCHITECTURE.md', 'help me design the architecture', 'we're starting a new project', 'document our system design', 'we need an architecture doc', or references an existing SPEC.md/PRD and wants the next layer of design. Also trigger when the user mentions ADRs, technical design docs, or wants to capture stack choices and tradeoffs. Do NOT use this for deep refactors of existing systems where an architecture already exists — use a refactor-focused workflow instead. Do NOT use for data-model-only design — use the data-model-doc skill for schemas."
---

# ARCHITECTURE.md generation via structured interview

## Overview

This skill produces a 1–2 page `ARCHITECTURE.md` that captures the major components, data flow, tech choices, and explicit tradeoffs of a new web application. It is the "second layer" doc — sits between `SPEC.md` (what we're building, for whom) and `DATA_MODEL.md` (schema details).

The output must be **decision-dense, not description-dense**. A good architecture doc tells a future reader (or future Claude session) *why* this stack was chosen, not just what it is.

## When to use

- New project kickoff, immediately after `SPEC.md` exists
- Adding a major new subsystem (e.g., a background-job tier, a new service)
- Re-architecting a portion of the system after a stack change

## When NOT to use

- Tiny CRUD apps where the architecture is "single Next.js app + Postgres" — write a 5-line note in CLAUDE.md instead
- After-the-fact documentation of an existing system — that's a different skill
- Pure data-model design — use `data-model-doc` skill

## Workflow

### Phase 1: Read what already exists

Before asking any questions, read these if they exist:

- `SPEC.md`, `PRD.md`, or any product-spec file
- `CLAUDE.md` or `AGENTS.md` for declared conventions
- `package.json` / `pyproject.toml` / equivalent for any existing stack signals
- The user's memory/preferences if available (stack preferences are often pre-declared)

State explicitly what you read and what you inferred. Example:
> "I read SPEC.md. Inferred: multi-tenant SaaS, B2B, async-heavy. I noticed you previously mentioned a preference for TanStack Start + Drizzle + Postgres in your project context — I'll assume that as a default unless you tell me otherwise."

### Phase 2: Interview, don't lecture

Use the AskUserQuestion tool. Ask about *the hard parts the user might not have considered* — not the obvious stuff. Cover these areas, but **skip any topic that's already settled** in SPEC.md or user context:

1. **Deployment target & cost model**
   - Where does this run? (Vercel / Render / Fly / Railway / self-host / on-prem)
   - Is cost predictability or autoscaling more important?
   - What's the budget ceiling for infra in year 1?

2. **Client topology**
   - Web-only, or web + native + API consumers?
   - SSR / SPA / hybrid? Streaming? Hydration sensitivity?
   - Mobile: native (Expo/RN), responsive web, or both?

3. **API style & shared types**
   - REST, tRPC, oRPC, GraphQL, RPC-ish?
   - Single API consumed by multiple clients, or per-client backends?
   - How is the type contract enforced across the boundary?

4. **Auth & multi-tenancy**
   - Single-tenant, multi-tenant pooled, or silo'd?
   - Auth provider (BetterAuth, Clerk, Auth.js, Cognito, hand-rolled)?
   - Session vs JWT vs bearer; SSO/OAuth needs?
   - Row-level vs schema-level vs database-level tenant isolation?

5. **Background work**
   - Do you need jobs at MVP, or can everything be inline?
   - If yes: queue/worker choice (pg-boss, BullMQ, Sidekiq, Celery, Inngest, Temporal)?
   - Cron/scheduled jobs?

6. **State & realtime**
   - Do you need realtime (websockets, SSE, Liveblocks, Convex)? At MVP or later?
   - Cache layer (Redis, in-memory, none)?
   - Search (Postgres FTS, Meilisearch, Typesense, Elastic)?

7. **External integrations**
   - Payments (Stripe / Paddle / Lemon)?
   - Email (Resend / Postmark / SES)?
   - File storage (S3 / R2 / local)?
   - Analytics / observability?

8. **Non-functional requirements**
   - Expected traffic at month 6 and month 24
   - Latency budget for the hot path
   - Compliance (SOC2, HIPAA, GDPR specifics)
   - Data residency

9. **Team & operational constraints**
   - Solo, small team, or growing?
   - Comfort with each candidate technology — bias toward what the user can debug at 2am
   - CI/CD preferences

**Interview principles:**

- Ask 2–4 questions per turn, not 15. Let the user breathe.
- When the user signals a preference, *don't re-ask*. Confirm it.
- Surface tradeoffs explicitly. "Render gives you predictable pricing but slower cold starts vs Vercel — which matters more for this app?"
- If the user is unsure, give them your recommendation with reasoning, and ask them to accept/reject.
- Push back when you see a smell. ("You picked GraphQL but the spec describes 3 endpoints — is that intentional?")

### Phase 3: Propose the architecture in plan mode

Before writing ARCHITECTURE.md, present a draft outline in the chat:

> "Based on your answers, here's what I'd propose. Confirm or correct before I write the doc:
> - Web: TanStack Start on Render
> - API: oRPC, shared with Expo client
> - DB: Postgres 16, Drizzle ORM
> - Jobs: pg-boss on Render worker dyno
> - Auth: BetterAuth, bearer tokens for mobile
> - Storage: S3-compatible (Cloudflare R2)
> - Realtime: deferred to v2
>
> Key tradeoffs I made:
> - Chose Render over Vercel for cost predictability
> - Skipped Redis because pg-boss + Postgres covers MVP needs
> - Skipped GraphQL because oRPC gives us OpenAPI for free
>
> Anything to change before I write the doc?"

### Phase 4: Write ARCHITECTURE.md

Use the template below. Keep it to 1–2 pages. **Every section must explain at least one tradeoff or "why," not just "what."**

## Template

```markdown
# Architecture

> Last updated: <YYYY-MM-DD>
> Related: [SPEC.md](./SPEC.md), [DATA_MODEL.md](./DATA_MODEL.md)

## System at a glance

<2–3 sentences. What kind of system this is, what shape it has,
who calls what. A future reader should understand the topology
from this paragraph alone.>

```
<Optional ASCII diagram. Keep it under 15 lines. Show the boxes
that matter — clients, API, DB, queue, external services.>

  [Web (TanStack Start)] ──┐
                            ├─▶ [oRPC API] ──▶ [Postgres]
  [Mobile (Expo)] ──────────┘         │
                                      └─▶ [pg-boss worker]
                                              │
                                              ▼
                                          [S3 / R2]
```

## Stack & versions

| Layer | Choice | Version | Why this over alternatives |
|---|---|---|---|
| Runtime | Node | 22 LTS | Long support; Bun not yet stable for our deps |
| Web | TanStack Start | latest | SSR + file routing + shared types with API |
| Mobile | Expo | SDK 53 | OTA updates, shared TS with web |
| API | oRPC | latest | OpenAPI generation; tRPC lacked it |
| DB | Postgres | 16 | RLS, JSONB, FTS in one engine |
| ORM | Drizzle | latest | Lightweight, SQL-shaped, no codegen issues |
| Auth | BetterAuth | latest | Bearer tokens for mobile out of the box |
| Jobs | pg-boss | latest | No Redis required at MVP |
| Storage | Cloudflare R2 | — | S3-compatible, no egress fees |
| Host | Render | — | Cost predictability over Vercel autoscale |

## Components

### Web client
<1–3 sentences. What runs in the browser, SSR vs CSR boundary, key constraints.>

### API
<1–3 sentences. Auth model, error format, versioning approach.>

### Worker tier
<1–3 sentences. What runs async, how jobs are enqueued, retry/visibility model.>

### Database
<1–3 sentences. Tenancy model, backup strategy, migration approach. Detail lives in DATA_MODEL.md.>

## Cross-cutting concerns

### Auth & sessions
<How auth flows for web vs mobile. Token storage. Refresh strategy.>

### Multi-tenancy
<Tenancy model and where it's enforced — middleware, RLS, app code.>

### Observability
<Logging, metrics, tracing choices. What's at MVP, what's deferred.>

### Errors
<Error contract across the API boundary. Problem Details / custom envelope / etc.>

### Secrets & config
<Where secrets live. 12-factor compliance. Local-dev story.>

## Environments

| Env | Host | DB | Notes |
|---|---|---|---|
| local | docker-compose | local Postgres | seed script in `scripts/seed.ts` |
| preview | Render preview | branched DB | per-PR |
| prod | Render | Postgres 16, daily snapshot | — |

## Out of scope for v1

<Bullet list of things we explicitly chose NOT to build now and the
trigger that would make us reconsider. Examples:>

- Realtime (websockets/SSE) — defer until we have a feature that demands it
- Redis cache — defer until p95 read latency degrades
- GraphQL — REST/oRPC sufficient for current clients
- Separate API service — monolith until 5+ engineers or 10× current traffic

## Open questions

<Bullet list of decisions we punted. Each should have a "decide by"
trigger or date.>

- Search infra: Postgres FTS to start. Reconsider if corpus > 1M rows or
  fuzzy/multilingual needs emerge.
- Email deliverability: Resend at MVP. Move to Postmark if we hit transactional
  volume issues.
```

## Style rules

- **Tradeoffs are mandatory.** If a section can't say "we chose X over Y because Z," it's too thin — push harder in the interview.
- **No marketing language.** Not "modern," "scalable," "best-in-class." Either it solves a stated requirement or it doesn't.
- **Version-pin everything in the stack table.** "Latest" is acceptable for fast-moving libs, but Node/runtime/DB must be exact.
- **"Why this over alternatives" is the most important column.** It documents the road not taken.
- **The "Out of scope" section is load-bearing.** It prevents Claude (and future-you) from accidentally building deferred features.
- **Open questions get explicit triggers** — "decide by date X" or "reconsider when condition Y."

## Common failure modes to avoid

- Writing it before SPEC.md is stable — you'll churn
- Description-only: listing what's in the stack with no "why"
- Marketing tone: "modern," "scalable," "battle-tested"
- 5-page docs nobody reads. Hard ceiling: 2 pages
- ASCII diagram with 30 boxes — limit to the top-level topology
- Mixing in data-model details — those go in DATA_MODEL.md
- Stating preferences as facts ("we use Render") without the "why" — that's how you get re-litigated decisions six months later

## Handoff

Once ARCHITECTURE.md is written and the user confirms:

1. Suggest the user commit it: `git add docs/ARCHITECTURE.md && git commit -m "docs: initial architecture"`
2. Suggest adding an `@docs/ARCHITECTURE.md` import to CLAUDE.md
3. Suggest the next step is `DATA_MODEL.md` (use the `data-model-doc` skill)
