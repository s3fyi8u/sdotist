class ExecutiveOffice {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<OfficeMember> members;

  ExecutiveOffice({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.members = const [],
  });

  factory ExecutiveOffice.fromJson(Map<String, dynamic> json) {
    return ExecutiveOffice(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => OfficeMember.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class OfficeMember {
  final int id;
  final int officeId;
  final String name;
  final String? position;
  final String? imageUrl;
  final String? email;
  final String? phone;
  final String role; // 'manager' or 'member'

  OfficeMember({
    required this.id,
    required this.officeId,
    required this.name,
    this.position,
    this.imageUrl,
    this.email,
    this.phone,
    this.role = 'member',
  });

  factory OfficeMember.fromJson(Map<String, dynamic> json) {
    return OfficeMember(
      id: json['id'],
      officeId: json['office_id'],
      name: json['name'],
      position: json['position'],
      imageUrl: json['image_url'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'member',
    );
  }
  
  bool get isManager => role == 'manager';
}
