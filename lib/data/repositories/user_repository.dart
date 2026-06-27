import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    final response = await _supabase
        .from('users')
        .select('id, name, email, role')
        .order('name', ascending: true);

    return (response as List)
        .map((json) => UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    ))
        .toList();
  }

  /// Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    final response = await _supabase
        .from('users')
        .select('id, name, email, role')
        .eq('role', role)
        .order('name', ascending: true);

    return (response as List)
        .map((json) => UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    ))
        .toList();
  }

  /// Get user by id
  Future<UserModel?> getUserById(String id) async {
    final response = await _supabase
        .from('users')
        .select('id, name, email, role')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return UserModel(
      id: response['id'].toString(),
      name: response['name'] ?? '',
      email: response['email'] ?? '',
      role: response['role'] ?? 'user',
    );
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final response = await _supabase
        .from('users')
        .select('id, name, email, role')
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;

    return UserModel(
      id: response['id'].toString(),
      name: response['name'] ?? '',
      email: response['email'] ?? '',
      role: response['role'] ?? 'user',
    );
  }

  /// Add new user via Supabase Auth + insert ke tabel users
  Future<UserModel> addUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    // 1. Daftarkan ke Supabase Auth
    final authResponse = await _supabase.auth.admin.createUser(
      AdminUserAttributes(
        email: email,
        password: password,
        emailConfirm: true,
      ),
    );

    final authUser = authResponse.user;
    if (authUser == null) throw Exception('Gagal membuat akun');

    // 2. Insert ke tabel users
    await _supabase.from('users').insert({
      'id': authUser.id,
      'name': name,
      'email': email,
      'role': role,
    });

    return UserModel(
      id: authUser.id,
      name: name,
      email: email,
      role: role,
    );
  }

  /// Update role user
  Future<void> updateUserRole(String userId, String newRole) async {
    await _supabase
        .from('users')
        .update({'role': newRole})
        .eq('id', userId);
  }

  /// Update nama user
  Future<void> updateUserName(String userId, String newName) async {
    await _supabase
        .from('users')
        .update({'name': newName})
        .eq('id', userId);
  }

  /// Non-aktifkan user (soft delete — set role jadi 'inactive')
  Future<void> deactivateUser(String userId) async {
    await _supabase
        .from('users')
        .update({'role': 'inactive'})
        .eq('id', userId);
  }

  /// Hapus user (hard delete)
  Future<void> deleteUser(String userId) async {
    // Hapus dari tabel users dulu
    await _supabase
        .from('users')
        .delete()
        .eq('id', userId);

    // Hapus dari Supabase Auth (butuh service role key)
    await _supabase.auth.admin.deleteUser(userId);
  }

  /// Cari user berdasarkan nama / email
  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _supabase
        .from('users')
        .select('id, name, email, role')
        .or('name.ilike.%$query%,email.ilike.%$query%')
        .order('name', ascending: true);

    return (response as List)
        .map((json) => UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    ))
        .toList();
  }

  /// Get jumlah tiket aktif per helpdesk (untuk dashboard admin)
  Future<List<Map<String, dynamic>>> getHelpdeskWithTicketCount() async {
    final response = await _supabase
        .from('users')
        .select('id, name, email, role')
        .eq('role', 'helpdesk')
        .order('name', ascending: true);

    final helpdesks = (response as List);

    // Hitung tiket aktif per helpdesk
    final result = await Future.wait(
      helpdesks.map((h) async {
        final ticketCount = await _supabase
            .from('tickets')
            .select('id')
            .eq('assigned_to', h['id'])
            .inFilter('status', ['assigned', 'in_progress', 'forwarded']);

        return {
          'id': h['id'].toString(),
          'name': h['name'] ?? '',
          'email': h['email'] ?? '',
          'role': h['role'] ?? 'helpdesk',
          'ticket_count': (ticketCount as List).length,
        };
      }),
    );

    return result;
  }
}