class AppConstants {
  static const String appName = 'T.ask';
  static const String motto = 'What are your Tasks?';

  // Primary local backend URL + fallback tunnel/emulator URLs
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8000/api';
  static const List<String> fallbackApiBaseUrls = [
    'https://2061-183-83-170-206.ngrok-free.app/api',
    'http://10.0.2.2:8000/api',
    'http://localhost:8000/api',
  ];

  // Storage keys
  static const String tokenKey = 'task_access_token';
  static const String userKey = 'task_user_info';
  static const String rememberMeKey = 'task_remember_me';
  static const String savedEmailKey = 'task_saved_email';
}
