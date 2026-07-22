# ADR-0004 — Phase 3 Categories & Maldives Service Areas

## Status

Accepted

## Context

Phase 2 established Provider and Customer profiles without marketplace taxonomy or geography. Phase 3 must introduce service categories, Maldives-only geographic hierarchy (atolls → islands), and provider service coverage so later listing and search phases have stable foundations.

The marketplace operates exclusively in the Maldives. Multi-country architecture must not be introduced.

## Decisions

### 1. Maldives is fixed context (no Country table)

**Decision:** Do not persist a `Country` entity. Country is documented as Maldives and implied by all geography data.

**Reason:** Country selection is never required; a Country table would invite multi-country expansion prematurely.

**Impact:** Atolls and islands are top-level geography entities under a fixed national context.

### 2. Categories are hierarchical and admin-managed

**Decision:** Persist `Category` with optional `parentId` self-relation, unique `slug`, `displayOrder`, `CatalogStatus`, and `metadata` JSON. Mutations require `ADMINISTRATOR`. Public reads return active categories by default.

**Reason:** Unlimited taxonomy growth and admin curation without exposing write APIs to providers in this phase.

**Impact:** Localization/SEO/analytics can extend `metadata` additively. First real use of `@Roles(ADMINISTRATOR)`.

### 3. Geography API is read-only in Phase 3

**Decision:** Expose list/get for atolls and islands only. Populate geography via development seeds (and future admin tools).

**Reason:** Administrative geography changes are rare; seed-driven data is sufficient for Phase 3.

### 4. Coverage is island-normalized, not profile fields

**Decision:** Store coverage in `ProviderIslandCoverage` (`providerProfileId` + `islandId`). Do not add service-area columns to `ProviderProfile`. “Serve entire atoll” expands to all **currently active** islands in that atoll (snapshot); newly added islands are not auto-included.

**Reason:** ADR-0003 requires Provider Profile ≠ service areas. Island-level rows keep future search/listings simple. Dual atoll/island coverage tables add complexity without clear Phase 3 benefit.

**Impact:** Coverage APIs live under `/provider-profiles/me/coverage` with ownership checks.

### 5. Pagination via envelope meta

**Decision:** List endpoints return `{ data: items, error: null, meta: { pagination: { page, limit, total, totalPages } } }`.

**Reason:** Aligns with existing envelope; first shared list convention for later catalog/search APIs.

### 6. Development seed pipeline is mandatory

**Decision:** Introduce idempotent Prisma seeds organized by domain, with documented `db:seed`, `db:clear`, `db:reset`, and `db:reseed` commands. Refuse seeds when `NODE_ENV=production`.

**Reason:** Project seed standards require realistic data for UI/API testing; Phase 3 is the first entity set that depends on rich relational fixtures.

## Consequences

- Phase 4 (listings) can reference categories and islands without redesigning geography.
- Atoll-wide auto-include of future islands remains a possible later enhancement.
- Flutter Phase 3 UI covers provider service-area selection only (no category admin UI).
