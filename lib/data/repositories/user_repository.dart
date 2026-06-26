import '../models/user_model.dart';

class UserRepository {
  static final List<UserModel> _users = [
    UserModel(id: '1', name: 'Budi Santoso', email: 'budi@mail.com', role: 'user'),
    UserModel(id: '2', name: 'Siti Rahma', email: 'siti@mail.com', role: 'user'),
    UserModel(id: '3', name: 'Rina Wulandari', email: 'rina@helpdesk.com', role: 'helpdesk'),
    UserModel(id: '4', name: 'Joko Susanto', email: 'joko@helpdesk.com', role: 'helpdesk'),
    UserModel(id: '5', name: 'Fajar Nugroho', email: 'fajar@ts.com', role: 'technical_support'),
    UserModel(id: '6', name: 'Dimas Pratama', email: 'dimas@ts.com', role: 'technical_support'),
    UserModel(id: '7', name: 'Admin Sistem', email: 'admin@helpdesk.com', role: 'admin'),
  ];

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_users);
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _users.where((u) => u.role == role).toList();
  }

  /// Get user by id
  Future<UserModel?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new user (e.g. by Admin)
  Future<UserModel> addUser({
    required String name,
    required String email,
    required String role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final newUser = UserModel(
      id: '${_users.length + 1}',
      name: name,
      email: email,
      role: role,
    );

    _users.add(newUser);
    return newUser;
  }

  /// Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = await getUserById(userId);
    if (user != null) {
      _users[_users.indexOf(user)] = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        role: newRole,
      );
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _users.removeWhere((u) => u.id == userId);
  }
}