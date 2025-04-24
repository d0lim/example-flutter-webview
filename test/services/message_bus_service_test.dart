import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:example_webview/services/message_bus_service.dart';

// Mock InAppWebViewController 클래스
class MockInAppWebViewController extends Mock implements InAppWebViewController {}

void main() {
  late MockInAppWebViewController mockController;

  setUp(() {
    mockController = MockInAppWebViewController();
    
    // evaluateJavascript 메소드 모킹
    when(() => mockController.evaluateJavascript(source: any(named: 'source')))
        .thenAnswer((_) async => null);
  });

  group('MessageBusService', () {
    test('handleJsMessage should handle text message correctly', () async {
      // 텍스트 메시지 케이스 테스트
      final result = await MessageBusService.handleJsMessage([{'type': 'message', 'data': 'Hello from JS'}]);
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'OK');
      expect(result['message'], contains('Hello from JS'));
      expect(result['timestamp'], isA<int>());
    });

    test('handleJsMessage should return error for empty message', () async {
      // 빈 메시지 처리 테스트
      final result = await MessageBusService.handleJsMessage([{'type': 'message', 'data': ''}]);
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'ERROR');
      expect(result['message'], contains('Empty message'));
    });

    test('handleJsMessage should return error for unknown message type', () async {
      // 알 수 없는 메시지 타입 테스트
      final result = await MessageBusService.handleJsMessage([{'type': 'unknown', 'data': 'test'}]);
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'ERROR');
      expect(result['message'], contains('Unknown message type'));
    });

    test('handleJsMessage should return error for empty args', () async {
      // 빈 인자 테스트
      final result = await MessageBusService.handleJsMessage([]);
      
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], 'ERROR');
      expect(result['message'], contains('No arguments provided'));
    });

    test('sendToJs should call evaluateJavascript', () async {
      // sendToJs 메소드 테스트
      await MessageBusService.sendToJs(mockController, {'test': 'data'});
      
      verify(() => mockController.evaluateJavascript(source: any(named: 'source'))).called(1);
    });

    test('injectJsHandler should call evaluateJavascript', () async {
      // injectJsHandler 메소드 테스트
      await MessageBusService.injectJsHandler(mockController);
      
      verify(() => mockController.evaluateJavascript(source: any(named: 'source'))).called(1);
    });
  });
}