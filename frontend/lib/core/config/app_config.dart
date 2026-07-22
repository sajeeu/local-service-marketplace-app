import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Application configuration loaded from compile-time defines.
///
/// Example:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1`
///
/// On Android emulators, `localhost` / `127.0.0.1` are rewritten to `10.0.2.2`
/// so the app can reach the host machine's backend.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.appName,
  });

  final String apiBaseUrl;
  final String appName;

  static const String _defaultApiBaseUrl = 'http://localhost:3000/api/v1';
  static const String _defaultAppName = 'Local Service Marketplace';

  static AppConfig get current => AppConfig(
        apiBaseUrl: resolveApiBaseUrl(
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: _defaultApiBaseUrl,
          ),
        ),
        appName: const String.fromEnvironment(
          'APP_NAME',
          defaultValue: _defaultAppName,
        ),
      );

  /// Maps host loopback URLs to the Android emulator host alias.
  @visibleForTesting
  static String resolveApiBaseUrl(String configured) {
    if (kIsWeb) {
      return configured;
    }
    final isAndroid = !kIsWeb && Platform.isAndroid;
    if (!isAndroid) {
      return configured;
    }
    return configured
        .replaceFirst('://localhost', '://10.0.2.2')
        .replaceFirst('://127.0.0.1', '://10.0.2.2');
  }
}
