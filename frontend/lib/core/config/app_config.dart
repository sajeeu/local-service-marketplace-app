/// Application configuration loaded from compile-time defines.
///
/// Example:
/// `flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1`
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.appName,
  });

  final String apiBaseUrl;
  final String appName;

  static const AppConfig current = AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000/api/v1',
    ),
    appName: String.fromEnvironment(
      'APP_NAME',
      defaultValue: 'Local Service Marketplace',
    ),
  );
}
