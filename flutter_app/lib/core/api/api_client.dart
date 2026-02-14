import 'package:dio/dio.dart';
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
          // TODO: Trigger logout
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
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        "/upload", // Using relative path since baseUrl is set
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
      return null; // Or rethrow
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
