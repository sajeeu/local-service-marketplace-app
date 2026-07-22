# ADR-0003 — Phase 2 Provider & Customer Profiles

## Status

Accepted

## Context

Phase 1 established authentication identity (`User`) without marketplace profiles. Phase 2 must introduce Provider Profile and Customer Profile as independent business identities while preserving Identity boundaries and deferring listings, bookings, and other marketplace features.

## Decisions

### 1. User remains authentication identity only

**Decision:** `User` continues to represent login credentials, account status, and role assignment. Marketplace profile fields are not added to `User`.

**Reason:** Domain rules require Identity ≠ marketplace domains. Mixing profile data into auth identity couples login lifecycle to business profiles and blocks a user from eventually holding both provider and customer identities cleanly.

**Impact:** Profiles attach to `User.id` via 1:1 optional relations. A user may exist with neither, one, or both profiles.

### 2. Provider Profile and Customer Profile are separate domains

**Decision:** Persist `ProviderProfile` and `CustomerProfile` as distinct tables/modules with independent APIs and Flutter feature folders.

**Reason:** Provider and customer marketplace identities have different fields, visibility rules, and future extension paths. Merging them into a single “Profile” entity would blur domain boundaries.

**Impact:** Cross-profile coupling is forbidden. Shared patterns (status, completion mapping) may be duplicated lightly rather than introducing a premature shared profile abstraction.

### 3. Provider Profile is not a service listing

**Decision:** Provider Profile stores business identity only (display, description, contact, media URLs, languages, settings, visibility). No services, pricing, availability, service areas, reviews, or reputation.

**Reason:** Cursor domain rules and long-term listing evolution require Provider Profile ≠ Service Listing.

**Impact:** Listing tables and APIs remain out of scope until a later phase.

### 4. Ownership-based authorization (not role flip)

**Decision:** Profile endpoints authorize by authenticated `userId` ownership. Creating a provider profile does not change `User.role`.

**Reason:** Phase 1 uses a single `UserRole` enum. Auto-promoting to `PROVIDER` would conflict with “a user may eventually have both profiles.” Ownership checks keep both profiles available under the same login.

**Impact:** `@Roles()` is not required for profile CRUD. Public provider reads are `@Public()` and filtered by `ACTIVE` + `PUBLIC` visibility.

### 5. Soft delete via profile status

**Decision:** Use `ProfileStatus` (`ACTIVE` | `DEACTIVATED`) with deactivate/restore endpoints, mirroring User status-based soft delete.

**Reason:** Consistent lifecycle model without hard deletes; owners can still read deactivated profiles; public reads hide deactivated profiles.

### 6. Media as URL strings

**Decision:** Store `logoUrl`, `coverImageUrl`, and `avatarUrl` as optional HTTPS URLs. Do not implement file upload or object storage in Phase 2.

**Reason:** No media infrastructure exists yet. URL fields keep the API complete for profile management without expanding scope into storage services.

**Impact:** Clients supply URLs; a future media service can replace or augment these fields additively.

### 7. Completion is computed

**Decision:** Profile completion (`status` / `percent`) is derived in mappers, not stored.

**Reason:** Completion rules will evolve; stored percentages risk drift.

### 8. OpenAPI via NestJS Swagger

**Decision:** Introduce `@nestjs/swagger` and serve docs at `/api/docs`.

**Reason:** Phase 2 requires API documentation; the repo previously had no OpenAPI surface.

## Consequences

- Phase 3 (categories & service areas) can build on profiles without redesigning identity.
- Public provider responses must strip private contact and settings.
- Dual-role authorization matrices remain a future concern if product requires simultaneous role semantics beyond ownership.
- Flutter keeps profile domain state separate from `sessionProvider`.
