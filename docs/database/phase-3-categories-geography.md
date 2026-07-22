# Database — Phase 3 Categories, Geography & Coverage

Migration: `20260722120000_phase3_categories_geography_coverage`

## Enums

| Enum | Values |
| --- | --- |
| `CatalogStatus` | `ACTIVE`, `INACTIVE` |
| `IslandType` | `CAPITAL`, `CITY`, `INHABITED`, `RESORT`, `AIRPORT`, `INDUSTRIAL`, `OTHER` |

## Tables

### Category

| Column | Notes |
| --- | --- |
| `id` | cuid |
| `name`, `slug` | slug unique |
| `description`, `icon` | optional |
| `parentId` | self-FK, `ON DELETE RESTRICT` |
| `displayOrder` | default 0 |
| `status` | `CatalogStatus` |
| `metadata` | JSONB default `{}` |
| timestamps | `createdAt`, `updatedAt` |

Indexes: `parentId`, `(status, displayOrder)`.

### Atoll

| Column | Notes |
| --- | --- |
| `id` | cuid |
| `name`, `code` | code unique |
| `description` | optional |
| `displayOrder`, `status` | |
| timestamps | |

Index: `(status, displayOrder)`.

### Island

| Column | Notes |
| --- | --- |
| `id` | cuid |
| `atollId` | FK → Atoll, `ON DELETE RESTRICT` |
| `name`, `slug` | slug unique; unique `(atollId, name)` |
| `type` | `IslandType` |
| `displayOrder`, `status` | |
| timestamps | |

Indexes: `atollId`, `(status, displayOrder)`.

### ProviderIslandCoverage

| Column | Notes |
| --- | --- |
| `id` | cuid |
| `providerProfileId` | FK → ProviderProfile, cascade delete |
| `islandId` | FK → Island, restrict delete |
| `createdAt` | |

Unique: `(providerProfileId, islandId)`. Indexes on both FKs.

## Relationships

```
User 1—0..1 ProviderProfile 1—* ProviderIslandCoverage *—1 Island *—1 Atoll
Category 0..1—* Category (parent/children)
```

No Country table — Maldives is fixed application context.
