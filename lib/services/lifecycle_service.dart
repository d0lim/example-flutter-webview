import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Service that handles app lifecycle events
class LifecycleService {
  static InAppWebViewController? _webViewController;
  
  /// Set the WebView controller for sending lifecycle events
  static void setController(InAppWebViewController controller) {
    _webViewController = controller;
  }
  
  /// Handle app lifecycle state changes
  static void handleLifecycleChange(AppLifecycleState state) {
    if (_webViewController == null) return;
    
    try {
      switch (state) {
        case AppLifecycleState.resumed:
          _notifyJs('resumed');
          _webViewController!.resume();
          break;
        case AppLifecycleState.paused:
          _notifyJs('paused');
          _webViewController!.pause();
          break;
        case AppLifecycleState.inactive:
          _notifyJs('inactive');
          break;
        case AppLifecycleState.detached:
          _notifyJs('detached');
          break;
        default:
          // Handle any future lifecycle states
          _notifyJs(state.toString());
      }
    } catch (e) {
      debugPrint('Error handling lifecycle change: $e');
    }
  }
  
  /// Notify JavaScript of the app lifecycle state change
  static Future<void> _notifyJs(String state) async {
    if (_webViewController == null) return;
    
    try {
      await _webViewController!.evaluateJavascript(
        source: "window.dispatchEvent(new CustomEvent('appLifecycle', { detail: { state: '$state' } }));"
      );
      debugPrint('Lifecycle event sent to JS: $state');
    } catch (e) {
      debugPrint('Error sending lifecycle event to JS: $e');
    }
  }
  
  /// Clean up resources when no longer needed
  static void dispose() {
    _webViewController = null;
  }
}