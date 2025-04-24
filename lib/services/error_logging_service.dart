import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/constants.dart';

/// Service that handles error logging and crash reporting
class ErrorLoggingService {
  /// Initialize error logging service
  static Future<void> initialize() async {
    // Pass all uncaught Flutter errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  
  /// Log error to Crashlytics
  static void logError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: false,
      );
    } catch (e) {
      debugPrint('Error logging to Crashlytics: $e');
    }
  }
  
  /// Set up JavaScript error capturing
  static void setupJsErrorCapturing(InAppWebViewController controller) {
    // Log console messages to Crashlytics
    controller.addJavaScriptHandler(
      handlerName: AppConstants.jsHandlerJsError,
      callback: (args) {
        if (args.isNotEmpty && args[0] is Map) {
          final errorData = args[0] as Map;
          final errorMessage = errorData['message'] ?? 'Unknown JS Error';
          final errorSource = errorData['source'] ?? 'Unknown';
          final errorLine = errorData['lineno'] ?? '?';
          final errorColumn = errorData['colno'] ?? '?';
          
          FirebaseCrashlytics.instance.recordError(
            'JavaScript Error: $errorMessage',
            StackTrace.current,
            reason: 'JS Error at $errorSource:$errorLine:$errorColumn',
          );
          
          debugPrint('Logged JS error: $errorMessage');
        }
        return {'logged': true};
      },
    );
    
    // Inject JS error handler
    controller.evaluateJavascript(source: '''
      window.addEventListener('error', function(event) {
        window.flutter_inappwebview.callHandler(
          '${AppConstants.jsHandlerJsError}', 
          {
            message: event.message,
            source: event.filename,
            lineno: event.lineno,
            colno: event.colno,
            error: event.error ? event.error.toString() : null
          }
        );
        
        // Don't prevent default handling
        return false;
      });
    ''');
  }
  
  /// Handle console messages from WebView
  static ConsoleMessageLevel? handleConsoleMessage(ConsoleMessage message) {
    // Log console messages
    debugPrint('WebView Console [${message.messageLevel.name}]: ${message.message}');
    
    // Log errors to Crashlytics
    if (message.messageLevel == ConsoleMessageLevel.ERROR) {
      FirebaseCrashlytics.instance.recordError(
        "WebView JS Error: ${message.message}",
        StackTrace.current,
        reason: "JavaScript Console Error",
      );
    }
    
    return null; // Return null to allow default handling
  }
}