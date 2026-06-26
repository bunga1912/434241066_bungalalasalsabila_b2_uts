import '../models/ticket_model.dart';
import '../models/comment_model.dart';

class TicketRepository {
  // Dummy data tiket
  static final List<TicketModel> _tickets = [
    TicketModel(
      id: 'TKT-001',
      title: 'Tidak bisa login ke portal akademik',
      description:
      'Setiap kali login muncul error 500, sudah coba clear cache tapi masih sama',
      status: 'pending',
      category: 'Akun',
      createdBy: 'Budi Santoso',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    TicketModel(
      id: 'TKT-002',
      title: 'Wifi perpustakaan lambat',
      description:
      'Koneksi sangat lambat sejak pagi, sulit untuk download materi',
      status: 'pending',
      category: 'Jaringan',
      createdBy: 'Siti Rahma',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    TicketModel(
      id: 'TKT-003',
      title: 'Laptop dinas error blue screen',
      description:
      'Laptop sering blue screen saat dipakai presentasi, butuh pengecekan hardware',
      status: 'assigned',
      category: 'Hardware',
      createdBy: 'Andi Wijaya',
      assignedTo: 'Helpdesk - Rina',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    TicketModel(
      id: 'TKT-004',
      title: 'Aplikasi SIAKAD tidak bisa diakses',
      description: 'Halaman blank putih saat dibuka',
      status: 'forwarded',
      category: 'Aplikasi',
      createdBy: 'Dewi Lestari',
      assignedTo: 'TS - Fajar',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TicketModel(
      id: 'TKT-005',
      title: 'Printer ruang dosen rusak',
      description: 'Printer tidak menyala sama sekali',
      status: 'in_progress',
      category: 'Hardware',
      createdBy: 'Hendra Gunawan',
      assignedTo: 'TS - Fajar',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    TicketModel(
      id: 'TKT-006',
      title: 'Reset password email kampus',
      description: 'Lupa password, butuh reset',
      status: 'resolved',
      category: 'Akun',
      createdBy: 'Maya Putri',
      assignedTo: 'Helpdesk - Rina',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TicketModel(
      id: 'TKT-007',
      title: 'Proyektor kelas B201 tidak menyala',
      description: 'Sudah dicoba berbagai kabel tetap tidak menyala',
      status: 'closed',
      category: 'Hardware',
      createdBy: 'Rio Pratama',
      assignedTo: 'TS - Joko',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TicketModel(
      id: 'TKT-008',
      title: 'Lupa password akun SSO',
      description: 'Tidak bisa mengakses akun, butuh reset password',
      status: 'assigned',
      category: 'Akun',
      createdBy: 'Lina Marlina',
      assignedTo: 'Helpdesk - Rina',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  static final List<CommentModel> _comments = [
    CommentModel(
      id: 'C-001',
      ticketId: 'TKT-003',
      userId: '2',
      userName: 'Rina Wulandari',
      message: 'Sudah saya cek, kemungkinan masalah di RAM. Akan saya jadwalkan pengecekan lebih lanjut.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CommentModel(
      id: 'C-002',
      ticketId: 'TKT-003',
      userId: '4',
      userName: 'Andi Wijaya',
      message: 'Baik, terima kasih. Saya tunggu update selanjutnya.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
  ];

  /// Get all tickets
  Future<List<TicketModel>> getAllTickets() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_tickets);
  }

  /// Get tickets by status
  Future<List<TicketModel>> getTicketsByStatus(List<String> statuses) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _tickets.where((t) => statuses.contains(t.status)).toList();
  }

  /// Get tickets assigned to a specific person
  Future<List<TicketModel>> getTicketsByAssignee(String assignee) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _tickets.where((t) => t.assignedTo == assignee).toList();
  }

  /// Get tickets created by a specific user
  Future<List<TicketModel>> getTicketsByCreator(String creator) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _tickets.where((t) => t.createdBy == creator).toList();
  }

  /// Get ticket by id
  Future<TicketModel?> getTicketById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create new ticket
  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String category,
    required String createdBy,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final newTicket = TicketModel(
      id: 'TKT-${(_tickets.length + 1).toString().padLeft(3, '0')}',
      title: title,
      description: description,
      status: 'pending',
      category: category,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      history: [
        TicketHistory(
          status: 'pending',
          description: 'Tiket dibuat',
          timestamp: DateTime.now(),
          actor: createdBy,
        ),
      ],
    );

    _tickets.insert(0, newTicket);
    return newTicket;
  }

  /// Assign ticket to helpdesk (by Admin)
  Future<void> assignToHelpdesk(String ticketId, String helpdeskName) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final ticket = await getTicketById(ticketId);
    if (ticket != null) {
      ticket.status = 'assigned';
      ticket.assignedTo = helpdeskName;
      ticket.history.add(
        TicketHistory(
          status: 'assigned',
          description: 'Tiket di-assign ke $helpdeskName',
          timestamp: DateTime.now(),
          actor: 'Admin',
        ),
      );
    }
  }

  /// Forward ticket to Technical Support (by Helpdesk)
  Future<void> forwardToTechnicalSupport(
      String ticketId,
      String tsName, {
        String? note,
      }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final ticket = await getTicketById(ticketId);
    if (ticket != null) {
      ticket.status = 'forwarded';
      ticket.assignedTo = tsName;
      ticket.history.add(
        TicketHistory(
          status: 'forwarded',
          description: note != null && note.isNotEmpty
              ? 'Diteruskan ke $tsName — $note'
              : 'Diteruskan ke $tsName',
          timestamp: DateTime.now(),
          actor: 'Helpdesk',
        ),
      );
    }
  }

  /// Update status to in_progress (TS started working)
  Future<void> markInProgress(String ticketId, String actor) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final ticket = await getTicketById(ticketId);
    if (ticket != null) {
      ticket.status = 'in_progress';
      ticket.history.add(
        TicketHistory(
          status: 'in_progress',
          description: 'Mulai dikerjakan',
          timestamp: DateTime.now(),
          actor: actor,
        ),
      );
    }
  }

  /// Mark ticket as resolved
  Future<void> markResolved(String ticketId, String actor) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final ticket = await getTicketById(ticketId);
    if (ticket != null) {
      ticket.status = 'resolved';
      ticket.history.add(
        TicketHistory(
          status: 'resolved',
          description: 'Tiket ditandai selesai',
          timestamp: DateTime.now(),
          actor: actor,
        ),
      );
    }
  }

  /// Close ticket (confirmed by user)
  Future<void> closeTicket(String ticketId, String actor) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final ticket = await getTicketById(ticketId);
    if (ticket != null) {
      ticket.status = 'closed';
      ticket.history.add(
        TicketHistory(
          status: 'closed',
          description: 'Tiket ditutup oleh pengguna',
          timestamp: DateTime.now(),
          actor: actor,
        ),
      );
    }
  }

  /// Get comments for a ticket
  Future<List<CommentModel>> getCommentsByTicketId(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _comments.where((c) => c.ticketId == ticketId).toList();
  }

  /// Add comment to a ticket
  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final comment = CommentModel(
      id: 'C-${(_comments.length + 1).toString().padLeft(3, '0')}',
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      message: message,
      createdAt: DateTime.now(),
    );

    _comments.add(comment);
    return comment;
  }

  /// Get ticket statistics (for dashboard)
  Future<Map<String, int>> getTicketStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'total': _tickets.length,
      'pending': _tickets.where((t) => t.status == 'pending').length,
      'assigned': _tickets.where((t) => t.status == 'assigned').length,
      'in_progress': _tickets.where((t) => t.status == 'in_progress').length,
      'forwarded': _tickets.where((t) => t.status == 'forwarded').length,
      'resolved': _tickets.where((t) => t.status == 'resolved').length,
      'closed': _tickets.where((t) => t.status == 'closed').length,
    };
  }
}