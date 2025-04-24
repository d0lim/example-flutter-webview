import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Service that handles file uploads from WebView
class FileUploadService {
  /// Handle a file choose request from WebView
  /// 파일 선택 요청 처리
  /// Flutter InAppWebView 라이브러리 버전에 따라 이 메소드 시그니처와 반환 타입이 달라질 수 있음
  static Future<dynamic> handleFileChooser(dynamic params) async {
    try {
      List<String>? paths;
      List<PlatformFile>? files;
      
      // params의 타입에 따라 적절히 처리
      bool allowMultiple = false;
      List<String>? acceptTypes = [];
      
      // 파라미터 타입에 따른 동적 처리
      if (params != null) {
        // InAppWebView 6.0.0 버전에서는 다른 방식으로 처리될 수 있음
        if (params is Map) {
          allowMultiple = params['allowMultiple'] ?? false;
          acceptTypes = (params['acceptTypes'] as List?)?.cast<String>();
        } else {
          // 가능한 경우 타입 확인
          try {
            // 리플렉션 또는 동적 접근을 통한 속성 접근
            allowMultiple = (params as dynamic).allowMultiple ?? false;
            acceptTypes = (params as dynamic).acceptTypes as List<String>?;
          } catch (e) {
            debugPrint('Error extracting params: $e');
          }
        }
      }
      
      if (allowMultiple) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: _parseAcceptTypes(acceptTypes),
          allowMultiple: true,
        );
        files = result?.files;
        paths = files?.map((file) => file.path!).toList();
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: _parseAcceptTypes(acceptTypes),
        );
        files = result?.files;
        paths = files?.isNotEmpty == true ? [files!.first.path!] : null;
      }
      
      if (paths != null) {
        debugPrint('Files selected: ${paths.length}');
      } else {
        debugPrint('No files selected');
      }
      
      // 동적 반환 타입
      return {
        'paths': paths,
        'handledByClient': true,
      };
    } catch (e) {
      debugPrint('File picking error: $e');
      return {
        'handledByClient': false,
      };
    }
  }
  
  /// Parse WebView accept types to file picker extensions
  static List<String> _parseAcceptTypes(List<String>? acceptTypes) {
    if (acceptTypes == null || acceptTypes.isEmpty) {
      return [];
    }
    
    final extensions = <String>[];
    for (final type in acceptTypes) {
      if (type.startsWith('.')) {
        extensions.add(type.substring(1));
      } else if (type.contains('/')) {
        // Handle MIME types like 'image/*'
        final parts = type.split('/');
        if (parts.length == 2 && parts[1] == '*') {
          switch (parts[0]) {
            case 'image':
              extensions.addAll(['jpg', 'jpeg', 'png', 'gif', 'webp']);
              break;
            case 'video':
              extensions.addAll(['mp4', 'mov', 'avi', 'mkv']);
              break;
            case 'audio':
              extensions.addAll(['mp3', 'wav', 'ogg', 'aac']);
              break;
          }
        }
      }
    }
    
    return extensions;
  }
}