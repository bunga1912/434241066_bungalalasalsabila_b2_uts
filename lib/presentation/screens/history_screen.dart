import 'package:flutter/material.dart';
import '../../data/dummy/dummy_data.dart';
import '../widgets/ticket_card.dart';
import '../widgets/status_badge.dart';
import 'ticket_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = currentUser.role == 'user'
        ? dummyTickets.where((t) => t.createdBy == currentUser.id).toList()
        : dummyTickets;

    final activeTickets = tickets
        .where((t) => t.status == 'open' || t.status == 'in_progress').toList();
    final historyTickets = tickets
        .where((t) => t.status == 'resolved' || t.status == 'closed').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat & Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tiket Aktif (Tracking)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (activeTickets.isEmpty)
            const Text('Tidak ada tiket aktif.',
                style: TextStyle(color: Colors.grey)),
          ...activeTickets.map((t) => TicketCard(
            ticket: t,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t))),
          )),
          const SizedBox(height: 16),
          const Text('Riwayat Tiket',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (historyTickets.isEmpty)
            const Text('Belum ada riwayat tiket.',
                style: TextStyle(color: Colors.grey)),
          ...historyTickets.map((t) => TicketCard(
            ticket: t,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: t))),
          )),
        ],
      ),
    );
  }
}