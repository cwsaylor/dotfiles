---
name: data-model-doc
description: "Use this skill at the start of a new project, or when adding a major new entity/aggregate, to produce a DATA_MODEL.md through a structured interview. Trigger when the user says things like 'create DATA_MODEL.md', 'design the schema', 'help me model the data', 'we need to figure out the database', 'design the tables for X', 'plan the schema before migrations', or references an existing SPEC.md/ARCHITECTURE.md and wants to design the data layer next. Also trigger when the user wants to discuss tradeoffs between first-class fields vs JSON columns, normalization choices, or wants to enumerate query patterns before writing migrations. Do NOT use this skill to write actual migration code — this skill produces the design doc only; migrations come after, in a separate session. Do NOT use for one-off schema tweaks to an established model — those just get a migration directly."
---

# DATA_MODEL.md generation via structured interview

## Overview

This skill produces a 1–2 page `DATA_MODEL.md` that defines entities, relationships, naming conventions, key indexes, and the rationale for first-class fields vs JSON columns. It is the single source of truth that migration files are generated *from*, in a separate later session.

**Critical principle:** The schema is human-curated. Migrations are AI-generated. Both are reviewed. This skill produces the human-curated part.

The doc must capture **decisions and query patterns**, not just a table list. A future reader (or future Claude session writing the next migration) needs to know *why* a field is denormalized, *why* an index exists, and *which queries the model is optimized for*.

## When to use

- New project, immediately after `ARCHITECTURE.md` is settled
- Adding a major new aggregate (e.g., billing, audit log, multi-tenant boundary) that touches multiple tables
- Re-modeling a portion of the schema after a significant requirement change

## When NOT to use

- Single-column additions or simple migrations — write the migration directly
- After-the-fact reverse-engineering of an existing DB — different skill
- Architecture-level questions about the data layer (e.g., "should we shard?") — that's `architecture-doc`

## Workflow

### Phase 1: Read what already exists

Before any questions, read:

- `SPEC.md` — entities mentioned, relationships described
- `ARCHITECTURE.md` — DB engine, ORM, tenancy model
- `CLAUDE.md` / `AGENTS.md` — any naming conventions already declared
- The user's memory/preferences for stack/ORM signals

Explicitly state what you found. Example:
> "From SPEC.md I see these entities mentioned: User, Project, Page, Task, File. From ARCHITECTURE.md: Postgres 16 + Drizzle, pooled multi-tenancy. I'll assume snake_case columns and plural table names unless you say otherwise."

### Phase 2: Interview

Use the AskUserQuestion tool. Drive these in order — earlier answers constrain later ones.

**Round 1 — Naming and base conventions**

- Confirm case style: snake_case columns + plural snake_case tables (Postgres default) vs camelCase + singular (some Mongo-ish habits)
- Primary key strategy: UUID v7 (sortable, no enumeration), UUID v4 (random), bigint identity, ULID, nanoid, snowflake — what tradeoff matters most?
- Soft-delete or hard-delete? If soft, on which tables specifically?
- Audit columns: `created_at`, `updated_at` everywhere? `created_by`, `updated_by`? `version` for optimistic locking?
- Timestamp type: `timestamptz` (Postgres recommendation) or `timestamp`?

**Round 2 — Tenancy boundary**

- If multi-tenant: where does `tenant_id` (or `workspace_id`, `org_id`) live? On every row of every tenant-scoped table, or just at aggregate roots?
- Enforced where: RLS, app middleware, both?
- Cross-tenant tables (e.g., users that belong to multiple orgs) — modeled as join table or duplicated rows?

**Round 3 — Enumerate the entities**

Walk the user through each entity from SPEC.md. For each, ask:

- What identifies it? (Just `id`, or natural key like `slug`?)
- Owning relationship? (Belongs to user / project / tenant?)
- What's the *expected cardinality*? (10 rows, 10K rows, 10M rows? Affects index choices.)
- What's its lifecycle? (Created once and immutable? Frequently updated? TTL?)

