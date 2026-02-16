import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _token;
  String? _role;

  AuthProvider() {
    loadToken();
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _role == 'admin';

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'username': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      _token = response.data['access_token'];
      await _apiClient.storage.write(key: 'access_token', value: _token);
      
      // Fetch user role immediately after login
      await fetchUserProfile();
      
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.me);
      _role = response.data['role'];
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      rethrow;
    }
  }

  Future<String> register({
    required String name,
    required String email,
    required String password,
    dynamic documentFile, // PlatformFile? or XFile?
    dynamic profileImageFile, // XFile? or File?
    String? dateOfBirth,
    String? university,
    String? degree,
    String? specialization,
    String? academicYear,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Build multipart form data
      final Map<String, dynamic> formMap = {
        'name': name,
        'email': email,
        'password': password,
      };

      if (dateOfBirth != null) formMap['date_of_birth'] = dateOfBirth;
      if (university != null) formMap['university'] = university;
      if (degree != null) formMap['degree'] = degree;
      if (specialization != null && specialization.isNotEmpty) {
        formMap['specialization'] = specialization;
      }
      if (academicYear != null) formMap['academic_year'] = academicYear;

      // Add document file
      if (documentFile != null) {
        if (documentFile.runtimeType.toString() == 'PlatformFile') {
           final file = documentFile; // PlatformFile
           if (file.bytes != null) {
             formMap['document'] = MultipartFile.fromBytes(
               file.bytes!,
               filename: file.name,
             );
           } else if (file.path != null) {
             formMap['document'] = await MultipartFile.fromFile(
               file.path!,
               filename: file.name,
             );
           }
        }
      }

      // Add profile image
      if (profileImageFile != null) {
         // Assuming XFile
         // We can use readAsBytes for both web and mobile on XFile
         // But need to handle if it is passed as something else
         if (profileImageFile.runtimeType.toString().contains('XFile')) {
            final file = profileImageFile; 
            final bytes = await file.readAsBytes();
            formMap['profile_image'] = MultipartFile.fromBytes(
              bytes,
              filename: file.name,
            );
         }
      }

      final formData = FormData.fromMap(formMap);

      final response = await _apiClient.dio.post(
        ApiConstants.registerWithDoc,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

      debugPrint("Registration successful");
      return response.data['message'] ?? 'Registration submitted';
    } catch (e) {
      debugPrint("Registration error in AuthProvider: $e");
      if (e is DioException) {
        debugPrint("DioError response: ${e.response?.data}");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    await _apiClient.storage.delete(key: 'access_token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _token = await _apiClient.storage.read(key: 'access_token');
      if (_token != null) {
        await fetchUserProfile();
      }
    } catch (e) {
      debugPrint("Error loading token: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
