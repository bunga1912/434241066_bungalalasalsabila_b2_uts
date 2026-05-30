import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/ticket_model.dart';
import 'status_badge.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  Color _getCategoryColor() {
    switch (ticket.category) {
      case 'Hardware': return const Color(0xFFEF4444);
      case 'Software': return const Color(0xFF8B5CF6);
      case 'Jaringan': return const Color(0xFF06B6D4);
      case 'Akun & Akses': return const Color(0xFFF59E0B);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getCategoryIcon() {
    switch (ticket.category) {
      case 'Hardware': return Icons.computer_rounded;
      case 'Software': return Icons.code_rounded;
      case 'Jaringan': return Icons.wifi_rounded;
      case 'Akun & Akses': return Icons.manage_accounts_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            // Color accent top bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getCategoryIcon(), size: 14, color: catColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ticket.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: catColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      StatusBadge(status: ticket.status, compact: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ticket.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(ticket.createdAt, locale: 'id'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#${ticket.id.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}