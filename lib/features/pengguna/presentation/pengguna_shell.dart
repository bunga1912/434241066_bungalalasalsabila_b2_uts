import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/pengguna_dashboard_screen.dart';
import 'pages/pengguna_ticket_list_screen.dart';
import 'pages/pengguna_history_screen.dart';
import '../../shared/presentation/pages/profile_screen.dart';

final penggunaNavIndexProvider = StateProvider<int>((ref) => 0);

class PenggunaShell extends ConsumerWidget {
  const PenggunaShell({super.key});

  static const Color primaryNavy = Color(0xFF042C53);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(penggunaNavIndexProvider);

    final pages = [
      const PenggunaDashboardScreen(),
      const PenggunaTicketListScreen(),
      const PenggunaHistoryScreen(),
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
            padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                  label: 'Tiket Saya',
                ),
                _navItem(
                  ref: ref,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.history_rounded,
                  label: 'Aktivitas',
                ),
                _navItem(
                  ref: ref,
                  index: 3,
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
      onTap: () =>
      ref.read(penggunaNavIndexProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryNavy.withOpacity(0.08)
              : Colors.transparent,
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
                fontSize: 11,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isSelected ? primaryNavy : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}