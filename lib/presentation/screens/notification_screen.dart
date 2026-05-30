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
      'title': 'Status tiket diperbarui',
      'body': 'Tiket "Koneksi WiFi lambat" berubah menjadi Diproses',
      'ticketId': 't2',
      'type': 'status_update',
      'isRead': false,
      'time': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 'n2',
      'title': 'Tiket berhasil diselesaikan',
      'body': 'Tiket "Printer error" telah diselesaikan oleh tim helpdesk',
      'ticketId': 't3',
      'type': 'resolved',
      'isRead': false,
      'time': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 'n3',
      'title': 'Balasan baru',
      'body': 'Siti Jaenab membalas di tiket "Koneksi WiFi lambat"',
      'ticketId': 't2',
      'type': 'comment',
      'isRead': true,
      'time': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = _notifications.where((n) => !n['isRead']).length;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Text('Notifikasi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unread baru',
                      style: const TextStyle(color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const Spacer(),
                if (unread > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (final n in _notifications) n['isRead'] = true;
                      });
                    },
                    child: const Text('Tandai semua dibaca',
                        style: TextStyle(fontSize: 12, color: Color(0xFF4F46E5))),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final n = _notifications[index];
                final isRead = n['isRead'] as bool;
                return _NotifTile(
                  title: n['title'] as String,
                  body: n['body'] as String,
                  type: n['type'] as String,
                  time: n['time'] as DateTime,
                  isRead: isRead,
                  onTap: () {
                    setState(() => _notifications[index]['isRead'] = true);
                    final ticket = dummyTickets.firstWhere(
                            (t) => t.id == n['ticketId'], orElse: () => dummyTickets.first);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final String title, body, type;
  final DateTime time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotifTile({
    required this.title, required this.body, required this.type,
    required this.time, required this.isRead, required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case 'status_update': return Icons.autorenew_rounded;
      case 'resolved': return Icons.check_circle_rounded;
      case 'comment': return Icons.chat_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case 'status_update': return const Color(0xFF4F46E5);
      case 'resolved': return const Color(0xFF10B981);
      case 'comment': return const Color(0xFF06B6D4);
      default: return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : _color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                : _color.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 18, color: _color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                    fontSize: 13,
                  )),
                  const SizedBox(height: 3),
                  Text(body, style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B), height: 1.4)),
                  const SizedBox(height: 5),
                  Text(
                    timeago.format(time, locale: 'id'),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}