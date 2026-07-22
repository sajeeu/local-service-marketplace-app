# Domain — Provider Service Coverage

Providers declare **where** they offer services. Coverage is separate from Provider Profile identity fields (see ADR-0003 / ADR-0004).

## Model

`ProviderIslandCoverage` joins `ProviderProfile` ↔ `Island` with a unique pair constraint.

Providers may:

- Serve one island
- Serve multiple islands
- Serve an entire atoll (snapshot of all **active** islands in that atoll at assignment time)
- Clear coverage (empty set for empty-state UX)

## Rules

- Owner must have a provider profile.
- Only **active** islands can be assigned.
- Adds are idempotent (`skipDuplicates`).
- Replace (`PUT`) is the primary full-sync operation used by the Flutter editor.
- Expanding an atoll does **not** auto-include islands added to that atoll later.

## API

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/v1/provider-profiles/me/coverage` | View coverage |
| PUT | `/api/v1/provider-profiles/me/coverage` | Replace island set |
| POST | `/api/v1/provider-profiles/me/coverage/islands` | Add islands |
| DELETE | `/api/v1/provider-profiles/me/coverage/islands` | Remove islands |
| POST | `/api/v1/provider-profiles/me/coverage/atolls/:atollId` | Expand atoll |

Authorization: authenticated owner of the provider profile.

## Out of scope

Listings, search ranking by area, customer location preferences.
