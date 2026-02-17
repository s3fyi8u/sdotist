import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';

class UploadService {
  final ApiClient _apiClient = ApiClient();

  Future<String> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiConstants.upload,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      return response.data['url'];
    } catch (e) {
      rethrow;
    }
  }
}
