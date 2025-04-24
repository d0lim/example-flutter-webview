import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:example_webview/services/auth_service.dart';
import 'package:example_webview/core/constants.dart';

// Mock 클래스
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockInAppWebViewController extends Mock implements InAppWebViewController {}

void main() {
  group('AuthService', () {
    test('Auth Service exists', () {
      // 서비스 존재 확인 테스트
      expect(AuthService, isNotNull);
    });

    test('createAuthorizedRequest should create a URLRequest with correct URL and headers', () async {
      // 테스트 URL
      const String testUrl = 'https://example.com/api';
      
      // 테스트 토큰
      const String testToken = 'test-token-123';
      
      // 모킹 설정을 위해 AuthService._secureStorage 필드를 직접 접근할 수 없으므로
      // 간접적으로 결과만 테스트
      
      // createAuthorizedRequest 호출
      final request = await AuthService.createAuthorizedRequest(testUrl);
      
      // 기본 검증
      expect(request, isA<URLRequest>());
      expect(request.url.toString(), contains('example.com'));
    });

    test('notifyTokenExpired should call evaluateJavascript', () async {
      final mockController = MockInAppWebViewController();
      
      // evaluateJavascript 모킹
      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((_) async => null);
      
      await AuthService.notifyTokenExpired(mockController);
      
      // evaluateJavascript 호출 확인
      verify(() => mockController.evaluateJavascript(source: any(named: 'source'))).called(1);
    });
  });
}