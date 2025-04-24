import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/constants.dart';

/// Service that handles message passing between WebView and Flutter
class MessageBusService {
  /// Handles messages received from JavaScript
  static Future<dynamic> handleJsMessage(List<dynamic> args) async {
    try {
      if (args.isEmpty) {
        return {'status': 'ERROR', 'message': 'No arguments provided'};
      }

      final message = args[0];
      debugPrint('Received from JS: $message');
      
      // You can parse the message and handle different types
      if (message is Map) {
        final type = message['type'];
        final data = message['data'];
        
        switch (type) {
          case 'message':
            return _handleTextMessage(data);
          default:
            return {'status': 'ERROR', 'message': 'Unknown message type'};
        }
      }
      
      return {'status': 'OK', 'received': message};
    } catch (e) {
      debugPrint('Error handling JS message: $e');
      return {'status': 'ERROR', 'message': e.toString()};
    }
  }
  
  /// Handles text messages from JavaScript
  static Map<String, dynamic> _handleTextMessage(String? message) {
    if (message == null || message.isEmpty) {
      return {'status': 'ERROR', 'message': 'Empty message'};
    }
    
    // Process the message as needed
    debugPrint('Processing text message: $message');
    
    return {
      'status': 'OK',
      'message': 'Message received: $message',
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
  }
  
  /// Sends a message to JavaScript
  static Future<void> sendToJs(InAppWebViewController controller, dynamic message) async {
    try {
      final jsonMessage = jsonEncode(message);
      
      // Send the message using the injected function
      await controller.evaluateJavascript(
        source: "window.postMessageFromFlutter($jsonMessage);"
      );
      
      debugPrint('Sent to JS: $message');
    } catch (e) {
      debugPrint('Error sending to JS: $e');
    }
  }
  
  /// Injects the JavaScript function that will receive messages from Flutter
  static Future<void> injectJsHandler(InAppWebViewController controller) async {
    await controller.evaluateJavascript(
      source: """
        window.postMessageFromFlutter = function(msg) {
          console.log('Message from Flutter:', msg);
          if (typeof msg === 'string') {
            try {
              msg = JSON.parse(msg);
            } catch(e) {
              // Keep as string if not valid JSON
            }
          }
          
          // Dispatch event for other JS code to listen
          window.dispatchEvent(new CustomEvent('flutterMessage', { 
            detail: msg 
          }));
          
          return true;
        };
      """
    );
  }
}