**Round 4 — Relationships and edges**

For each relationship:

- 1:1, 1:N, or N:N?
- Required (NOT NULL FK) or optional?
- ON DELETE behavior: cascade, restrict, set null, set default?
- For N:N: does the join table carry any data of its own? (If yes, give it a proper name, not `<a>_<b>`.)

**Round 5 — Query patterns (the most important round)**

This round is what separates a good data model from a bad one. Ask the user:

> "Tell me the 5–10 queries this app will run most often. Not the writes — the reads. Think about list views, dashboards, search, and any 'show me X for user Y' patterns."

Then for each query, work out:

- Which tables it touches
- What it filters by (→ candidate indexes)
- What it sorts by (→ index ordering)
- Is it paginated? (→ cursor-friendly index)
- How often it runs and how fast it needs to be

This is where you discover that you need a composite index on `(workspace_id, status, created_at DESC)` instead of three separate single-column indexes.

**Round 6 — First-class vs JSON, ruthlessly**

For every candidate `jsonb` / `json` column, force these answers:

- Will any production query filter, sort, or aggregate on a key inside this?
- Will the application code ever read individual keys directly?
- Is the shape stable across rows (same keys, same types)?

**If yes to any → promote to first-class columns.** JSON is only for genuinely free-form, user-supplied, never-queried payload (e.g., a settings blob the app round-trips opaquely, or an audit-log event payload).

Push back when the user (or your own draft) reaches for JSON out of laziness. Examples of bad JSON usage to catch:

- "We'll put status in metadata" → no, `status` is an enum column
- "We'll put tags in a JSON array" → no, that's a `tags` table or a Postgres `text[]` column with a GIN index
- "We'll put feature flags per user in JSON" → no, that's a `feature_flags` table

**Round 7 — Enums, lookups, and constants**

- Postgres `CREATE TYPE ... AS ENUM` vs lookup table vs CHECK constraint?
- Default position: small fixed sets → Postgres enum; user-extendable sets → lookup table; truly free-form → text + check constraint
- Discuss enum migration pain (Postgres makes adding values easy, removing/reordering hard) so the user makes an informed choice

**Round 8 — Special-purpose columns**

- Money: always `numeric(N,2)` with an explicit currency column. Never `float`. Confirm precision.
- Time-of-day vs date vs timestamp — distinguish carefully.
- Geo: PostGIS or just lat/lng pair?
- Search: which fields participate in FTS? `tsvector` column with a trigger or generated column?
- Vector/embeddings: `pgvector` extension, dimensions, index type (HNSW/IVFFlat)?

### Phase 3: Propose the model in plan mode

Before writing DATA_MODEL.md, summarize the design in the chat:

> "Here's what I'd propose. Confirm or correct before I write the doc:
>
> **Entities** (8): users, workspaces, workspace_members, projects, pages, tasks, files, audit_events
>
> **Naming**: snake_case + plural; PKs are UUID v7; FKs are `<table>_id`; soft-delete via `deleted_at` on projects/pages/tasks only
>
> **Tenancy**: `workspace_id` denormalized onto every tenant-scoped table for RLS efficiency
>
> **Notable decisions**:
> - tasks.metadata is jsonb (genuinely free-form per integration)
> - tasks.status is a Postgres enum, not a string
> - files.size_bytes is `bigint`, not `int`
> - audit_events.payload is jsonb (intentionally schemaless)
>
> **Critical indexes**:
> - pages: (workspace_id, project_id, position) for ordered display
> - tasks: (workspace_id, assignee_id, status, due_date) for "my open tasks" view
> - audit_events: (workspace_id, created_at DESC) for log views
>
> **Deferred**: full-text search on pages content (add when corpus > 1K pages)
>
> Anything to change?"

### Phase 4: Write DATA_MODEL.md

Use the template below. Keep it to 1–2 pages — detail without bloat.

## Template

