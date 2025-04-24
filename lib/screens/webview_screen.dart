import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';
import '../services/clipboard_service.dart';
import '../services/file_upload_service.dart';
import '../services/lifecycle_service.dart';
import '../services/location_service.dart';
import '../services/message_bus_service.dart';

/// Main screen that contains the WebView with all native bridges
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with WidgetsBindingObserver {
  InAppWebViewController? _webViewController;
  final GlobalKey webViewKey = GlobalKey();
  
  // WebView settings
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      useOnLoadResource: true,
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
      cacheEnabled: true,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      // For development only - should be restricted in production
      safeBrowsingEnabled: false,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
      allowsAirPlayForMediaPlayback: true,
    ),
  );
  
  // Loading local HTML
  String? _localHtmlFilePath;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareLocalFiles();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LifecycleService.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    LifecycleService.handleLifecycleChange(state);
  }
  
  /// Prepare local HTML files for loading in the WebView
  Future<void> _prepareLocalFiles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      _localHtmlFilePath = '${directory.path}/index.html';
      
      // Use local file path for development
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error preparing local files: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Set up all JavaScript handlers for native functionality
  void _setupJsHandlers(InAppWebViewController controller) {
    // Message bus handler
    controller.addJavaScriptHandler(
      handlerName: AppConstants.jsHandlerNative,
      callback: MessageBusService.handleJsMessage,
    );
    
    // Location handler
    controller.addJavaScriptHandler(
      handlerName: AppConstants.jsHandlerGetLocation,
      callback: LocationService.handleGetLocation,
    );
    
    // Clipboard handlers
    controller.addJavaScriptHandler(
      handlerName: AppConstants.jsHandlerReadClipboard,
      callback: ClipboardService.handleReadClipboard,
    );
    controller.addJavaScriptHandler(
      handlerName: AppConstants.jsHandlerWriteClipboard,
      callback: ClipboardService.handleWriteClipboard,
    );
    
    // Set controllers for services that need to send data to JS
    LifecycleService.setController(controller);
    
    // Inject JS helper functions
    MessageBusService.injectJsHandler(controller);
    LocationService.injectJsHandler(controller);
    ClipboardService.injectJsHandlers(controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView Bridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController?.reload();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : InAppWebView(
              key: webViewKey,
              initialOptions: options,
              // Choose between remote URL or local content
              // initialUrlRequest: URLRequest(url: Uri.parse(AppConstants.initialUrl)),
              // For development - load from local asset
              initialFile: AppConstants.localWebPath,
              onWebViewCreated: (controller) {
                _webViewController = controller;
                _setupJsHandlers(controller);
              },
              onLoadStart: (controller, url) {
                debugPrint('Page started loading: $url');
              },
              onLoadStop: (controller, url) async {
                debugPrint('Page finished loading: $url');
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint('WebView Console: ${consoleMessage.message}');
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                
                // Handle external links (e.g., tel:, mailto:, etc.)
                if (uri != null && !['http', 'https', 'file', 'chrome', 'data', 'javascript', 'about'].contains(uri.scheme)) {
                  // Handle external links
                  debugPrint('Opening external URL: $uri');
                  return NavigationActionPolicy.CANCEL;
                }
                
                return NavigationActionPolicy.ALLOW;
              },
              onLoadError: (controller, url, code, message) {
                debugPrint('Page load error: $code - $message');
              },
              onCreateWindow: (controller, createWindowAction) async {
                // Handle new window creation (e.g., target="_blank" links)
                debugPrint('New window requested');
                return false;
              },
              onJsAlert: (controller, jsAlertRequest) async {
                // Handle JavaScript alerts
                return JsAlertResponse(handledByClient: false);
              },
              androidOnPermissionRequest: (controller, origin, resources) async {
                // Handle Android permission requests from WebView
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
            ),
    );
  }
}