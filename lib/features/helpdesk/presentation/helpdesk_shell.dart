import 'package:e_ticketing_helpdesk/features/shared/presentation/pages/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/helpdesk_provider.dart';
import 'pages/helpdesk_dashboard_screen.dart';
import 'pages/helpdesk_ticket_list_screen.dart';
import '../../shared/presentation/pages/profile_screen.dart';

class HelpdeskShell extends ConsumerWidget {
  const HelpdeskShell({super.key});

  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  static const List<Widget> _screens = [
    HelpdeskDashboardScreen(),
    HelpdeskTicketListScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(helpdeskNavIndexProvider);
    final unreadAsync = ref.watch(helpdeskUnreadCountProvider);

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
                  onTap: () => ref
                      .read(helpdeskNavIndexProvider.notifier)
                      .state = 0,
                ),
                _NavItem(
                  icon: Icons.confirmation_number_rounded,
                  iconOutlined: Icons.confirmation_number_outlined,
                  label: 'Tiket',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: () => ref
                      .read(helpdeskNavIndexProvider.notifier)
                      .state = 1,
                ),
                // Notifikasi dengan badge
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
                  onTap: () => ref
                      .read(helpdeskNavIndexProvider.notifier)
                      .state = 2,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  iconOutlined: Icons.person_outlined,
                  label: 'Profil',
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: () => ref
                      .read(helpdeskNavIndexProvider.notifier)
                      .state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav Item biasa ──────────────────────────────────────────────────────────
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
  static const Color primaryBlue = Color(0xFF185FA5);

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

// ── Nav Item dengan badge notifikasi ────────────────────────────────────────
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