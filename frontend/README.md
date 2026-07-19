# Frontend

Flutter client for the Local Service Marketplace.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

## State ownership

| Kind | Approach |
| --- | --- |
| UI | Widget-local / Riverpod UI providers |
| Session | `sessionProvider` (`AsyncNotifier`) — auth identity + tokens |
| Remote | `ApiClient` + feature APIs (`AuthApi`) |
| Persistent prefs | `PreferencesStore` via `shared_preferences` |
| Secure tokens | `TokenStore` via `flutter_secure_storage` |

## Auth routes

| Path | Screen |
| --- | --- |
| `/login` | Sign in |
| `/register` | Create account |
| `/` | Foundation home (authenticated) |

Unauthenticated users are redirected to `/login`. Tokens are never stored in SharedPreferences.

## Structure

```
lib/
  app/        App shell, router (auth redirects)
  core/       Config, theme, network, errors, session, token store
  features/
    auth/     Login/register + AuthApi
    home/     Bootstrap shell
```
