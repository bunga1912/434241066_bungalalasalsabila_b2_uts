import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../providers/pengguna_provider.dart';

class PenggunaActivityScreen extends ConsumerWidget {
  const PenggunaActivityScreen({super.key});

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

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF185FA5);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return const Color(0xFF4CAF50);
      case 'close':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.fiber_new_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'close':
        return Icons.lock_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(penggunaTicketProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
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
                        color: accentGold.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Aktivitas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: Text(
                          'Semua aktivitas tiket kamu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ticketsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (tickets) {
                  if (tickets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              size: 48,
                              color: primaryBlue.withValues(alpha: 0.5),
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
                          const SizedBox(height: 4),
                          Text(
                            'Tiket yang kamu buat akan muncul di sini',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Urutkan dari terbaru
                  final sorted = [...tickets]
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(penggunaTicketProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final ticket = sorted[index];

                        // Tampilkan label tanggal jika beda hari
                        final showDateLabel = index == 0 ||
                            _formatDate(sorted[index - 1].createdAt) !=
                                _formatDate(ticket.createdAt);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateLabel) ...[
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 8, top: 4),
                                child: Text(
                                  _formatDate(ticket.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[500],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                            _activityCard(ticket),
                          ],
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

  Widget _activityCard(TicketModel ticket) {
    final color = _statusColor(ticket.status);
    final icon = _statusIcon(ticket.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon status
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nomor tiket
                  // FIX: sebelumnya ticket.id (UUID panjang, bikin overflow
                  // di layar sempit). Sekarang pakai displayNumber -> "TKT-0001".
                  Text(
                    ticket.displayNumber,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Judul tiket
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Kategori & status
                  Row(
                    children: [
                      Icon(Icons.category_outlined,
                          size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        ticket.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticket.statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Assigned to
                  if (ticket.assignedTo != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.assignment_ind_outlined,
                            size: 12, color: primaryBlue),
                        const SizedBox(width: 4),
                        // FIX: dibungkus Expanded + ellipsis supaya nama/ID
                        // panjang tidak overflow ke luar kartu (sebelumnya
                        // "Ditangani: <uuid>" meluber ke kanan layar).
                        // Juga pakai assignedToName jika tersedia dari join,
                        // supaya tidak lagi menampilkan UUID mentah.
                        Expanded(
                          child: Text(
                            'Ditangani: ${ticket.assignedToName ?? ticket.assignedTo}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}