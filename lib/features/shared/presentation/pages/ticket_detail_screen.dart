import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/models/comment_model.dart';
import '../providers/ticket_provider.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  final String userRole;
  final String userName;
  final String userId;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.userRole,
    required this.userName,
    required this.userId,
  });

  @override
  ConsumerState<TicketDetailScreen> createState() =>
      _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);
  static const Color purple = Color(0xFF9575CD);

  final _commentController = TextEditingController();
  bool _isSending = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFE57373);
      case 'assigned':
        return primaryBlue;
      case 'in_progress':
        return accentGold;
      case 'forwarded':
        return purple;
      case 'resolved':
        return const Color(0xFF4CAF50);
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'assigned':
        return Icons.assignment_ind_rounded;
      case 'in_progress':
        return Icons.sync_rounded;
      case 'forwarded':
        return Icons.forward_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'closed':
        return Icons.lock_rounded;
      default:
        return Icons.circle;
    }
  }

  Future<void> _sendComment() async {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);

    await ref.read(commentProvider(widget.ticketId).notifier).addComment(
      userId: widget.userId,
      userName: widget.userName,
      message: message,
    );

    _commentController.clear();
    setState(() => _isSending = false);
  }

  String _formatDate(DateTime time) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${time.day} ${months[time.month - 1]} ${time.year}, '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final commentsAsync = ref.watch(commentProvider(widget.ticketId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ticket) {
          if (ticket == null) {
            return const Center(child: Text('Tiket tidak ditemukan'));
          }

          final statusColor = _statusColor(ticket.status);

          return Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryNavy, primaryBlue],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryNavy.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + ID + Status
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
                              Colors.white.withOpacity(0.15),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.id,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  ticket.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              ticket.statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Petugas yang menangani
                      if (ticket.assignedTo != null)
                        Container(
                          margin: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.support_agent_rounded,
                                  color: accentGold,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ditangani oleh',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      ticket.assignedTo!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Aktif',
                                  style: TextStyle(
                                    color: accentGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Tab Bar
                      TabBar(
                        controller: _tabController,
                        indicatorColor: accentGold,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor:
                        Colors.white.withOpacity(0.5),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(text: 'Detail'),
                          Tab(text: 'Tracking'),
                          Tab(text: 'Diskusi'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tab Content ──────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Detail
                    _buildDetailTab(ticket),

                    // Tab 2: Tracking
                    _buildTrackingTab(ticket),

                    // Tab 3: Diskusi
                    _buildDiskusiTab(commentsAsync),
                  ],
                ),
              ),

              // ── Input Komentar (hanya di tab Diskusi) ───────────────
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  if (_tabController.index != 2) return const SizedBox();
                  return _buildCommentInput();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Tab Detail ───────────────────────────────────────────────────────
  Widget _buildDetailTab(TicketModel ticket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deskripsi
          _sectionCard(
            title: 'Deskripsi Masalah',
            child: Text(
              ticket.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Info tiket
          _sectionCard(
            title: 'Informasi Tiket',
            child: Column(
              children: [
                _infoRow(
                  Icons.confirmation_number_outlined,
                  'ID Tiket',
                  ticket.id,
                ),
                const Divider(height: 20),
                _infoRow(
                  Icons.category_outlined,
                  'Kategori',
                  ticket.category,
                ),
                const Divider(height: 20),
                _infoRow(
                  Icons.person_outline_rounded,
                  'Dilaporkan oleh',
                  ticket.createdBy,
                ),
                const Divider(height: 20),
                _infoRow(
                  Icons.access_time_rounded,
                  'Dibuat',
                  _formatDate(ticket.createdAt),
                ),
                if (ticket.assignedTo != null) ...[
                  const Divider(height: 20),
                  _infoRow(
                    Icons.support_agent_rounded,
                    'Petugas',
                    ticket.assignedTo!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Aksi pengguna (jika resolved → bisa close)
          if (widget.userRole == 'user' && ticket.status == 'resolved')
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showCloseDialog(ticket),
                icon: const Icon(Icons.thumb_up_rounded, size: 18),
                label: const Text(
                  'Konfirmasi Selesai',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Tab Tracking ──────────────────────────────────────────────────────
  Widget _buildTrackingTab(TicketModel ticket) {
    // Status steps berurutan
    final allSteps = [
      'pending',
      'assigned',
      'in_progress',
      'forwarded',
      'resolved',
      'closed',
    ];

    final stepLabels = {
      'pending': 'Menunggu',
      'assigned': 'Ditugaskan',
      'in_progress': 'Sedang Dikerjakan',
      'forwarded': 'Diteruskan ke TS',
      'resolved': 'Selesai',
      'closed': 'Ditutup',
    };

    final stepIcons = {
      'pending': Icons.hourglass_empty_rounded,
      'assigned': Icons.assignment_ind_rounded,
      'in_progress': Icons.sync_rounded,
      'forwarded': Icons.forward_rounded,
      'resolved': Icons.check_circle_rounded,
      'closed': Icons.lock_rounded,
    };

    // Tentukan step mana yang sudah dilalui
    final currentStepIndex = allSteps.indexOf(ticket.status);

    // Ambil steps yang relevan (skip forwarded kalau tidak ada)
    final hasForwarded = ticket.history.any((h) => h.status == 'forwarded');
    final relevantSteps = allSteps
        .where((s) => s != 'forwarded' || hasForwarded)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual timeline
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Perjalanan Tiket',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 20),
                ...relevantSteps.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final step = entry.value;
                  final stepCurrentIdx = allSteps.indexOf(step);
                  final isDone = stepCurrentIdx <= currentStepIndex;
                  final isCurrent = step == ticket.status;
                  final isLast = idx == relevantSteps.length - 1;

                  final color = isDone
                      ? _statusColor(step)
                      : Colors.grey[300]!;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? color.withOpacity(0.15)
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDone ? color : Colors.grey[300]!,
                                width: isCurrent ? 2.5 : 1.5,
                              ),
                            ),
                            child: Icon(
                              stepIcons[step]!,
                              size: 18,
                              color: isDone ? color : Colors.grey[400],
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 32,
                              color: isDone &&
                                  stepCurrentIdx < currentStepIndex
                                  ? color.withOpacity(0.4)
                                  : Colors.grey[200],
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Label
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    stepLabels[step]!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isDone
                                          ? primaryNavy
                                          : Colors.grey[400],
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Saat ini',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // Cari timestamp dari history
                              Builder(builder: (_) {
                                final historyItem = ticket.history
                                    .where((h) => h.status == step)
                                    .lastOrNull;
                                if (historyItem == null) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    _formatDate(historyItem.timestamp),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Log history detail
          if (ticket.history.isNotEmpty) ...[
            const Text(
              'Log Aktivitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryNavy,
              ),
            ),
            const SizedBox(height: 10),
            ...ticket.history.reversed.map((h) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primaryNavy.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _statusColor(h.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _statusIcon(h.status),
                      color: _statusColor(h.status),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.description,
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
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              h.actor,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.access_time_rounded,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              _timeAgo(h.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  // ── Tab Diskusi ───────────────────────────────────────────────────────
  Widget _buildDiskusiTab(AsyncValue<List<CommentModel>> commentsAsync) {
    return commentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (comments) {
        if (comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 40,
                    color: primaryBlue.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada diskusi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai percakapan dengan petugas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final isMe = comment.userId == widget.userId;

            return _commentBubble(comment, isMe);
          },
        );
      },
    );
  }

  // ── Comment Bubble ────────────────────────────────────────────────────
  Widget _commentBubble(CommentModel comment, bool isMe) {
    final initials = comment.userName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: primaryBlue.withOpacity(0.12),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      comment.userName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? primaryNavy : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryNavy.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    comment.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isMe ? Colors.white : Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _timeAgo(comment.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: accentGold.withOpacity(0.2),
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Input Komentar ────────────────────────────────────────────────────
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan...',
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF1EFE8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isSending ? null : _sendComment,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSending ? Colors.grey[300] : primaryNavy,
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryBlue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCloseDialog(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Selesai?',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: primaryNavy),
        ),
        content: const Text(
          'Pastikan masalahmu sudah benar-benar teratasi sebelum menutup tiket.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF4CAF50),
                  content: Text('Tiket berhasil ditutup'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );
  }
}