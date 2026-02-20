class Event {
  final int id;
  final String title;
  final String? description;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEnded;
  final List<EventRegistration> registrations;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.location,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isEnded = false,
    this.registrations = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isEnded: json['is_ended'] ?? false,
      registrations: (json['registrations'] as List<dynamic>?)
              ?.map((e) => EventRegistration.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EventRegistration {
  final int id;
  final int userId;
  final int eventId;
  final DateTime registeredAt;
  final bool attended;
  final EventUser user;

  EventRegistration({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    required this.attended,
    required this.user,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      registeredAt: DateTime.parse(json['registered_at']),
      attended: json['attended'],
      user: EventUser.fromJson(json['user']),
    );
  }
}

class EventUser {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final String? barcodeId;

  EventUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.barcodeId,
  });

  factory EventUser.fromJson(Map<String, dynamic> json) {
    return EventUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      barcodeId: json['barcode_id'],
    );
  }
}
