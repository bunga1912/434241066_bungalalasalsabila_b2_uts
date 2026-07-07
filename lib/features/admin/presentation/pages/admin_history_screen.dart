import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class AdminHistoryScreen extends ConsumerWidget {
  const AdminHistoryScreen({super.key});

  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  String _formatDate(DateTime time) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${time.day} ${months[time.month - 1]} ${time.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(
      List<Map<String, dynamic>> logs) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var log in logs) {
      final raw = log['timestamp'];
      final time = raw is DateTime
          ? raw
          : DateTime.tryParse(raw.toString()) ?? DateTime.now();
      final dateKey = _formatDate(time);
      grouped.putIfAbsent(dateKey, () => []).add({...log, '_parsedTime': time});
    }
    return grouped;
  }

  IconData _iconForStatus(String status) {
    switch (status) {
      case 'open':
        return Icons.inbox_rounded;
      case 'assigned':
      case 'in_progress':
        return Icons.assignment_turned_in_rounded;
      case 'forwarded':
        return Icons.forward_rounded;
      case 'close':
        return Icons.check_circle_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _colorForStatus(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFFE57373);
      case 'assigned':
      case 'in_progress':
        return primaryBlue;
      case 'forwarded':
        return const Color(0xFF9575CD);
      case 'close':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(adminRecentActivitiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryNavy, primaryBlue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -10,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentGold.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Aktivitas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                ref.invalidate(adminRecentActivitiesProvider),
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                              Colors.white.withOpacity(0.15),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Log seluruh aktivitas sistem',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Content ───────────────────────────────────────────────
            Expanded(
              child: activitiesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat aktivitas',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref
                            .invalidate(adminRecentActivitiesProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
                data: (logs) {
                  if (logs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_rounded,
                              size: 48,
                              color: primaryBlue.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada aktivitas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final grouped = _groupByDate(logs);

                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(adminRecentActivitiesProvider),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 10,
                                top: 8,
                              ),
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            ...entry.value.map((log) => _logItem(log)),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
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

  Widget _logItem(Map<String, dynamic> log) {
    final status = (log['status'] as String?) ?? '';
    final description = (log['description'] as String?) ?? '';
    // FIX: sebelumnya pakai log['actor'] (UUID mentah). Sekarang pakai
    // 'actor_name' hasil join ke tabel users dari adminRecentActivitiesProvider,
    // dengan fallback ke UUID kalau nama tidak ditemukan (misal user terhapus).
    final actorName =
        (log['actor_name'] as String?) ?? (log['actor'] as String?) ?? '-';
    final parsedTime = log['_parsedTime'] as DateTime? ?? DateTime.now();
    final color = _colorForStatus(status);
    final icon = _iconForStatus(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'oleh $actorName',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(parsedTime),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}