import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example_webview/main.dart';
import 'package:example_webview/screens/webview_screen.dart';

void main() {
  testWidgets('WebView app initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that WebViewScreen is the main widget
    expect(find.byType(WebViewScreen), findsOneWidget);
  });
}
