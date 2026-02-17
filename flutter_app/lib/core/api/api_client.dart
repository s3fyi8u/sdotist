import 'package:dio/dio.dart';
import '../../main.dart'; // Import for navigatorKey
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors (e.g., 401 Unauthorized)
        if (e.response?.statusCode == 401) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/session_expired', (route) => false);
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  Future<String?> uploadImage(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      late FormData formData;
      
      if (kIsWeb) {
        // On web, filePath is actually a blob URL - we can't use fromFile
        // Use uploadImageBytes instead for web
        return null;
      } else {
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(filePath, filename: fileName),
        });
      }

      final response = await _dio.post(
        "/upload",
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          }
        )
      );
      
      return response.data["url"];
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<String?> uploadImageBytes(List<int> bytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final response = await _dio.post(
        "/upload",
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          }
        )
      );
      
      return response.data["url"];
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }
  Future<Response> changePassword(String currentPassword, String newPassword) async {
    return await _dio.patch(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }
}
