import 'package:flutter_test/flutter_test.dart';

// 각 서비스 테스트 파일들 import
import 'core/constants_test.dart' as constants;
import 'services/message_bus_service_test.dart' as message_bus;
import 'services/clipboard_service_test.dart' as clipboard;
import 'services/location_service_test.dart' as location;
import 'services/file_upload_service_test.dart' as file_upload;
import 'services/auth_service_test.dart' as auth;
import 'services/lifecycle_service_test.dart' as lifecycle;

void main() {
  group('All Tests', () {
    group('Core Tests', () {
      // constants_test.dart의 테스트 실행
      constants.main();
    });
    
    group('Service Tests', () {
      group('MessageBusService Tests', () {
        message_bus.main();
      });
      
      group('ClipboardService Tests', () {
        clipboard.main();
      });
      
      group('LocationService Tests', () {
        location.main();
      });
      
      group('FileUploadService Tests', () {
        file_upload.main();
      });
      
      group('AuthService Tests', () {
        auth.main();
      });
      
      group('LifecycleService Tests', () {
        lifecycle.main();
      });
    });
  });
}