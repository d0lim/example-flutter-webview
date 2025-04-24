import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants.dart';

/// Service that handles authentication token management
class AuthService {
  static final _secureStorage = FlutterSecureStorage();

  /// Save auth token securely
  static Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.keyAuthToken, value: token);
      debugPrint('Auth token saved');
    } catch (e) {
      debugPrint('Error saving auth token: $e');
    }
  }

  /// Get the stored auth token
  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.keyAuthToken);
    } catch (e) {
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }

  /// Delete the stored auth token
  static Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.keyAuthToken);
      debugPrint('Auth token deleted');
    } catch (e) {
      debugPrint('Error deleting auth token: $e');
    }
  }

  /// Create URL request with auth token in headers
  static Future<URLRequest> createAuthorizedRequest(String url) async {
    final token = await getToken();
    
    return URLRequest(
      url: WebUri(url), // Uri.parse(url)에서 WebUri로 변경
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Notify JavaScript when token is expired or invalid
  static Future<void> notifyTokenExpired(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(
        source: "window.dispatchEvent(new CustomEvent('authExpired'));"
      );
      debugPrint('Token expired event sent to JS');
    } catch (e) {
      debugPrint('Error sending token expired event: $e');
    }
  }
}