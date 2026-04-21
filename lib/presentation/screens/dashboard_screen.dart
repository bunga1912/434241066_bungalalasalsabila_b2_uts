import 'package:flutter/material.dart';
import '../../data/dummy/dummy_data.dart';
import 'ticket_list_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'create_ticket_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardHome(),
    const TicketListScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateTicketScreen()));
          setState(() {});
        },
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tiket'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    final total = dummyTickets.length;
    final open = dummyTickets.where((t) => t.status == 'open').length;
    final inProgress = dummyTickets.where((t) => t.status == 'in_progress').length;
    final resolved = dummyTickets.where((t) => t.status == 'resolved').length;
    final closed = dummyTickets.where((t) => t.status == 'closed').length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${currentUser.name} 👋',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Role: ${currentUser.role}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('Statistik Tiket',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _StatCard(label: 'Total Tiket', count: total, color: Colors.blue),
            _StatCard(label: 'Open', count: open, color: Colors.orange),
            _StatCard(label: 'In Progress', count: inProgress, color: Colors.amber),
            _StatCard(label: 'Resolved', count: resolved, color: Colors.green),
            _StatCard(label: 'Closed', count: closed, color: Colors.grey),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen())),
              icon: const Icon(Icons.history),
              label: const Text('Lihat Riwayat & Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text('$count',
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(label),
      ),
    );
  }
}