```markdown
# Data model

> Last updated: <YYYY-MM-DD>
> Engine: PostgreSQL 16
> ORM: Drizzle
> Related: [ARCHITECTURE.md](./ARCHITECTURE.md)

## Conventions

- **Case:** snake_case columns, plural snake_case tables (e.g., `workspace_members`)
- **Primary keys:** UUID v7 (sortable, time-prefixed); column name `id`
- **Foreign keys:** `<referenced_table_singular>_id` (e.g., `workspace_id` references `workspaces.id`)
- **Timestamps:** `timestamptz`; every table has `created_at`, mutable tables also have `updated_at`
- **Soft delete:** `deleted_at timestamptz NULL` on entities the user can "delete" but we retain
- **Money:** `numeric(12, 2)` + adjacent `currency char(3)` (ISO 4217)
- **Booleans:** `is_<state>` or `has_<state>` (`is_archived`, `has_paid`); never just `<state>` if ambiguous
- **Enums:** Postgres `CREATE TYPE` for fixed sets; lookup tables for extensible sets
- **JSON:** `jsonb`, only for genuinely free-form payloads; never as a catch-all for known fields

## Tenancy model

<2–3 sentences. Where workspace_id lives, how it's enforced (RLS / middleware / both),
how cross-tenant rows are handled.>

## Entities

### users
Authentication identity. Lives outside the tenancy boundary; joined to workspaces via `workspace_members`.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | uuid | PK, default uuidv7() | |
| email | citext | NOT NULL UNIQUE | citext for case-insensitive uniqueness |
| email_verified_at | timestamptz | NULL | |
| name | text | NOT NULL | |
| created_at | timestamptz | NOT NULL default now() | |
| updated_at | timestamptz | NOT NULL default now() | |

**Indexes:** UNIQUE(email) implicit from constraint.

**Notes:** No `password_hash` — auth provider (BetterAuth) owns credentials in its own tables.

---

### workspaces
Tenant root. Everything tenant-scoped has `workspace_id` denormalized.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | uuid | PK, default uuidv7() | |
| slug | text | NOT NULL UNIQUE | URL component, lowercased |
| name | text | NOT NULL | display name |
| plan | workspace_plan (enum) | NOT NULL default 'free' | enum: free/pro/team |
| created_at | timestamptz | NOT NULL default now() | |

**Indexes:** UNIQUE(slug) implicit.

---

### projects
Belongs to workspace. Soft-deletable.

| Column | Type | Constraints | Notes |
|---|---|---|---|
| id | uuid | PK | |
| workspace_id | uuid | NOT NULL FK → workspaces(id) ON DELETE CASCADE | denormalized for RLS |
| name | text | NOT NULL | |
| position | int | NOT NULL default 0 | for ordering in sidebar |
| deleted_at | timestamptz | NULL | soft delete |
| created_at, updated_at | timestamptz | NOT NULL | |

**Indexes:**
- `(workspace_id, deleted_at, position)` — sidebar query
- `(workspace_id)` — FK index (redundant with above but kept for clarity)

---

<... continue for each entity, in roughly creation order of dependencies ...>

## Relationships at a glance

```
users ──< workspace_members >── workspaces ──< projects ──< pages
                                     │             │
                                     └──< files    └──< tasks ──> users (assignee)
