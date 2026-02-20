import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/event_model.dart';

class EventsService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Event>> getEvents() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.events);
      final List<dynamic> data = response.data;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> getEvent(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.events}$id');
      return Event.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> createEvent(String title, String description, DateTime date, String location, {String? imageUrl}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.events,
        data: {
          'title': title,
          'description': description,
          'date': date.toIso8601String(),
          'location': location,
          'image_url': imageUrl,
        },
      );
      return Event.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> updateEvent(int id, String title, String description, DateTime date, String location, {String? imageUrl}) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.events}$id',
        data: {
          'title': title,
          'description': description,
          'date': date.toIso8601String(),
          'location': location,
          'image_url': imageUrl,
        },
      );
      return Event.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.events}$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerForEvent(int eventId) async {
    try {
      await _apiClient.dio.post('${ApiConstants.events}$eventId/register');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unregisterFromEvent(int eventId) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.events}$eventId/register');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventRegistration>> getEventRegistrations(int eventId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.events}$eventId/registrations');
      final List<dynamic> data = response.data;
      return data.map((json) => EventRegistration.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<EventRegistration> verifyAttendance(int eventId, String barcodeId) async {
    try {
      // Send barcodeId as query parameter
      final response = await _apiClient.dio.post(
        '${ApiConstants.events}$eventId/verify',
        queryParameters: {'barcode_id': barcodeId},
      );
      return EventRegistration.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> endEvent(int id) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.events}$id',
        data: {'is_ended': true},
      );
      return Event.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
