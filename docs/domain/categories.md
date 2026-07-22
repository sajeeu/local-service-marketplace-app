# Domain — Categories

Service categories classify offerings for browsing and (later) listings.

## Model

- Hierarchical: optional `parentId` (unlimited depth).
- Fields: `name`, `slug` (unique), `description`, `icon`, `displayOrder`, `status` (`ACTIVE` | `INACTIVE`), `metadata` (JSON).
- `metadata` is reserved for future localization, SEO, and analytics stubs.

## Rules

- Slugs are lowercase alphanumeric with hyphens.
- A category cannot be its own ancestor (no cycles).
- Delete of an active category soft-sets `INACTIVE` when it has no children.
- Hard delete is allowed only when already inactive and childless.
- Categories with children cannot be deleted until children are reassigned or removed.

## Authorization

| Action | Who |
| --- | --- |
| List / get active | Public |
| List / get inactive | Administrator (via status filter or admin get) |
| Create / update / delete | Administrator |

## Out of scope

Search, recommendations, promotions, featured categories, listing linkage (Phase 4+).
