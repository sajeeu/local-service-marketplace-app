# Domain — Maldives Geography

The marketplace operates **only in the Maldives**. There is no country selection and no `Country` table.

## Hierarchy

```
Maldives (fixed context)
  └── Atoll (or city-atoll equivalent, e.g. Addu City)
        └── Island
```

## Atoll

- `name`, unique `code`, optional `description`
- `displayOrder`, `status` (`ACTIVE` | `INACTIVE`)

Examples: Kaafu Atoll (`K`), Alifu Alifu (`AA`), Addu City (`S`).

## Island

- Belongs to exactly one atoll
- `name`, unique `slug`, `type` (`CAPITAL` | `CITY` | `INHABITED` | `RESORT` | `AIRPORT` | `INDUSTRIAL` | `OTHER`)
- `displayOrder`, `status`

Examples: Malé, Hulhumalé, Villingili, Maafushi, Thulusdhoo.

## API (Phase 3)

Read-only:

- List / get atolls
- List islands by atoll
- List / get islands (filter by atoll, type, search)

Geography writes are seed-driven in development; admin mutation APIs are deferred.

## Extensibility

Additional atolls and islands can be added without schema redesign. Listings and search in later phases will reference islands (and optionally atolls for aggregation).
