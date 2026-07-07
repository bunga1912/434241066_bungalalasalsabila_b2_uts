import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/admin_dashboard_screen.dart';
import 'pages/admin_ticket_list_screen.dart';
import 'pages/admin_manage_users_screen.dart';
import 'pages/admin_history_screen.dart';
import '../../shared/presentation/pages/profile_screen.dart';

final adminNavIndexProvider = StateProvider<int>((ref) => 0);

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key});

  static const Color primaryNavy = Color(0xFF042C53);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminNavIndexProvider);

    final pages = [
      const AdminDashboardScreen(),
      const AdminTicketListScreen(),
      const AdminManageUsersScreen(),
      const AdminHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: primaryNavy.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  ref: ref,
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                ),
                _navItem(
                  ref: ref,
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.confirmation_number_rounded,
                  label: 'Tiket',
                ),
                _navItem(
                  ref: ref,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.people_rounded,
                  label: 'Pengguna',
                ),
                _navItem(
                  ref: ref,
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.history_rounded,
                  label: 'Aktivitas',
                ),
                _navItem(
                  ref: ref,
                  index: 4,
                  currentIndex: currentIndex,
                  icon: Icons.person_rounded,
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required WidgetRef ref,
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(adminNavIndexProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryNavy.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryNavy : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryNavy : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}