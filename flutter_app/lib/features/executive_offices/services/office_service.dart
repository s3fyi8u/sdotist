
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/office_models.dart';

class OfficeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ExecutiveOffice>> getOffices() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.offices);
      final List<dynamic> data = response.data;
      return data.map((json) => ExecutiveOffice.fromJson(json)).toList();
    } catch (e) {
      // Handle or rethrow
      rethrow;
    }
  }

  Future<ExecutiveOffice> getOfficeDetails(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.offices}/$id');
      return ExecutiveOffice.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