```

## Query patterns this model is optimized for

| # | Query | Tables | Index used |
|---|---|---|---|
| 1 | List projects in sidebar | projects | `(workspace_id, deleted_at, position)` |
| 2 | "My open tasks" view | tasks | `(workspace_id, assignee_id, status, due_date)` |
| 3 | Recent activity feed | audit_events | `(workspace_id, created_at DESC)` |
| 4 | Page tree for project | pages | `(workspace_id, project_id, parent_id, position)` |
| 5 | Workspace member list | workspace_members + users | `(workspace_id)` + join |

## Critical indexes (beyond FK auto-index)

| Table | Index | Reason |
|---|---|---|
| tasks | `(workspace_id, assignee_id, status, due_date)` | "my open tasks" composite |
| audit_events | `(workspace_id, created_at DESC)` | log pagination |
| pages | `(workspace_id, project_id, parent_id, position)` | tree rendering |

**Rule:** every FK gets an index. Composite indexes listed above are *additional*.

## Enums

```sql
CREATE TYPE workspace_plan AS ENUM ('free', 'pro', 'team');
CREATE TYPE task_status   AS ENUM ('open', 'in_progress', 'done', 'archived');
```

Postgres enum tradeoffs: adding values is cheap, removing/reordering is painful.
When in doubt, use a lookup table.

## JSON columns (justified)

| Table.column | Why JSON | Example payload |
|---|---|---|
| tasks.integration_meta | Per-integration shape, never queried | `{"github": {"issue_id": 42}}` |
| audit_events.payload | Schemaless by design (event-shape varies) | `{"before": {...}, "after": {...}}` |

Everything else is first-class.

## Deferred / open questions

- **Full-text search on pages.content** — defer until corpus > 1K pages; revisit with `tsvector` generated column + GIN
- **Embeddings/vector search** — defer until we have an AI search feature spec
- **Multi-currency on workspaces** — currently single currency per workspace; revisit if we sell internationally
- **Hard-delete retention policy** — soft-deleted rows currently live forever; add a cleanup job at 90 days when storage matters
```

## Anti-patterns to catch and call out

When interviewing or reviewing, watch for and push back on:

1. **Catch-all `metadata jsonb`** — almost always wrong. Promote known keys to columns.
2. **Booleans/enums hidden in JSON** — `metadata->>'is_archived'` is unindexable; make it a column.
3. **Float for money** — always `numeric`. No exceptions.
4. **`timestamp` instead of `timestamptz`** in Postgres — silent timezone bugs.
5. **`varchar(255)`** — use `text` in Postgres unless there's a real domain reason for a limit. There's no perf difference.
6. **FK without index** — Postgres does NOT auto-index FK columns. The migration must add one.
7. **No `ON DELETE` specified** — defaults to NO ACTION, which throws errors at runtime. Be explicit.
8. **Pluralization drift** — `user` vs `users`, `category` vs `categories`. Pick one rule (plural) and enforce.
9. **camelCase columns in Postgres** — requires constant double-quoting. Use snake_case.
10. **Mixing tenant boundary** — denormalize `workspace_id` onto every tenant-scoped table or risk slow joins for RLS.
11. **Cascading deletes everywhere** — cascade is appropriate for owned children, not for shared references. Think before defaulting.
12. **`status` as a free-form string** — always an enum or lookup, with CHECK constraint at minimum.
13. **`order` as a column name** — reserved word in SQL. Use `position` or `sort_order`.
14. **Designing without query patterns** — if Round 5 of the interview produced fewer than 5 queries, the indexes will be wrong.

## Style rules

- **Reasoning, not just listing.** Every notable column choice has a "Notes" or rationale.
- **Indexes are first-class content.** They prove the query patterns are real.
- **JSON columns each get a justification.** If you can't write the justification, it shouldn't be JSON.
- **Cardinality estimates** for any table expected to grow large (> 1M rows) — they drive index strategy.
- **Open questions get explicit triggers** — "revisit when corpus > X" or "when feature Y ships."

## Handoff

Once DATA_MODEL.md is written and the user confirms:

1. Suggest the user commit it: `git add docs/DATA_MODEL.md && git commit -m "docs: initial data model"`
2. Suggest adding `@docs/DATA_MODEL.md` import to CLAUDE.md
3. Suggest the next step is the first migration:
   > "Want me to generate the initial migration from this model? I'll do it in a fresh session so we don't pollute this context. The migration will follow our naming convention (`<YYYYMMDD>_<HHMMSS>_<verb>_<noun>.sql`) and include every index and FK constraint listed here."
4. Remind the user to run a `schema-reviewer` subagent (or CodeRabbit) over the generated migration before commit.
