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
npm run backend:dev
```

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

All responses use the shared envelope `{ data, error, meta }`.

## Modules

Identity lives under `src/modules/identity/` (Auth, Users, Authorization).

See [ADR-0002](../docs/architecture/ADR-0002-phase-1-identity.md) and the root [README.md](../README.md).
