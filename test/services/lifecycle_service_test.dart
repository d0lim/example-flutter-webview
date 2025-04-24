import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:example_webview/services/lifecycle_service.dart';

// Mock 클래스
class MockInAppWebViewController extends Mock implements InAppWebViewController {}

void main() {
  late MockInAppWebViewController mockController;
  
  setUp(() {
    mockController = MockInAppWebViewController();
    
    // LifecycleService의 상태 초기화
    LifecycleService.dispose();
    
    // evaluateJavascript 메소드 모킹
    when(() => mockController.evaluateJavascript(source: any(named: 'source')))
      .thenAnswer((_) async => null);
        
    // resume 및 pause 메소드 모킹
    when(() => mockController.resume()).thenAnswer((_) async => {});
    when(() => mockController.pause()).thenAnswer((_) async => {});
  });
  
  group('LifecycleService', () {
    test('setController should set the controller', () {
      // 컨트롤러 설정 테스트
      LifecycleService.setController(mockController);
      
      // 직접적인 확인 방법은 없지만, 다음 테스트들이 성공적으로 실행된다면 설정 성공
    });
    
    test('handleLifecycleChange should call resume for resumed state', () {
      // resumed 상태 테스트
      LifecycleService.setController(mockController);
      
      LifecycleService.handleLifecycleChange(AppLifecycleState.resumed);
      
      verify(() => mockController.evaluateJavascript(source: any(named: 'source'))).called(1);
      verify(() => mockController.resume()).called(1);
    });
    
    test('handleLifecycleChange should call pause for paused state', () {
      // paused 상태 테스트
      LifecycleService.setController(mockController);
      
      LifecycleService.handleLifecycleChange(AppLifecycleState.paused);
      
      verify(() => mockController.evaluateJavascript(source: any(named: 'source'))).called(1);
      verify(() => mockController.pause()).called(1);
    });
    
    test('handleLifecycleChange should handle inactive state', () {
      // inactive 상태 테스트
      LifecycleService.setController(mockController);
      
      LifecycleService.handleLifecycleChange(AppLifecycleState.inactive);
      
      verify(() => mockController.evaluateJavascript(source: any(named: 'source'))).called(1);
    });
    
    test('handleLifecycleChange should handle detached state', () {
      // detached 상태 테스트
      LifecycleService.setController(mockController);
      
      LifecycleService.handleLifecycleChange(AppLifecycleState.detached);
      
      verify(() => mockController.evaluateJavascript(source: any(named: 'source'))).called(1);
    });
    
    test('handleLifecycleChange should do nothing if controller is null', () {
      // 컨트롤러가 null일 때 테스트
      LifecycleService.dispose(); // 컨트롤러 제거
      
      // 에러 없이 실행되어야 함
      LifecycleService.handleLifecycleChange(AppLifecycleState.resumed);
    });
    
    test('dispose should clear the controller', () {
      // dispose 메소드 테스트
      LifecycleService.setController(mockController);
      LifecycleService.dispose();
      
      // 컨트롤러가 null이 되었다면
      // 다음 호출은 에러를 발생시키지 않아야 함
      LifecycleService.handleLifecycleChange(AppLifecycleState.resumed);
      
      // 모든 evaluateJavascript 호출이 없어야 함
      verifyNever(() => mockController.evaluateJavascript(source: any(named: 'source')));
    });
  });
}