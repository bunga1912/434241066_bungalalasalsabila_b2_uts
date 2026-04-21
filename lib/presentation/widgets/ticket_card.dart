import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';
import 'status_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(
          ticket.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(ticket.category,
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(timeago.format(ticket.createdAt, locale: 'id'),
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: StatusBadge(status: ticket.status),
        isThreeLine: true,
      ),
    );
  }
}