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

OpenAPI docs: `http://localhost:3000/api/docs`

Health:

- Liveness: `GET /api/v1/health`
- Readiness: `GET /api/v1/health/ready`

Identity:

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/logout`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/users/me`
- `PATCH /api/v1/users/me`

Provider profiles:

- `POST /api/v1/provider-profiles`
- `GET /api/v1/provider-profiles/me`
- `PATCH /api/v1/provider-profiles/me`
- `POST /api/v1/provider-profiles/me/deactivate`
- `POST /api/v1/provider-profiles/me/restore`
- `GET /api/v1/provider-profiles/:id` (public when ACTIVE + PUBLIC)

Customer profiles:

- `POST /api/v1/customer-profiles`
- `GET /api/v1/customer-profiles/me`
- `PATCH /api/v1/customer-profiles/me`
- `POST /api/v1/customer-profiles/me/deactivate`
- `POST /api/v1/customer-profiles/me/restore`

### 3. Frontend

```bash
cd frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

Auth screens: `/login`, `/register`. Profile screens: `/customer-profile*`, `/provider-profile*`. Tokens are stored with `flutter_secure_storage`.

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
docs/domain/       Domain boundaries and rules
docs/database/     Schema and migration notes
```

## Current phase

**Phase 2 — Provider & Customer Profiles** is implemented.

In scope: independent provider/customer marketplace identities linked to User, profile CRUD, soft deactivate/restore, public provider read, Flutter profile foundations.

Out of scope until later phases: categories, service areas, listings, search, bookings, payments, reviews, messaging, file upload storage.

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
- [ADR-0003 Phase 2 Profiles](docs/architecture/ADR-0003-phase-2-profiles.md)
- [Domain — Profiles](docs/domain/profiles.md)
- [Database — Phase 2 Profiles](docs/database/phase-2-profiles.md)
