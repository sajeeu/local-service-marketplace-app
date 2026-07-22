# Frontend

Flutter client for the Local Service Marketplace.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

On an **Android emulator**, `localhost` is automatically rewritten to `10.0.2.2` so the app can reach the backend on your host machine. You can also set it explicitly:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

## State ownership

| Kind | Approach |
| --- | --- |
| UI | Widget-local / Riverpod UI providers |
| Session | `sessionProvider` — auth identity + tokens only |
| Provider profile | `providerProfileProvider` — marketplace provider identity |
| Customer profile | `customerProfileProvider` — marketplace customer identity |
| Remote | `ApiClient` + feature APIs |
| Persistent prefs | `PreferencesStore` via `shared_preferences` |
| Secure tokens | `TokenStore` via `flutter_secure_storage` |

## Routes

| Path | Screen |
| --- | --- |
| `/login` | Sign in |
| `/register` | Create account |
| `/` | Home (authenticated) — profile entry points |
| `/customer-profile` | View own customer profile |
| `/customer-profile/create` | Create customer profile |
| `/customer-profile/edit` | Edit customer profile |
| `/provider-profile` | View own provider profile |
| `/provider-profile/create` | Create provider profile |
| `/provider-profile/edit` | Edit provider profile |

Unauthenticated users are redirected to `/login`. Tokens are never stored in SharedPreferences.

## Structure

```
lib/
  app/        App shell, router (auth redirects)
  core/       Config, theme, network, errors, session, token store
  features/
    auth/       Login/register + AuthApi
    home/       Authenticated home with profile links
    customers/  Customer profile data/state/presentation
    providers/  Provider profile data/state/presentation
```

Profile features are intentionally separate from `auth/`. Session state must not absorb marketplace profile fields.

## Theme

Visual design tokens live in `lib/core/theme/app_tokens.dart` and are applied via `lib/core/theme/app_theme.dart`.

The brand uses a professional blue palette (`#1565C0` primary) to communicate trust and reliability for a local service marketplace. Shared UI building blocks (scaffold width constraints, status chips, async/empty states, password field) live under `lib/core/widgets/`.
