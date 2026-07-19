import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin facade for persistent preferences (no domain keys yet).
class PreferencesStore {
  PreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> remove(String key) => _prefs.remove(key);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

final preferencesStoreProvider = Provider<PreferencesStore>((ref) {
  return PreferencesStore(ref.watch(sharedPreferencesProvider));
});
