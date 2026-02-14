class UniversityRepresentative {
  final int id;
  final String name;
  final String university;
  final String? imageUrl;

  UniversityRepresentative({
    required this.id,
    required this.name,
    required this.university,
    this.imageUrl,
  });

  factory UniversityRepresentative.fromJson(Map<String, dynamic> json) {
    return UniversityRepresentative(
      id: json['id'],
      name: json['name'],
      university: json['university'],
      imageUrl: json['image_url'],
    );
  }
}
