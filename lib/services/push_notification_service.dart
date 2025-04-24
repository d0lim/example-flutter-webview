import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/constants.dart';

/// Service that handles push notifications
class PushNotificationService {
  static FirebaseMessaging? _messaging;
  static InAppWebViewController? _webViewController;
  
  /// Initialize Firebase Messaging
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      
      // Request permission
      await _requestPermission();
      
      // Get FCM token
      final token = await _messaging!.getToken();
      debugPrint('FCM Token: $token');
      
      // Subscribe to topic for broadcast messages
      await _messaging!.subscribeToTopic(AppConstants.notificationTopic);
      
      // Configure message handlers
      _configureMessageHandlers();
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
    }
  }
  
  /// Request permission to receive notifications
  static Future<void> _requestPermission() async {
    final settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }
  
  /// Configure foreground and background message handlers
  static void _configureMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle when user taps on notification (app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }
  
  /// Handle a message received when app is in foreground
  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    _sendNotificationToJs(message);
  }
  
  /// Handle when user taps on notification (app was in background)
  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.notification?.title}');
    _sendNotificationToJs(message);
  }
  
  /// Send notification data to JavaScript
  static void _sendNotificationToJs(RemoteMessage message) {
    if (_webViewController == null) return;
    
    try {
      final payload = jsonEncode({
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
      });
      
      _webViewController!.evaluateJavascript(
        source: "window.dispatchEvent(new CustomEvent('push', { detail: $payload }));"
      );
    } catch (e) {
      debugPrint('Error sending notification to JS: $e');
    }
  }
  
  /// Set the WebView controller for sending notifications
  static void setController(InAppWebViewController controller) {
    _webViewController = controller;
  }
  
  /// Clean up resources when no longer needed
  static void dispose() {
    _webViewController = null;
  }
}