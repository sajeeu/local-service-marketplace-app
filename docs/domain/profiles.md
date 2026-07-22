# Domain — User, Provider Profile, Customer Profile

## Responsibilities

### User (Identity)

- Authentication credentials (email, password hash)
- Account status (`ACTIVE` | `SUSPENDED` | `DELETED`)
- Role assignment (`CUSTOMER` | `PROVIDER` | `ADMINISTRATOR`) — identity-level, not marketplace profile
- Optional identity display name for login UX

User is **not** a marketplace profile and does **not** contain listing, booking, or reputation data.

### Provider Profile

Marketplace **business identity** for a service provider:

- Display name and business information
- Description and contact information
- Logo / cover image URLs
- Languages
- Business settings (JSON)
- Profile visibility (`PUBLIC` | `PRIVATE`)
- Lifecycle status (`ACTIVE` | `DEACTIVATED`)
- Computed completion status

Provider Profile is **not** a service listing. It does not include services, pricing, availability, reviews, ratings, verification, or reputation.

Service areas (which islands a provider serves) are modeled separately as **Provider Island Coverage** — see [service-coverage.md](./service-coverage.md) and ADR-0004.

### Customer Profile

Marketplace **customer identity**:

- Display name and avatar URL
- Contact information
- Preferences and saved settings (JSON)
- Lifecycle status
- Computed completion status

Customer Profile does **not** include favorites, booking history, reviews, or marketplace activity feeds.

## Domain boundaries

| Concept | Owns | Must not own |
| --- | --- | --- |
| User | Auth identity | Marketplace profile fields, listings |
| Provider Profile | Business identity | Listings, bookings, payments |
| Customer Profile | Customer identity | Favorites, booking history, reviews |
| Service Listing (future) | Offerings / pricing / availability | Provider reputation / auth |

## Business rules

1. A User may exist without either profile.
2. A User may have at most one Provider Profile (1:1).
3. A User may have at most one Customer Profile (1:1).
4. A User may eventually have both profiles.
5. Users manage only their own profiles (ownership via authenticated `userId`).
6. Public provider reads expose only explicitly public fields when status is `ACTIVE` and visibility is `PUBLIC`.
7. Creating a profile does not mutate `User.role`.
8. Soft delete uses `DEACTIVATED`; restore returns `ACTIVE`.

## Module ownership

| Domain | Backend | Frontend |
| --- | --- | --- |
| Identity | `backend/src/modules/identity/` | `frontend/lib/features/auth/` + `core/state/session_provider.dart` |
| Providers | `backend/src/modules/providers/` | `frontend/lib/features/providers/` |
| Customers | `backend/src/modules/customers/` | `frontend/lib/features/customers/` |

See [ADR-0003](../architecture/ADR-0003-phase-2-profiles.md).
