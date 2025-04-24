import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/constants.dart';

/// Service that handles clipboard operations
class ClipboardService {
  /// Handles a request to read from the clipboard
  static Future<Map<String, dynamic>> handleReadClipboard(List<dynamic> args) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return {
        'status': 'OK',
        'text': data?.text ?? '',
      };
    } catch (e) {
      debugPrint('Clipboard read error: $e');
      return {
        'status': 'ERROR',
        'message': e.toString(),
      };
    }
  }

  /// Handles a request to write to the clipboard
  static Future<Map<String, dynamic>> handleWriteClipboard(List<dynamic> args) async {
    try {
      if (args.isEmpty || args[0] == null) {
        return {
          'status': 'ERROR',
          'message': 'No text provided',
        };
      }
      
      await Clipboard.setData(ClipboardData(text: args[0].toString()));
      return {
        'status': 'OK',
      };
    } catch (e) {
      debugPrint('Clipboard write error: $e');
      return {
        'status': 'ERROR',
        'message': e.toString(),
      };
    }
  }

  /// Injects the JavaScript functions for clipboard operations
  static Future<void> injectJsHandlers(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      window.nativeClipboard = {
        readText: function() {
          return window.flutter_inappwebview.callHandler('${AppConstants.jsHandlerReadClipboard}');
        },
        writeText: function(text) {
          return window.flutter_inappwebview.callHandler('${AppConstants.jsHandlerWriteClipboard}', text);
        }
      };
    ''');
  }
}