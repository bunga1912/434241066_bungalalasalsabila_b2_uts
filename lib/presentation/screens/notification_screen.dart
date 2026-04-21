import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/dummy/dummy_data.dart';
import 'ticket_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n1',
      'title': 'Tiket diperbarui',
      'body': 'Status tiket "Koneksi WiFi lambat" berubah menjadi In Progress',
      'ticketId': 't2',
      'isRead': false,
      'time': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 'n2',
      'title': 'Tiket selesai',
      'body': 'Tiket "Printer error" telah diselesaikan oleh helpdesk',
      'ticketId': 't3',
      'isRead': false,
      'time': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 'n3',
      'title': 'Komentar baru',
      'body': 'Helpdesk membalas tiket "Koneksi WiFi lambat"',
      'ticketId': 't2',
      'isRead': true,
      'time': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  void _markAsRead(int index) {
    setState(() => _notifications[index]['isRead'] = true);
  }

  void _navigateToTicket(String ticketId) {
    final ticket = dummyTickets.firstWhere(
          (t) => t.id == ticketId,
      orElse: () => dummyTickets.first,
    );
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)));
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Notifikasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$unreadCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  final isRead = notif['isRead'] as bool;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isRead ? null : const Color(0xFFEFF6FF),
                    child: ListTile(
                      onTap: () {
                        _markAsRead(index);
                        _navigateToTicket(notif['ticketId'] as String);
                      },
                      leading: CircleAvatar(
                        backgroundColor: isRead
                            ? Colors.grey.shade200
                            : const Color(0xFF2563EB),
                        child: Icon(Icons.notifications,
                            color: isRead ? Colors.grey : Colors.white),
                      ),
                      title: Text(notif['title'] as String,
                          style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notif['body'] as String),
                          const SizedBox(height: 2),
                          Text(timeago.format(notif['time'] as DateTime, locale: 'id'),
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      trailing: !isRead
                          ? const Icon(Icons.circle, color: Color(0xFF2563EB), size: 10)
                          : null,
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}