import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dummy/dummy_data.dart';
import 'login_screen.dart';
import '../../../main.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final myTickets = dummyTickets
        .where((t) => t.createdBy == currentUser.id).toList();
    final open = myTickets.where((t) => t.status == 'open').length;
    final done = myTickets.where((t) =>
    t.status == 'resolved' || t.status == 'closed').length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(currentUser.initials,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(currentUser.name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(currentUser.email,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    _roleLabel(currentUser.role),
                    style: const TextStyle(color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats (user only)
          if (currentUser.role == 'user') ...[
            Row(children: [
              Expanded(child: _StatMini(label: 'Total Tiket', value: '${myTickets.length}',
                  color: const Color(0xFF4F46E5))),
              const SizedBox(width: 10),
              Expanded(child: _StatMini(label: 'Menunggu', value: '$open',
                  color: const Color(0xFFF59E0B))),
              const SizedBox(width: 10),
              Expanded(child: _StatMini(label: 'Selesai', value: '$done',
                  color: const Color(0xFF10B981))),
            ]),
            const SizedBox(height: 16),
          ],

          // Settings
          _SettingsCard(children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text('Mode Gelap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
              ),
              value: isDark,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).state =
                val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ]),
          const SizedBox(height: 10),

          _SettingsCard(children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
              ),
              title: const Text('Keluar',
                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () => _confirmLogout(context),
            ),
          ]),

          const SizedBox(height: 24),
          Center(
            child: Text('HelpDesk UNAIR v1.0.0',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return 'Administrator';
      case 'helpdesk': return 'Tim Helpdesk';
      default: return 'Pengguna';
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      ]),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }
}