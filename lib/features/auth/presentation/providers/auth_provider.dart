import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/models/user_model.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final currentUserProvider = StateProvider<UserModel?>((ref) => null);

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseClient _supabase;
  final Ref _ref;

  AuthNotifier(this._supabase, this._ref)
      : super(const AsyncValue.loading()) {
    _checkCurrentSession();
  }

  Future<void> _checkCurrentSession() async {
    try {
      final session = _supabase.auth.currentSession;

      if (session == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final userData = await _getUserData(session.user.id);

      state = AsyncValue.data(userData);
      _ref.read(currentUserProvider.notifier).state = userData;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserModel?> _getUserData(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel(
        id: response['id'].toString(),
        name: response['name'] ?? '',
        email: response['email'] ?? '',
        role: response['role'] ?? 'user',
      );
    } catch (e) {
      print('GET USER ERROR: $e');
      return null;
    }
  }

  Future<UserModel> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;

      if (authUser == null) {
        throw Exception('Login gagal');
      }

      final userData = await _getUserData(authUser.id);

      if (userData == null) {
        throw Exception(
          'Data pengguna tidak ditemukan pada tabel users',
        );
      }

      state = AsyncValue.data(userData);
      _ref.read(currentUserProvider.notifier).state = userData;

      return userData;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = response.user;

      if (authUser != null) {
        await _supabase.from('users').insert({
          'id': authUser.id,
          'name': name,
          'email': email,
          'role': 'user',
        });
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> sendResetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();

    _ref.read(currentUserProvider.notifier).state = null;
    state = const AsyncValue.data(null);
  }
}

final authProvider =
StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
      (ref) {
    final supabase = ref.watch(supabaseClientProvider);
    return AuthNotifier(supabase, ref);
  },
);