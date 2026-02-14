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

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? profileImagePath,
    String? dateOfBirth,
    String? university,
    String? degree,
    String? specialization,
    String? academicYear,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      if (profileImagePath != null) {
        imageUrl = await _apiClient.uploadImage(profileImagePath);
      }

      await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': 'user', // Default role is user
          'date_of_birth': dateOfBirth,
          'university': university,
          'degree': degree,
          'specialization': specialization,
          'academic_year': academicYear,
          'profile_image': imageUrl, 
        },
      );
      print("Registration successful");
      // Optional: Auto login logic could be added here
    } catch (e) {
      print("Registration error in AuthProvider: $e");
      if (e is DioException) {
        print("DioError response: ${e.response?.data}");
        print("DioError message: ${e.message}");
        print("DioError type: ${e.type}");
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
