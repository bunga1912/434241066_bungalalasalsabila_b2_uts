import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../../shared/presentation/pages/notification_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../admin_shell.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final categoriesAsync = ref.watch(adminCategoryStatsProvider);
    final helpdeskAsync = ref.watch(adminHelpdeskActiveProvider);
    final ticketsAsync = ref.watch(adminRecentTicketsProvider);
    final userAsync = ref.watch(authProvider);
    final userName = userAsync.whenOrNull(data: (u) => u?.name) ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminStatsProvider);
            ref.invalidate(adminCategoryStatsProvider);
            ref.invalidate(adminHelpdeskActiveProvider);
            ref.invalidate(adminRecentTicketsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
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
                        top: -20,
                        right: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentGold.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo Admin, 👋',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Tombol Tambah Pengumuman
                                  GestureDetector(
                                    onTap: () => _showAddAnnouncementSheet(context, ref),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: accentGold.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: accentGold.withOpacity(0.5),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.campaign_rounded,
                                        color: accentGold,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Notifikasi
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const NotificationScreen(),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Stat cards row
                          statsAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                            error: (e, _) => Text(
                              'Gagal memuat statistik',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                            data: (stats) => Row(
                              children: [
                                _headerStatCard(
                                  label: 'Total',
                                  value: '${stats['total'] ?? 0}',
                                  icon: Icons.confirmation_number_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                _headerStatCard(
                                  label: 'Open',
                                  value: '${stats['open'] ?? 0}',
                                  icon: Icons.inbox_rounded,
                                  color: const Color(0xFFFFCDD2),
                                ),
                                const SizedBox(width: 8),
                                _headerStatCard(
                                  label: 'Progress',
                                  value: '${stats['in_progress'] ?? 0}',
                                  icon: Icons.sync_rounded,
                                  color: accentGold,
                                ),
                                const SizedBox(width: 8),
                                // FIX: key stats sebelumnya 'closed' (typo,
                                // tidak pernah match), sekarang 'close'
                                // konsisten dengan TicketRepository.getTicketStats().
                                _headerStatCard(
                                  label: 'Closed',
                                  value: '${stats['close'] ?? 0}',
                                  icon: Icons.check_circle_rounded,
                                  color: const Color(0xFFA5D6A7),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tiket Terbaru ────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tiket Terbaru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                              letterSpacing: -0.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => ref
                                .read(adminNavIndexProvider.notifier)
                                .state = 1,
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ticketsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => _errorCard('Gagal memuat tiket'),
                        data: (tickets) {
                          if (tickets.isEmpty) {
                            return _emptyCard('Belum ada tiket masuk');
                          }
                          return Column(
                            children: tickets
                                .take(3)
                                .map((t) => _ticketItem(t))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Kategori ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      categoriesAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => _errorCard('Gagal memuat kategori'),
                        data: (categories) {
                          if (categories.isEmpty) return _emptyCard('Belum ada data kategori');
                          final total = categories.values
                              .fold<int>(0, (sum, v) => sum + (v as int));
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryNavy.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: categories.entries.map((e) {
                                final pct = total == 0 ? 0.0 : (e.value as int) / total;
                                return _categoryRow(e.key, e.value as int, pct);
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Helpdesk Aktif ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Helpdesk Aktif',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      helpdeskAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => _errorCard('Gagal memuat helpdesk'),
                        data: (helpdesks) {
                          if (helpdesks.isEmpty) return _emptyCard('Belum ada helpdesk aktif');
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryNavy.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: helpdesks.asMap().entries.map((entry) {
                                final i = entry.key;
                                final h = entry.value;
                                final isLast = i == helpdesks.length - 1;
                                return _helpdeskRow(h, isLast: isLast);
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Stat Card ────────────────────────────────────────────────
  Widget _headerStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Ticket Item ──────────────────────────────────────────────────────
  Widget _ticketItem(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? '';
    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'open':
      case 'pending':
        statusColor = const Color(0xFFE57373);
        statusLabel = 'Open';
        break;
      case 'assigned':
      case 'in_progress':
      case 'forwarded':
        statusColor = primaryBlue;
        statusLabel = 'Progress';
        break;
      case 'resolved':
        statusColor = const Color(0xFF4CAF50);
        statusLabel = 'Resolved';
        break;
      case 'close':
        statusColor = Colors.grey;
        statusLabel = 'Close';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = status;
    }

    // FIX: sebelumnya menampilkan ticket['id'] (UUID panjang). Sekarang
    // pakai ticket['ticket_number'] yang diformat jadi "TKT-0001", dengan
    // fallback ke potongan UUID kalau ticket_number belum ada (data lama).
    final ticketNumber = ticket['ticket_number'];
    final displayNumber = ticketNumber != null
        ? 'TKT-${ticketNumber.toString().padLeft(4, '0')}'
        : (ticket['id']?.toString() ?? '');

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
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.confirmation_number_outlined,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayNumber,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ticket['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  // FIX: key hasil getRecentTickets() adalah 'created_by_name',
                  // bukan 'user_name' (sebelumnya selalu kosong).
                  ticket['created_by_name'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Row ─────────────────────────────────────────────────────
  Widget _categoryRow(String name, int count, double pct) {
    const colors = [primaryBlue, accentGold, Color(0xFF4CAF50), Color(0xFFE57373)];
    final colorMap = {
      'Software': colors[0],
      'Hardware': colors[3],
      'Jaringan': colors[2],
      'Akun': colors[1],
    };
    final color = colorMap[name] ?? primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryNavy,
                ),
              ),
              Text(
                '$count tiket',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1EFE8),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpdesk Row ──────────────────────────────────────────────────────
  Widget _helpdeskRow(Map<String, dynamic> h, {bool isLast = false}) {
    final count = h['ticket_count'] ?? h['count'] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
          bottom: BorderSide(color: Color(0xFFF1EFE8), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                (h['name'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              h['name'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryNavy,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count tiket',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────
  static Widget _emptyCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          msg,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ),
    );
  }

  static Widget _errorCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(msg, style: const TextStyle(color: Color(0xFFE57373))),
    );
  }

  // ── Bottom Sheet: Tambah Pengumuman ───────────────────────────────────
  void _showAddAnnouncementSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tambah Pengumuman',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 20),
              _inputField(
                controller: titleCtrl,
                label: 'Judul Pengumuman',
                hint: 'Contoh: Maintenance Server',
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: descCtrl,
                label: 'Deskripsi',
                hint: 'Tulis isi pengumuman...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) return;
                    ref.read(adminAnnouncementProvider.notifier).addAnnouncement(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Kirim Pengumuman',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primaryNavy,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF1EFE8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}