import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/representative.dart';

class RepresentativeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<UniversityRepresentative>> getRepresentatives() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.representatives);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => UniversityRepresentative.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        throw Exception('Failed to load representatives: ${e.message}');
      }
      throw Exception('An unexpected error occurred');
    }
  }
}
