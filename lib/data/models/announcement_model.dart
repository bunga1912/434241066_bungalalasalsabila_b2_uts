class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String? createdBy;
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    this.createdBy,
    required this.createdAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
    };
  }
}