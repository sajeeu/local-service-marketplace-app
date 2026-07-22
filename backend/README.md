# Backend API

NestJS + Prisma API for the Local Service Marketplace.

## Commands

```bash
# from repo root
npm install
npm run shared:build
cp backend/.env.example backend/.env
docker compose up -d
npm run prisma:generate --workspace=backend
npm run prisma:migrate:deploy --workspace=backend
npm run db:seed --workspace=backend
npm run backend:dev
```

OpenAPI (Swagger UI): `http://localhost:3000/api/docs`

## Seed / database commands

| Script | Purpose |
| --- | --- |
| `npm run db:seed` | Idempotent development seed |
| `npm run db:clear` | Clear development rows |
| `npm run db:reseed` | Clear + seed |
| `npm run db:reset` | Migrate reset + seed |
| `npm run prisma:studio` | Prisma Studio |

See [Seed Data](../docs/database/seed-data.md).

## Endpoints

### Health

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/api/v1/health` | Public | Liveness |
| GET | `/api/v1/health/ready` | Public | Readiness (DB) |

### Authentication

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| POST | `/api/v1/auth/register` | Public | Create customer identity + tokens |
| POST | `/api/v1/auth/login` | Public | Authenticate + tokens |
| POST | `/api/v1/auth/refresh` | Public | Rotate refresh + new access token |
| POST | `/api/v1/auth/logout` | Bearer | Revoke refresh token |

Register/login body:

```json
{ "email": "user@example.com", "password": "password123", "displayName": "Optional" }
```

Auth success `data`:

```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "expiresIn": 900,
  "user": {
    "id": "...",
    "email": "user@example.com",
    "displayName": "Optional",
    "role": "CUSTOMER",
    "status": "ACTIVE",
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

### Users (identity)

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/api/v1/users/me` | Bearer | Current identity |
| PATCH | `/api/v1/users/me` | Bearer | Update `displayName` |

### Provider profiles

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| POST | `/api/v1/provider-profiles` | Bearer | Create own provider profile |
| GET | `/api/v1/provider-profiles/me` | Bearer | Get own provider profile |
| PATCH | `/api/v1/provider-profiles/me` | Bearer | Update own provider profile |
| POST | `/api/v1/provider-profiles/me/deactivate` | Bearer | Soft-deactivate |
| POST | `/api/v1/provider-profiles/me/restore` | Bearer | Restore |
| GET | `/api/v1/provider-profiles/:id` | Public | Public profile (ACTIVE + PUBLIC only) |

### Provider service coverage

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/api/v1/provider-profiles/me/coverage` | Bearer | View island coverage |
| PUT | `/api/v1/provider-profiles/me/coverage` | Bearer | Replace coverage `{ islandIds }` |
| POST | `/api/v1/provider-profiles/me/coverage/islands` | Bearer | Add islands |
| DELETE | `/api/v1/provider-profiles/me/coverage/islands` | Bearer | Remove islands |
| POST | `/api/v1/provider-profiles/me/coverage/atolls/:atollId` | Bearer | Add all active islands in atoll |

### Customer profiles

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| POST | `/api/v1/customer-profiles` | Bearer | Create own customer profile |
| GET | `/api/v1/customer-profiles/me` | Bearer | Get own customer profile |
| PATCH | `/api/v1/customer-profiles/me` | Bearer | Update own customer profile |
| POST | `/api/v1/customer-profiles/me/deactivate` | Bearer | Soft-deactivate |
| POST | `/api/v1/customer-profiles/me/restore` | Bearer | Restore |

### Categories

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/api/v1/categories` | Public | List (pagination, filters) |
| GET | `/api/v1/categories/:id` | Public | Get category |
| POST | `/api/v1/categories` | Admin | Create |
| PATCH | `/api/v1/categories/:id` | Admin | Update |
| DELETE | `/api/v1/categories/:id` | Admin | Soft-deactivate / hard-delete if inactive |

### Maldives geography

| Method | Path | Auth | Purpose |
| --- | --- | --- | --- |
| GET | `/api/v1/atolls` | Public | List atolls |
| GET | `/api/v1/atolls/:id` | Public | Get atoll |
| GET | `/api/v1/atolls/:id/islands` | Public | Islands in atoll |
| GET | `/api/v1/islands` | Public | List islands |
| GET | `/api/v1/islands/:id` | Public | Get island |

List endpoints include `meta.pagination`: `{ page, limit, total, totalPages }`.

All responses use the shared envelope `{ data, error, meta }`.

## Modules

| Module | Path |
| --- | --- |
| Identity | `src/modules/identity/` |
| Providers | `src/modules/providers/` |
| Customers | `src/modules/customers/` |
| Categories | `src/modules/categories/` |
| Geography | `src/modules/geography/` |

See [ADR-0002](../docs/architecture/ADR-0002-phase-1-identity.md), [ADR-0003](../docs/architecture/ADR-0003-phase-2-profiles.md), [ADR-0004](../docs/architecture/ADR-0004-phase-3-categories-geography.md), and the root [README.md](../README.md).
