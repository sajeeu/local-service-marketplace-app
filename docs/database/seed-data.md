# Development Seed Data

Development seeds are **mandatory** for marketplace entities and must never run in production (`NODE_ENV=production` is rejected).

## Commands (from `backend/`)

| Command | Purpose |
| --- | --- |
| `npm run db:seed` | Idempotent upsert of all domain seeds |
| `npm run db:clear` | Delete development rows (users, profiles, categories, geography, coverage) |
| `npm run db:reseed` | Clear then seed |
| `npm run db:reset` | `prisma migrate reset --force` (drop DB, migrate, seed) |

Root-equivalent:

```bash
npm run db:seed --workspace=backend
npm run db:reseed --workspace=backend
npm run db:reset --workspace=backend
```

## Layout

```
backend/prisma/seed.ts              Orchestrator
backend/prisma/clear-dev-data.ts    Clear helper
backend/prisma/seeds/
  constants.ts                      Shared IDs / password
  identity.ts                       Users + sample customer
  providers.ts                      Provider profiles
  categories.ts                     Category tree
  geography.ts                      Atolls + islands
  coverage.ts                       Provider ↔ island coverage
```

## Seed password

All seeded users share: `SeedPassword123!`

## Inventory

### Users / profiles

| Email | Role / profile |
| --- | --- |
| `admin@seed.maldives.local` | Administrator |
| `plumbing@seed.maldives.local` | Provider: Malé Plumbing Experts |
| `cleaning@seed.maldives.local` | Provider: Hulhumalé Cleaning Experts |
| `photography@seed.maldives.local` | Provider: Atoll Photography Services |
| `nocoverage@seed.maldives.local` | Provider: New Island Services (empty coverage) |
| `customer@seed.maldives.local` | Customer profile |

### Categories

Parents: Home Services, Auto Services, Personal Services, Technology, plus inactive `Legacy Services`.

Children include Plumbing, Electrical, AC Repair, Cleaning, Painting, Carpentry, Appliance Repair, Gardening, Home Maintenance, Moving Services, Landscaping, Vehicle Repair, Auto Detailing, Roadside Assistance, Beauty, Fitness, Photography, Event Services, Computer Repair, Phone Repair, IT Support.

### Geography

Atolls include Kaafu (`K`), Alifu Alifu (`AA`), Alifu Dhaalu (`ADh`), Laamu (`L`), Addu City (`S`), Baa (`B`), Haa Dhaalu (`HDh`).

Islands include Malé, Hulhumalé, Villingili, Maafushi, Thulusdhoo, Addu City islands, and others; one inactive demo island under Kaafu.

### Coverage examples

| Provider | Coverage |
| --- | --- |
| Malé Plumbing Experts | Malé, Hulhumalé |
| Hulhumalé Cleaning Experts | Hulhumalé |
| Atoll Photography Services | All active Kaafu islands |
| New Island Services | None (empty state) |

## Idempotency

Seeds upsert by natural keys (`email`, `slug`, `code`, `userId`). Re-running `db:seed` does not duplicate rows. Coverage is replaced per provider on each seed run. Retired education category slugs and legacy tuition seed accounts are deleted on each seed run.
