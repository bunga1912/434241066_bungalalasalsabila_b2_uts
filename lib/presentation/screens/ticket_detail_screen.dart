import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/dummy/dummy_data.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/comment_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/ticket_tracker.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _commentController = TextEditingController();
  bool _sending = false;

  List<CommentModel> get _comments =>
      dummyComments.where((c) => c.ticketId == widget.ticket.id).toList();

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 400));
    dummyComments.add(CommentModel(
      id: 'c${dummyComments.length + 1}',
      ticketId: widget.ticket.id,
      userId: currentUser.id,
      userName: currentUser.name,
      message: _commentController.text.trim(),
      createdAt: DateTime.now(),
    ));
    _commentController.clear();
    if (mounted) setState(() => _sending = false);
  }

  void _updateStatus(String newStatus) {
    final idx = dummyTickets.indexWhere((t) => t.id == widget.ticket.id);
    if (idx != -1) {
      dummyTickets[idx].status = newStatus;
      dummyTickets[idx].history.add(TicketHistory(
        status: newStatus,
        description: _statusDescription(newStatus),
        timestamp: DateTime.now(),
        actor: currentUser.name,
      ));
    }
    widget.ticket.status = newStatus;
    widget.ticket.history.add(TicketHistory(
      status: newStatus,
      description: _statusDescription(newStatus),
      timestamp: DateTime.now(),
      actor: currentUser.name,
    ));
    setState(() {});
    _showSnack('Status berubah menjadi ${_statusLabel(newStatus)}', const Color(0xFF10B981));
  }

  void _assignTicket(String helpdeskId) {
    final idx = dummyTickets.indexWhere((t) => t.id == widget.ticket.id);
    if (idx != -1) dummyTickets[idx].assignedTo = helpdeskId;
    widget.ticket.assignedTo = helpdeskId;
    final helpdesk = dummyUsers.firstWhere((u) => u.id == helpdeskId);
    setState(() {});
    _showSnack('Tiket di-assign ke ${helpdesk.name}', const Color(0xFF4F46E5));
  }

  String _statusDescription(String s) {
    switch (s) {
      case 'open': return 'Tiket kembali dibuka';
      case 'in_progress': return 'Tim helpdesk mulai menangani tiket';
      case 'resolved': return 'Masalah berhasil diselesaikan';
      case 'closed': return 'Tiket ditutup';
      default: return 'Status diperbarui';
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'open': return 'Baru';
      case 'in_progress': return 'Diproses';
      case 'resolved': return 'Selesai';
      case 'closed': return 'Ditutup';
      default: return s;
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final helpdeskUsers = dummyUsers.where((u) => u.role == 'helpdesk').toList();
    final assignedUser = widget.ticket.assignedTo != null
        ? dummyUsers.firstWhereOrNull((u) => u.id == widget.ticket.assignedTo)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tiket #${widget.ticket.id.toUpperCase()}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusBadge(status: widget.ticket.status),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Ticket header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ticket.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        _infoChip(Icons.label_outline_rounded, widget.ticket.category),
                        const SizedBox(width: 8),
                        _infoChip(Icons.access_time_rounded,
                            timeago.format(widget.ticket.createdAt, locale: 'id')),
                      ]),
                      if (assignedUser != null) ...[
                        const SizedBox(height: 8),
                        _infoChip(Icons.person_pin_rounded, 'Ditangani: ${assignedUser.name}',
                            color: const Color(0xFF4F46E5)),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        widget.ticket.description,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // TRACKING SECTION — visible to ALL users
                TicketTracker(ticket: widget.ticket),
                const SizedBox(height: 16),

                // Admin-only: Update status & assign
                if (currentUser.role != 'user') ...[
                  _SectionHeader(
                    icon: Icons.tune_rounded,
                    title: 'Kelola Tiket',
                    color: const Color(0xFF4F46E5),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Update Status',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['open', 'in_progress', 'resolved', 'closed']
                              .map((s) => _StatusChip(
                            status: s,
                            isSelected: widget.ticket.status == s,
                            onTap: () => _updateStatus(s),
                          ))
                              .toList(),
                        ),

                        // Assign to helpdesk — admin only
                        if (currentUser.role == 'admin') ...[
                          const SizedBox(height: 16),
                          const Divider(height: 0),
                          const SizedBox(height: 16),
                          const Text('Assign ke Helpdesk',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: widget.ticket.assignedTo,
                            decoration: const InputDecoration(
                              hintText: 'Pilih anggota helpdesk',
                              prefixIcon: Icon(Icons.person_search_rounded, size: 20),
                            ),
                            items: helpdeskUsers.map((u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.name),
                            )).toList(),
                            onChanged: (val) { if (val != null) _assignTicket(val); },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Comments section
                _SectionHeader(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Diskusi (${_comments.length})',
                  color: const Color(0xFF06B6D4),
                ),
                const SizedBox(height: 12),

                if (_comments.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    alignment: Alignment.center,
                    child: Column(children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 36,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      const SizedBox(height: 8),
                      const Text('Belum ada diskusi',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ]),
                  ),

                ..._comments.map((c) => _CommentBubble(comment: c)),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                  top: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(currentUser.initials,
                        style: const TextStyle(color: Colors.white, fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addComment,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _sending
                        ? const SizedBox.shrink()
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11,
              color: color != null ? Colors.white : const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(
            fontSize: 11,
            color: color != null ? Colors.white : const Color(0xFF64748B),
          )),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({required this.status, required this.isSelected, required this.onTap});

  static const _labels = {
    'open': 'Baru',
    'in_progress': 'Diproses',
    'resolved': 'Selesai',
    'closed': 'Ditutup',
  };
  static const _colors = {
    'open': Color(0xFFF59E0B),
    'in_progress': Color(0xFF4F46E5),
    'resolved': Color(0xFF10B981),
    'closed': Color(0xFF64748B),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? const Color(0xFF64748B);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(isSelected ? 0 : 0.3)),
        ),
        child: Text(
          _labels[status] ?? status,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ],
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final CommentModel comment;
  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMe = comment.userId == currentUser.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF06B6D4).withOpacity(0.15),
              child: Text(
                comment.userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 11, color: Color(0xFF06B6D4), fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF4F46E5)
                    : isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isMe ? 14 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 14),
                ),
                border: isMe ? null : Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Text(comment.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF06B6D4))),
                  if (!isMe) const SizedBox(height: 2),
                  Text(comment.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: isMe ? Colors.white : null,
                        height: 1.4,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(comment.createdAt, locale: 'id'),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white.withOpacity(0.65) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF4F46E5).withOpacity(0.15),
              child: Text(
                currentUser.initials.substring(0, 1),
                style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension ListX<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) if (test(e)) return e;
    return null;
  }
}