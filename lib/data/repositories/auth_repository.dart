import '../models/user_model.dart';

class AuthRepository {
  // Dummy users untuk testing login
  static final List<UserModel> _dummyUsers = [
    UserModel(
      id: '1',
      name: 'Admin Sistem',
      email: 'admin@helpdesk.com',
      role: 'admin',
    ),
    UserModel(
      id: '2',
      name: 'Rina Wulandari',
      email: 'rina@helpdesk.com',
      role: 'helpdesk',
    ),
    UserModel(
      id: '3',
      name: 'Fajar Nugroho',
      email: 'fajar@helpdesk.com',
      role: 'technical_support',
    ),
    UserModel(
      id: '4',
      name: 'Budi Santoso',
      email: 'budi@mail.com',
      role: 'user',
    ),
  ];

  /// Login dengan email & password
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = _dummyUsers.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('Email atau password salah'),
    );

    // Simulasi validasi password (dummy: semua password = "password123")
    if (password != 'password123') {
      throw Exception('Email atau password salah');
    }

    return user;
  }

  /// Register pengguna baru (role default: user)
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final exists = _dummyUsers.any(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      throw Exception('Email sudah terdaftar');
    }

    final newUser = UserModel(
      id: '${_dummyUsers.length + 1}',
      name: name,
      email: email,
      role: 'user',
    );

    _dummyUsers.add(newUser);
    return newUser;
  }

  /// Kirim email reset password
  Future<void> sendResetPasswordEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    final exists = _dummyUsers.any(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (!exists) {
      throw Exception('Email tidak ditemukan');
    }
  }

  /// Logout
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get current logged in user (dummy: selalu return admin)
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyUsers.first;
  }
}