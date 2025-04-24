import 'package:flutter_test/flutter_test.dart';
import 'package:example_webview/core/constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct values', () {
      // WebView constants
      expect(AppConstants.initialUrl, 'https://example.com');
      expect(AppConstants.localWebPath, 'assets/web/index.html');
      
      // JavaScript Handlers constants
      expect(AppConstants.jsHandlerNative, 'native');
      expect(AppConstants.jsHandlerGetLocation, 'getLocation');
      expect(AppConstants.jsHandlerReadClipboard, 'readClipboard');
      expect(AppConstants.jsHandlerWriteClipboard, 'writeClipboard');
      expect(AppConstants.jsHandlerJsError, 'jsError');
      
      // Storage Keys constants
      expect(AppConstants.keyAuthToken, 'auth_token');
      
      // Deep Link Scheme constant
      expect(AppConstants.appLinkScheme, 'examplewebview');
      
      // Firebase Topic constant
      expect(AppConstants.notificationTopic, 'all_users');
    });
  });
}