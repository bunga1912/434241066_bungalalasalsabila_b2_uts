import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../providers/pengguna_provider.dart';
import '../../../shared/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PenggunaTicketListScreen extends ConsumerStatefulWidget {
  const PenggunaTicketListScreen({super.key});

  @override
  ConsumerState<PenggunaTicketListScreen> createState() =>
      _PenggunaTicketListScreenState();
}

class _PenggunaTicketListScreenState
    extends ConsumerState<PenggunaTicketListScreen> {
  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  String _selectedFilter = 'all';

  List<TicketModel> _filterTickets(List<TicketModel> tickets) {
    switch (_selectedFilter) {
      case 'active':
        return tickets
            .where((t) =>
        t.status == 'pending' ||
            t.status == 'assigned' ||
            t.status == 'in_progress' ||
            t.status == 'forwarded')
            .toList();
      case 'resolved':
        return tickets.where((t) => t.status == 'resolved').toList();
      case 'close':
        return tickets.where((t) => t.status == 'close').toList();
      default:
        return tickets;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFE57373);
      case 'assigned':
      case 'in_progress':
      case 'forwarded':
        return primaryBlue;
      case 'resolved':
        return const Color(0xFF4CAF50);
      case 'close':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
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
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Tiket Saya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(penggunaTicketProvider.notifier)
                                .refresh(),
                            icon: const Icon(Icons.refresh_rounded,
                                color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('all', 'Semua'),
                            _filterChip('active', 'Aktif'),
                            _filterChip('resolved', 'Selesai'),
                            _filterChip('close', 'Tertutup'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ticketsAsync.when(
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (tickets) {
                  final filtered = _filterTickets(tickets);
                  if (filtered.isEmpty) return _emptyState();
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(penggunaTicketProvider.notifier)
                        .refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _ticketCard(filtered[index]),
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

  Widget _filterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? accentGold
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? accentGold
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? primaryNavy : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ticketCard(TicketModel ticket) {
    final statusColor = _statusColor(ticket.status);

    return GestureDetector(
      onTap: () {
        final authState = ref.read(authProvider);
        final user = authState.whenOrNull(data: (u) => u);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailScreen(
              ticketId: ticket.id,
              userRole: 'user',
              userName: user?.name ?? '',
              userId: user?.id ?? '',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: primaryBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FIX: sebelumnya menampilkan ticket.id (UUID mentah,
                      // panjang dan tidak mudah dibaca user). Sekarang
                      // pakai ticket.displayNumber -> "TKT-0001", dst.
                      // UUID aslinya (ticket.id) tetap dipakai penuh di
                      // belakang layar untuk navigasi & query, tidak diubah.
                      Text(
                        ticket.displayNumber,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _timeAgo(ticket.createdAt),
                  style:
                  TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.category_outlined,
                    size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  ticket.category,
                  style:
                  TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
            if (ticket.assignedTo != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.assignment_ind_outlined,
                      size: 14, color: primaryBlue),
                  const SizedBox(width: 4),
                  Text(
                    'Ditangani oleh: ${ticket.assignedToName ?? ticket.assignedTo}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _emptyState() {
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
            child: Icon(Icons.inbox_rounded,
                size: 48, color: primaryBlue.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada tiket',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}