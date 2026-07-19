# ADR-0002 — Phase 1 Identity & Authentication

## Status

Accepted

## Context

Phase 0 established NestJS, Prisma, envelope responses, and security baselines without authentication. Phase 1 must add identity (users, auth, sessions, roles) without provider/customer marketplace profiles.

## Decisions

### 1. Identity is authentication identity only

**Decision:** The `User` entity represents login identity, account status, and role assignment. It does not include provider or customer marketplace profiles.

**Reason:** Domain rules require Provider Profile ≠ Service Listing and keep Identity separate from marketplace domains. Profiles arrive in Phase 2.

**Impact:** APIs expose only identity fields (`id`, `email`, `displayName`, `role`, `status`, timestamps). No profile tables in this phase.

### 2. JWT access tokens + opaque refresh tokens

**Decision:** Issue short-lived signed JWT access tokens (`Authorization: Bearer`) and long-lived opaque refresh tokens stored as SHA-256 hashes in `RefreshToken`.

**Reason:** Fits Flutter mobile clients and secure storage. Opaque refresh tokens support server-side revocation and rotation without cookie dependency in Phase 1.

**Impact:** Clients persist tokens securely; logout and rotation revoke refresh rows. Access JWT carries `sub` (user id), `role`, and `status`.

### 3. Argon2 password hashing

**Decision:** Hash passwords with Argon2. Never store or return plaintext passwords or password hashes in API responses.

**Reason:** Strong default for credential storage; aligns with security rules.

### 4. Single role enum on User

**Decision:** `UserRole` enum: `CUSTOMER` | `PROVIDER` | `ADMINISTRATOR`. Registration defaults to `CUSTOMER`.

**Reason:** Prepares for future marketplace roles without RBAC join tables or marketplace permission matrices yet.

**Impact:** Authorization uses `@Roles()` + `RolesGuard`. Permission constants are identity-level only and expand later.

### 5. Account lifecycle via status

**Decision:** `UserStatus`: `ACTIVE` | `SUSPENDED` | `DELETED`. Login allowed only for `ACTIVE`. Soft-delete uses `DELETED`.

**Reason:** Supports lifecycle without email-verification product flow in Phase 1.

### 6. Nest modules under `backend/src/modules/identity`

**Decision:** Aggregate Auth, Users, and Authorization under `IdentityModule`.

**Reason:** Matches ADR-0001 module placement and keeps controllers thin with service-owned business rules.

## Consequences

- Phase 2 can attach provider/customer profiles to `User.id` without redesigning auth.
- Env must include JWT secrets and TTLs; boot fails if secrets are missing outside test defaults.
- Health and public auth endpoints use `@Public()` because JWT auth guard is global.
- Multi-role users (if ever required) would need a later migration from the single enum.
