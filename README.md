# Local Service Marketplace

Mobile-first, API-first local service marketplace.

| Layer | Stack |
| --- | --- |
| Backend | NestJS + TypeScript |
| Database | PostgreSQL + Prisma |
| Frontend | Flutter (Riverpod + go_router) |
| Shared | `@local-service-marketplace/shared` (API envelope / error codes) |

## Prerequisites

- Node.js 20+
- npm 10+
- Docker / Docker Compose
- Flutter 3.38+ (stable)

## Quick start

### 1. Start PostgreSQL

Start Docker Desktop, then:

```bash
docker compose up -d
```

### 2. Backend

```bash
cp backend/.env.example backend/.env
npm install
npm run shared:build
npm run prisma:generate --workspace=backend
npm run prisma:migrate:dev --workspace=backend
npm run backend:dev
```

API base: `http://localhost:3000/api/v1`

Health:

- Liveness: `GET /api/v1/health`
- Readiness: `GET /api/v1/health/ready`

Identity (Phase 1):

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/logout`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/users/me`
- `PATCH /api/v1/users/me`

### 3. Frontend

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

Auth screens: `/login`, `/register`. Tokens are stored with `flutter_secure_storage`.

## Environments

Configuration is environment-driven (no hardcoded secrets).

| Variable | Description |
| --- | --- |
| `DATABASE_URL` | PostgreSQL connection string |
| `PORT` | HTTP port (default `3000`) |
| `APP_ENV` | `development` \| `staging` \| `production` |
| `CORS_ORIGINS` | Comma-separated allowed origins |
| `LOG_LEVEL` | Pino log level |
| `THROTTLE_TTL_MS` / `THROTTLE_LIMIT` | Rate limit window and max requests |
| `BODY_LIMIT` | Max request body size |
| `TRUST_PROXY` | Enable when behind a reverse proxy |
| `JWT_ACCESS_SECRET` | Access token signing secret (min 32 chars) |
| `JWT_ACCESS_TTL` | Access token lifetime (default `15m`) |
| `JWT_REFRESH_SECRET` | Refresh token pepper (min 32 chars) |
| `JWT_REFRESH_TTL` | Refresh token lifetime (default `7d`) |

Staging and production use the same keys with different values (see `backend/.env.example`).

## Repository layout

```
backend/           NestJS API
frontend/          Flutter app
packages/shared/   Shared API types
docs/architecture/ Architecture decisions
```

## Current phase

**Phase 1 — Identity & User Foundation** is implemented.

In scope: user accounts, authentication, refresh sessions, roles foundation, account status.

Out of scope until later phases: provider/customer profiles, listings, search, bookings, payments, reviews.

## Scripts

| Script | Purpose |
| --- | --- |
| `npm run backend:dev` | Start API in watch mode |
| `npm run backend:build` | Build API |
| `npm run backend:test` | Run backend unit tests |
| `npm run backend:lint` | Lint backend |
| `npm run shared:build` | Build shared package |

## Documentation

- [ADR-0001 Phase 0 Foundation](docs/architecture/ADR-0001-phase-0-foundation.md)
- [ADR-0002 Phase 1 Identity](docs/architecture/ADR-0002-phase-1-identity.md)
