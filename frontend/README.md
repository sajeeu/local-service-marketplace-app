# Frontend

Flutter client foundation for the Local Service Marketplace.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

## State ownership

| Kind | Approach |
| --- | --- |
| UI | Widget-local / Riverpod UI providers |
| Session | `sessionProvider` placeholder (Phase 1) |
| Remote | `ApiClient` + future AsyncNotifier providers |
| Persistent | `PreferencesStore` via `shared_preferences` |

## Structure

```
lib/
  app/        App shell, router
  core/       Config, theme, network, errors, shared widgets
  features/   Feature modules (home bootstrap only in Phase 0)
```
