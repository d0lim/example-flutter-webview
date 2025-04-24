/// Constants used throughout the application
class AppConstants {
  // WebView
  static const String initialUrl = 'https://example.com';
  static const String localWebPath = 'assets/web/index.html';
  
  // JavaScript Handlers
  static const String jsHandlerNative = 'native';
  static const String jsHandlerGetLocation = 'getLocation';
  static const String jsHandlerReadClipboard = 'readClipboard';
  static const String jsHandlerWriteClipboard = 'writeClipboard';
  static const String jsHandlerJsError = 'jsError';
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  
  // Deep Link Scheme
  static const String appLinkScheme = 'examplewebview';
  
  // Firebase Topic 
  static const String notificationTopic = 'all_users';
}