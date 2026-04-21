import 'package:flutter/material.dart';
import '../../data/dummy/dummy_data.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // User biasa hanya lihat tiketnya sendiri
    final tickets = currentUser.role == 'user'
        ? dummyTickets.where((t) => t.createdBy == currentUser.id).toList()
        : dummyTickets;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daftar Tiket',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) => TicketCard(
                  ticket: tickets[index],
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                        builder: (_) => TicketDetailScreen(ticket: tickets[index])));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}