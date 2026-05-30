import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  StatusStyle _getStyle() {
    switch (status) {
      case 'open':
        return StatusStyle(
          color: const Color(0xFFF59E0B),
          bg: const Color(0xFFFFFBEB),
          label: 'Baru',
          icon: Icons.fiber_new_rounded,
        );
      case 'in_progress':
        return StatusStyle(
          color: const Color(0xFF4F46E5),
          bg: const Color(0xFFEEF2FF),
          label: 'Diproses',
          icon: Icons.autorenew_rounded,
        );
      case 'resolved':
        return StatusStyle(
          color: const Color(0xFF10B981),
          bg: const Color(0xFFECFDF5),
          label: 'Selesai',
          icon: Icons.check_circle_outline_rounded,
        );
      case 'closed':
        return StatusStyle(
          color: const Color(0xFF64748B),
          bg: const Color(0xFFF1F5F9),
          label: 'Ditutup',
          icon: Icons.lock_outline_rounded,
        );
      default:
        return StatusStyle(
          color: const Color(0xFF64748B),
          bg: const Color(0xFFF1F5F9),
          label: status,
          icon: Icons.help_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 10 : 12, color: style.color),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusStyle {
  final Color color;
  final Color bg;
  final String label;
  final IconData icon;

  StatusStyle({
    required this.color,
    required this.bg,
    required this.label,
    required this.icon,
  });
}