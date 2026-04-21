import 'package:flutter/material.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/comment_model.dart';
import '../widgets/status_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _commentController = TextEditingController();
  late String _currentStatus;
  late String? _assignedTo;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ticket.status;
    _assignedTo = widget.ticket.assignedTo;
  }

  List<CommentModel> get _comments =>
      dummyComments.where((c) => c.ticketId == widget.ticket.id).toList();

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      dummyComments.add(CommentModel(
        id: 'c${dummyComments.length + 1}',
        ticketId: widget.ticket.id,
        userId: currentUser.id,
        userName: currentUser.name,
        message: _commentController.text.trim(),
        createdAt: DateTime.now(),
      ));
      _commentController.clear();
    });
  }

  void _updateStatus(String newStatus) {
    setState(() {
      _currentStatus = newStatus;
      // Update di dummy data juga
      final idx = dummyTickets.indexWhere((t) => t.id == widget.ticket.id);
      if (idx != -1) {
        dummyTickets[idx] = TicketModel(
          id: widget.ticket.id,
          title: widget.ticket.title,
          description: widget.ticket.description,
          status: newStatus,
          category: widget.ticket.category,
          createdBy: widget.ticket.createdBy,
          assignedTo: _assignedTo,
          createdAt: widget.ticket.createdAt,
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi $newStatus')));
  }

  void _assignTicket(String helpdeskId) {
    setState(() {
      _assignedTo = helpdeskId;
      final idx = dummyTickets.indexWhere((t) => t.id == widget.ticket.id);
      if (idx != -1) {
        dummyTickets[idx] = TicketModel(
          id: widget.ticket.id,
          title: widget.ticket.title,
          description: widget.ticket.description,
          status: _currentStatus,
          category: widget.ticket.category,
          createdBy: widget.ticket.createdBy,
          assignedTo: helpdeskId,
          createdAt: widget.ticket.createdAt,
        );
      }
    });
    final helpdesk = dummyUsers.firstWhere((u) => u.id == helpdeskId);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tiket di-assign ke ${helpdesk.name}')));
  }

  @override
  Widget build(BuildContext context) {
    final helpdeskUsers = dummyUsers.where((u) => u.role == 'helpdesk').toList();
    final assignedUser = _assignedTo != null
        ? dummyUsers.firstWhere((u) => u.id == _assignedTo,
        orElse: () => dummyUsers[0])
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info tiket
                Text(widget.ticket.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  StatusBadge(status: _currentStatus),
                  const SizedBox(width: 8),
                  Text(widget.ticket.category,
                      style: const TextStyle(color: Colors.grey)),
                ]),
                const SizedBox(height: 12),
                Text(widget.ticket.description),
                const SizedBox(height: 8),
                Text(timeago.format(widget.ticket.createdAt, locale: 'id'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),

                // Info assign
                if (_assignedTo != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.person_pin, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Ditangani oleh: ${assignedUser?.name ?? '-'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ],

                // Update status — hanya admin/helpdesk
                if (currentUser.role != 'user') ...[
                  const Divider(height: 32),
                  const Text('Update Status',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['open', 'in_progress', 'resolved', 'closed']
                        .map((s) => ChoiceChip(
                      label: Text(s),
                      selected: _currentStatus == s,
                      onSelected: (_) => _updateStatus(s),
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: _currentStatus == s ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    )).toList(),
                  ),

                  // Assign tiket — hanya admin
                  if (currentUser.role == 'admin') ...[
                    const SizedBox(height: 16),
                    const Text('Assign ke Helpdesk',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _assignedTo,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Pilih helpdesk',
                      ),
                      items: helpdeskUsers.map((u) => DropdownMenuItem(
                        value: u.id,
                        child: Text(u.name),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) _assignTicket(val);
                      },
                    ),
                  ],
                ],

                // Komentar
                const Divider(height: 32),
                const Text('Komentar',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_comments.isEmpty)
                  const Text('Belum ada komentar.',
                      style: TextStyle(color: Colors.grey)),
                ..._comments.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.userId == currentUser.id
                        ? const Color(0xFFEFF6FF)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(c.message),
                      const SizedBox(height: 4),
                      Text(timeago.format(c.createdAt, locale: 'id'),
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // Input komentar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}