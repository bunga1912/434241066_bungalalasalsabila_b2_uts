import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/helpdesk_provider.dart';

class HelpdeskHistoryScreen extends ConsumerWidget {
  const HelpdeskHistoryScreen({super.key});

  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(helpdeskHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Riwayat aktivitas tiket kamu',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: historyAsync.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (history) {
                  if (history.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada riwayat aktivitas',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.refresh(helpdeskHistoryProvider.future),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final meta = _statusMeta(item['status'] as String?);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryNavy.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: meta.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(meta.icon,
                                    color: meta.color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['ticket_title'] as String? ?? '-',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: primaryNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['description'] as String? ?? '-',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(
                                          item['timestamp'] as String?),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  ({IconData icon, Color color}) _statusMeta(String? status) {
    switch (status) {
      case 'in_progress':
        return (icon: Icons.autorenew_rounded, color: accentGold);
      case 'forwarded':
        return (icon: Icons.forward_rounded, color: primaryBlue);
      case 'close':
        return (icon: Icons.check_circle_rounded, color: Colors.green);
      case 'open':
        return (icon: Icons.confirmation_number_rounded, color: primaryBlue);
      default:
        return (icon: Icons.info_outline_rounded, color: Colors.grey);
    }
  }

  String _formatTimestamp(String? isoString) {
    if (isoString == null) return '-';
    final date = DateTime.tryParse(isoString);
    if (date == null) return '-';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}