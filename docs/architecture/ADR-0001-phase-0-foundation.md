# ADR-0001 — Phase 0 Foundation

## Status

Accepted

## Context

The Local Service Marketplace repository started as a greenfield project with architectural rules only. Phase 0 must establish a production-ready foundation without implementing business domains (identity, listings, bookings, etc.).

## Decisions

### 1. NestJS for the backend

**Decision:** Use NestJS with TypeScript modules and dependency injection.

**Reason:** Project rules require thin controllers, domain services, DI, and typed interfaces. NestJS provides this structure with filters, pipes, guards, and versioning built in.

**Impact:** Future domains become Nest modules under `backend/src/modules/` with clear boundaries.

### 2. Prisma + PostgreSQL

**Decision:** Use Prisma against PostgreSQL 16 (Docker Compose for local development).

**Reason:** Strong typing, migration safety, and clear persistence boundary. Matches long-term relational marketplace data needs.

**Impact:** Phase 0 ships a schema with **no business models** and an empty baseline migration so deploy paths exist before domain tables arrive.

### 3. Flutter + Riverpod + go_router

**Decision:** Place the client in `frontend/` with Riverpod for state ownership and go_router for navigation.

**Reason:** Feature-oriented Flutter apps scale better with explicit state ownership (UI / session / remote / persistent) and declarative routing.

**Impact:** Phase 1+ features add routes and providers without restructuring the app shell.

### 4. Versioned REST API with envelope responses

**Decision:** Global prefix `api`, URI versioning (`/api/v1/...`), and a consistent envelope:

```json
{ "data": {}, "error": null, "meta": {} }
```

**Reason:** Stable contracts, safe error surfaces, and forward-compatible clients.

**Impact:** Shared error codes live in `@local-service-marketplace/shared`; clients must not invent parallel formats.

### 5. npm workspaces for backend + shared types

**Decision:** Root npm workspaces for `backend` and `packages/shared`. Flutter remains separate (pub).

**Reason:** Share API envelope/error constants without premature Dart/TS codegen complexity.

**Impact:** Domain DTOs stay out of `shared` until there is a concrete cross-cutting need.

### 6. Security baseline without authentication

**Decision:** Helmet, CORS allowlist, body limits, throttling, structured redacted logging. No auth implementation.

**Reason:** Secure defaults before identity work in Phase 1.

**Impact:** Authn/authz error types exist server-side and are ready for Phase 1 wiring.

## Consequences

- Phase 1 can add Identity/User models and auth without redesigning bootstrap, config, logging, or API conventions.
- Local development requires Docker for PostgreSQL readiness checks against a real database.
- CI validates backend lint/tests and Flutter analyze/tests; full e2e against Docker may be added later.
