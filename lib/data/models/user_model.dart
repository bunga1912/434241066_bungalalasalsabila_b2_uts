class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'user' | 'helpdesk' | 'admin'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}