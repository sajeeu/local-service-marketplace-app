# Database — Phase 2 Profiles

## Migration

- Name: `20260722100000_phase2_profiles`
- Additive on Phase 1 Identity schema
- SQL: `backend/prisma/migrations/20260722100000_phase2_profiles/migration.sql`

## New enums

| Enum | Values |
| --- | --- |
| `ProfileStatus` | `ACTIVE`, `DEACTIVATED` |
| `ProfileVisibility` | `PUBLIC`, `PRIVATE` |

## Models

### `ProviderProfile`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | TEXT (cuid) | PK |
| `userId` | TEXT | Unique FK → `User.id`, `ON DELETE CASCADE` |
| `displayName` | TEXT | Required |
| `businessName` | TEXT | Optional |
| `description` | TEXT | Optional |
| `contactEmail` | TEXT | Optional |
| `contactPhone` | TEXT | Optional |
| `websiteUrl` | TEXT | Optional |
| `logoUrl` | TEXT | Optional HTTPS URL |
| `coverImageUrl` | TEXT | Optional HTTPS URL |
| `languages` | TEXT[] | Default `[]` |
| `businessSettings` | JSONB | Default `{}` |
| `visibility` | `ProfileVisibility` | Default `PRIVATE` |
| `status` | `ProfileStatus` | Default `ACTIVE` |
| `createdAt` / `updatedAt` | TIMESTAMP | |

**Indexes**

- Unique: `userId`
- Composite: `(status, visibility)` for public lookups

### `CustomerProfile`

| Column | Type | Notes |
| --- | --- | --- |
| `id` | TEXT (cuid) | PK |
| `userId` | TEXT | Unique FK → `User.id`, cascade |
| `displayName` | TEXT | Required |
| `avatarUrl` | TEXT | Optional HTTPS URL |
| `contactEmail` | TEXT | Optional |
| `contactPhone` | TEXT | Optional |
| `preferences` | JSONB | Default `{}` |
| `savedSettings` | JSONB | Default `{}` |
| `status` | `ProfileStatus` | Default `ACTIVE` |
| `createdAt` / `updatedAt` | TIMESTAMP | |

**Indexes**

- Unique: `userId`
- `status`

## Relationships

```
User 1 ── 0..1 ProviderProfile
User 1 ── 0..1 CustomerProfile
```

`User` gained optional relations `providerProfile` and `customerProfile` only. No listing, category, booking, payment, review, or messaging tables were added.

## Constraints & integrity

- One provider profile per user (unique `userId`)
- One customer profile per user (unique `userId`)
- Cascading delete when a User row is removed
- Soft delete for profiles uses `status = DEACTIVATED` (no `deletedAt` column)

## Out of scope

Listings, categories, service areas, bookings, payments, reviews, messaging.
