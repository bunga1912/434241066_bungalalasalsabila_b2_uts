import 'package:flutter/material.dart';
import '../../data/dummy/dummy_data.dart';
import 'ticket_list_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'create_ticket_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardHome(onRefresh: () => setState(() {})),
      TicketListScreen(onRefresh: () => setState(() {})),
      const NotificationScreen(),
      const ProfileScreen(),
    ];
  }

  void _onFabPressed() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const CreateTicketScreen()));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isUser = currentUser.role == 'user';

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: (isUser && _currentIndex == 1)
          ? FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Tiket', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number_rounded),
              label: 'Tiket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final VoidCallback onRefresh;
  const _DashboardHome({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userTickets = currentUser.role == 'user'
        ? dummyTickets.where((t) => t.createdBy == currentUser.id).toList()
        : dummyTickets;

    final total = userTickets.length;
    final open = userTickets.where((t) => t.status == 'open').length;
    final inProgress = userTickets.where((t) => t.status == 'in_progress').length;
    final resolved = userTickets.where((t) => t.status == 'resolved').length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: const Color(0xFF4F46E5),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${currentUser.name.split(' ').first} 👋',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _roleLabel(currentUser.role),
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      currentUser.initials,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(label: 'Total Tiket', count: total,
                    color: const Color(0xFF4F46E5), icon: Icons.confirmation_number_rounded),
                _StatCard(label: 'Baru', count: open,
                    color: const Color(0xFFF59E0B), icon: Icons.fiber_new_rounded),
                _StatCard(label: 'Diproses', count: inProgress,
                    color: const Color(0xFF06B6D4), icon: Icons.autorenew_rounded),
                _StatCard(label: 'Selesai', count: resolved,
                    color: const Color(0xFF10B981), icon: Icons.check_circle_rounded),
              ],
            ),
            const SizedBox(height: 24),

            // Recent tickets header
            const Text('Tiket Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            // Recent tickets list (last 3)
            ...userTickets.take(3).map((t) => _RecentTicketRow(ticket: t)),

            if (userTickets.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded, size: 48,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      const SizedBox(height: 12),
                      const Text('Belum ada tiket', style: TextStyle(color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.count,
    required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTicketRow extends StatelessWidget {
  final ticket;
  const _RecentTicketRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(ticket.category,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusDot(ticket.status),
        ],
      ),
    );
  }

  Widget _statusDot(String status) {
    final colors = {
      'open': const Color(0xFFF59E0B),
      'in_progress': const Color(0xFF4F46E5),
      'resolved': const Color(0xFF10B981),
      'closed': const Color(0xFF94A3B8),
    };
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        color: colors[status] ?? const Color(0xFF94A3B8),
        shape: BoxShape.circle,
      ),
    );
  }
}