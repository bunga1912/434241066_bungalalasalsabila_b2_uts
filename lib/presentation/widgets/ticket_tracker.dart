import 'package:flutter/material.dart';
import '../../data/models/ticket_model.dart';

class TicketTracker extends StatelessWidget {
  final TicketModel ticket;

  const TicketTracker({super.key, required this.ticket});

  static const _steps = [
    _TrackStep(status: 'open', label: 'Tiket Diterima', icon: Icons.inbox_rounded),
    _TrackStep(status: 'in_progress', label: 'Sedang Diproses', icon: Icons.build_rounded),
    _TrackStep(status: 'resolved', label: 'Masalah Selesai', icon: Icons.check_circle_rounded),
    _TrackStep(status: 'closed', label: 'Tiket Ditutup', icon: Icons.lock_rounded),
  ];

  int get _currentStep {
    switch (ticket.status) {
      case 'open': return 0;
      case 'in_progress': return 1;
      case 'resolved': return 2;
      case 'closed': return 3;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = _currentStep;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timeline_rounded, size: 16, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Status Tiket',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(_steps.length, (index) {
            final step = _steps[index];
            final isDone = index < currentStep;
            final isCurrent = index == currentStep;
            final isLast = index == _steps.length - 1;

            // Find history for this step
            final historyEntry = ticket.history.where(
                    (h) => h.status == step.status
            ).lastOrNull;

            Color nodeColor;
            Color lineColor;
            if (isDone || isCurrent) {
              nodeColor = isCurrent ? const Color(0xFF4F46E5) : const Color(0xFF10B981);
              lineColor = isDone ? const Color(0xFF10B981) : const Color(0xFFE2E8F0);
            } else {
              nodeColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
              lineColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: icon + line
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (isDone || isCurrent)
                            ? nodeColor.withOpacity(0.15)
                            : nodeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: nodeColor,
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : step.icon,
                        size: 16,
                        color: (isDone || isCurrent) ? nodeColor
                            : isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: lineColor,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Right: content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                            color: (isDone || isCurrent)
                                ? (isDark ? Colors.white : const Color(0xFF1E293B))
                                : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        if (historyEntry != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            historyEntry.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 10,
                                color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                historyEntry.actor,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time_rounded,
                                size: 10,
                                color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatDate(historyEntry.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ] else if (!isDone && !isCurrent) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Menunggu...',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                        if (isCurrent) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Status saat ini',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF4F46E5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

class _TrackStep {
  final String status;
  final String label;
  final IconData icon;
  const _TrackStep({required this.status, required this.label, required this.icon});
}