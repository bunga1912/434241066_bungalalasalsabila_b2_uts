import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/ts_provider.dart';
import 'presentation/pages/ts_dashboard_screen.dart';
import 'presentation/pages/ts_ticket_list_screen.dart';
import '../shared/presentation/pages/notification_screen.dart';
import '../shared/presentation/pages/profile_screen.dart';

class TsShell extends ConsumerWidget {
  const TsShell({super.key});

  static const Color primaryNavy = Color(0xFF042C53);

  static const List<Widget> _screens = [
    TsDashboardScreen(),
    TsTicketListScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tsNavIndexProvider);
    final unreadAsync = ref.watch(tsUnreadCountProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: primaryNavy.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  iconOutlined: Icons.home_outlined,
                  label: 'Beranda',
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: () =>
                  ref.read(tsNavIndexProvider.notifier).state = 0,
                ),
                _NavItem(
                  icon: Icons.confirmation_number_rounded,
                  iconOutlined: Icons.confirmation_number_outlined,
                  label: 'Tiket',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: () =>
                  ref.read(tsNavIndexProvider.notifier).state = 1,
                ),
                _NavItemBadge(
                  icon: Icons.notifications_rounded,
                  iconOutlined: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  index: 2,
                  currentIndex: currentIndex,
                  badgeCount: unreadAsync.when(
                    data: (c) => c,
                    loading: () => 0,
                    error: (_, __) => 0,
                  ),
                  onTap: () =>
                  ref.read(tsNavIndexProvider.notifier).state = 2,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  iconOutlined: Icons.person_outlined,
                  label: 'Profil',
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: () =>
                  ref.read(tsNavIndexProvider.notifier).state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item biasa ───────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  static const Color primaryNavy = Color(0xFF042C53);

  bool get isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primaryNavy.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? icon : iconOutlined,
              color: isActive ? primaryNavy : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? primaryNavy : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav Item dengan badge ────────────────────────────────────────────────────
class _NavItemBadge extends StatelessWidget {
  const _NavItemBadge({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.badgeCount,
    required this.onTap,
  });

  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final int index;
  final int currentIndex;
  final int badgeCount;
  final VoidCallback onTap;

  static const Color primaryNavy = Color(0xFF042C53);

  bool get isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primaryNavy.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? icon : iconOutlined,
                  color: isActive ? primaryNavy : Colors.grey[400],
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE57373),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? primaryNavy : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}