import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:uni_links/uni_links.dart';

/// Service that handles deep links
class DeepLinkService {
  static StreamSubscription? _deepLinkSubscription;
  static String? _pendingDeepLink;
  
  /// Get the initial deep link if app was opened with one
  static Future<void> initDeepLinks(InAppWebViewController? controller) async {
    try {
      // Get initial URI which may have launched the app
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri, controller);
      }
      
      // Listen for subsequent URI events (when app is in foreground)
      _deepLinkSubscription = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri, controller);
        }
      }, onError: (err) {
        debugPrint('Deep link error: $err');
      });
    } catch (e) {
      debugPrint('Error initializing deep links: $e');
    }
  }
  
  /// Handle a deep link by forwarding it to WebView
  static void _handleDeepLink(Uri uri, InAppWebViewController? controller) {
    final deepLinkData = jsonEncode({
      'path': uri.path,
      'queryParameters': uri.queryParameters,
    });
    
    if (controller != null) {
      _sendDeepLinkToJs(controller, deepLinkData);
    } else {
      // Store for later when WebView is initialized
      _pendingDeepLink = deepLinkData;
    }
  }
  
  /// Set the WebView controller and process any pending deep links
  static void setController(InAppWebViewController controller) {
    if (_pendingDeepLink != null) {
      _sendDeepLinkToJs(controller, _pendingDeepLink!);
      _pendingDeepLink = null;
    }
  }
  
  /// Send deep link data to JavaScript
  static Future<void> _sendDeepLinkToJs(InAppWebViewController controller, String deepLinkData) async {
    try {
      await controller.evaluateJavascript(
        source: "window.dispatchEvent(new CustomEvent('deepLink', { detail: $deepLinkData }));"
      );
      debugPrint('Deep link sent to JS: $deepLinkData');
    } catch (e) {
      debugPrint('Error sending deep link to JS: $e');
    }
  }
  
  /// Clean up resources when no longer needed
  static void dispose() {
    _deepLinkSubscription?.cancel();
    _deepLinkSubscription = null;
  }
}