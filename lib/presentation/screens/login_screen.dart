import 'package:flutter/material.dart';
import '../../data/dummy/dummy_data.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError('Email dan password tidak boleh kosong');
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      final user = dummyUsers.firstWhere(
            (u) => u.email == _emailController.text.trim(),
        orElse: () => dummyUsers[0],
      );
      currentUser = user;
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo area
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 28),
              const Text(
                'Selamat datang\nkembali 👋',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke akun HelpDesk UNAIR Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),
              // Demo accounts info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF4F46E5)),
                        SizedBox(width: 6),
                        Text('Akun Demo', style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _demoAccountRow('User', 'angga@mail.com'),
                    _demoAccountRow('Helpdesk', 'siti@mail.com'),
                    _demoAccountRow('Admin', 'admin@mail.com'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Login button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Masuk'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text(
                      'Daftar sekarang',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _demoAccountRow(String role, String email) {
    return GestureDetector(
      onTap: () => setState(() => _emailController.text = email),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                role,
                style: const TextStyle(fontSize: 10, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(email, style: const TextStyle(fontSize: 11, color: Color(0xFF4338CA))),
          ],
        ),
      ),
    );
  }
}