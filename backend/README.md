# Backend API

NestJS + Prisma foundation for the Local Service Marketplace.

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

## Endpoints (Phase 0)

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/v1/health` | Liveness |
| GET | `/api/v1/health/ready` | Readiness (DB) |

See root [README.md](../README.md) and [ADR-0001](../docs/architecture/ADR-0001-phase-0-foundation.md).
