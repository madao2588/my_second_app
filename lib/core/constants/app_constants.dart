class AppConstants {
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  static String get apiBaseUrl => _configuredApiBaseUrl.endsWith('/')
      ? _configuredApiBaseUrl.substring(0, _configuredApiBaseUrl.length - 1)
      : _configuredApiBaseUrl;

  static const connectTimeoutSeconds = 15;
  static const receiveTimeoutSeconds = 15;
}
