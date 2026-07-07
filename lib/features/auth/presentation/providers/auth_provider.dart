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
    print('GET_USER_DATA: mulai query untuk userId=$userId');
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('GET_USER_DATA: TIMEOUT setelah 15 detik');
          throw Exception('Timeout mengambil data pengguna');
        },
      );

      print('GET_USER_DATA: response diterima = $response');

      if (response == null) {
        print('GET_USER_DATA: response null (row tidak ditemukan)');
        return null;
      }

      final user = UserModel(
        id: response['id'].toString(),
        name: response['name'] ?? '',
        email: response['email'] ?? '',
        role: response['role'] ?? 'user',
      );

      print('GET_USER_DATA: berhasil parse UserModel, role=${user.role}');
      return user;
    } catch (e) {
      print('GET_USER_DATA ERROR: $e');
      return null;
    }
  }

  Future<UserModel> login(String email, String password) async {
    print('LOGIN: mulai proses login untuk email=$email');
    state = const AsyncValue.loading();

    try {
      print('LOGIN: memanggil signInWithPassword...');
      final response = await _supabase.auth
          .signInWithPassword(
        email: email,
        password: password,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('LOGIN: TIMEOUT signInWithPassword setelah 15 detik');
          throw Exception(
              'Koneksi timeout saat login. Cek koneksi internet kamu.');
        },
      );

      print('LOGIN: signInWithPassword selesai, user=${response.user?.id}');

      final authUser = response.user;

      if (authUser == null) {
        print('LOGIN: authUser null, throw Login gagal');
        throw Exception('Login gagal');
      }

      print('LOGIN: mulai _getUserData untuk id=${authUser.id}');
      final userData = await _getUserData(authUser.id);
      print('LOGIN: _getUserData selesai, userData=$userData');

      if (userData == null) {
        print('LOGIN: userData null, throw data tidak ditemukan');
        throw Exception(
          'Data pengguna tidak ditemukan pada tabel users',
        );
      }

      state = AsyncValue.data(userData);
      _ref.read(currentUserProvider.notifier).state = userData;

      print('LOGIN: SUKSES, role=${userData.role}');
      return userData;
    } catch (e, st) {
      print('LOGIN CATCH: $e');
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
      final response = await _supabase.auth
          .signUp(
        email: email,
        password: password,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
              'Koneksi timeout saat registrasi. Cek koneksi internet kamu.');
        },
      );

      final authUser = response.user;

      if (authUser != null) {
        await _supabase.from('users').insert({
          'id': authUser.id,
          'name': name,
          'email': email,
          'role': 'user',
        }).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception(
                'Koneksi timeout saat menyimpan data pengguna.');
          },
        );
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> sendResetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Koneksi timeout saat mengirim reset password.');
      },
    );
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