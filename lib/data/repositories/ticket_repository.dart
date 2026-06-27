import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/ticket_history_model.dart';
import '../models/announcement_model.dart';

class TicketRepository {
  final SupabaseClient _client;

  TicketRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // TICKETS
  // ---------------------------------------------------------------------------

  /// Ambil semua tiket, join nama pembuat & penerima tugas dari tabel users
  Future<List<TicketModel>> getAllTickets() async {
    final response = await _client
        .from('tickets')
        .select('''
          *,
          created_by_user:users!tickets_created_by_fkey(name),
          assigned_to_user:users!tickets_assigned_to_fkey(name)
        ''')
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => TicketModel.fromMap(row))
        .toList();
  }

  /// Filter tiket berdasarkan satu atau beberapa status
  Future<List<TicketModel>> getTicketsByStatus(List<String> statuses) async {
    final response = await _client
        .from('tickets')
        .select('''
          *,
          created_by_user:users!tickets_created_by_fkey(name),
          assigned_to_user:users!tickets_assigned_to_fkey(name)
        ''')
        .inFilter('status', statuses)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => TicketModel.fromMap(row))
        .toList();
  }

  /// Tiket yang di-assign ke UUID tertentu (helpdesk / TS)
  Future<List<TicketModel>> getTicketsByAssignee(String assigneeId) async {
    final response = await _client
        .from('tickets')
        .select('''
          *,
          created_by_user:users!tickets_created_by_fkey(name),
          assigned_to_user:users!tickets_assigned_to_fkey(name)
        ''')
        .eq('assigned_to', assigneeId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => TicketModel.fromMap(row))
        .toList();
  }

  /// Tiket yang dibuat oleh UUID tertentu (user/mahasiswa)
  Future<List<TicketModel>> getTicketsByCreator(String creatorId) async {
    final response = await _client
        .from('tickets')
        .select('''
          *,
          created_by_user:users!tickets_created_by_fkey(name),
          assigned_to_user:users!tickets_assigned_to_fkey(name)
        ''')
        .eq('created_by', creatorId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => TicketModel.fromMap(row))
        .toList();
  }

  /// Ambil satu tiket berdasarkan ID
  Future<TicketModel?> getTicketById(String id) async {
    final response = await _client
        .from('tickets')
        .select('''
          *,
          created_by_user:users!tickets_created_by_fkey(name),
          assigned_to_user:users!tickets_assigned_to_fkey(name)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return TicketModel.fromMap(response);
  }

  /// Buat tiket baru — status awal selalu 'pending'
  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String category,
    required String createdBy, // UUID user
  }) async {
    // Insert tiket
    final ticketResponse = await _client
        .from('tickets')
        .insert({
      'title': title,
      'description': description,
      'status': 'pending',
      'category': category,
      'created_by': createdBy,
    })
        .select('''
          *,
          created_by_user:users!tickets_created_by_fkey(name),
          assigned_to_user:users!tickets_assigned_to_fkey(name)
        ''')
        .single();

    final ticket = TicketModel.fromMap(ticketResponse);

    // Catat histori awal
    await _addHistory(
      ticketId: ticket.id,
      status: 'pending',
      description: 'Tiket dibuat',
      actor: createdBy,
    );

    return ticket;
  }

  // ---------------------------------------------------------------------------
  // STATUS TRANSITIONS
  // ---------------------------------------------------------------------------

  /// Admin men-assign tiket ke helpdesk (UUID)
  Future<void> assignToHelpdesk(
      String ticketId,
      String helpdeskId, {
        String actor = 'Admin',
      }) async {
    await _client.from('tickets').update({
      'status': 'assigned',
      'assigned_to': helpdeskId,
    }).eq('id', ticketId);

    await _addHistory(
      ticketId: ticketId,
      status: 'assigned',
      description: 'Tiket di-assign ke helpdesk',
      actor: actor,
    );
  }

  /// Helpdesk meneruskan tiket ke Technical Support (UUID)
  Future<void> forwardToTechnicalSupport(
      String ticketId,
      String tsId, {
        String actor = 'Helpdesk',
        String? note,
      }) async {
    await _client.from('tickets').update({
      'status': 'forwarded',
      'assigned_to': tsId,
    }).eq('id', ticketId);

    await _addHistory(
      ticketId: ticketId,
      status: 'forwarded',
      description: note != null && note.isNotEmpty
          ? 'Diteruskan ke TS — $note'
          : 'Diteruskan ke Technical Support',
      actor: actor,
    );
  }

  /// TS mulai mengerjakan tiket
  Future<void> markInProgress(String ticketId, String actor) async {
    await _client
        .from('tickets')
        .update({'status': 'in_progress'})
        .eq('id', ticketId);

    await _addHistory(
      ticketId: ticketId,
      status: 'in_progress',
      description: 'Mulai dikerjakan',
      actor: actor,
    );
  }

  /// Tandai tiket selesai (resolved)
  Future<void> markResolved(String ticketId, String actor) async {
    await _client
        .from('tickets')
        .update({'status': 'resolved'})
        .eq('id', ticketId);

    await _addHistory(
      ticketId: ticketId,
      status: 'resolved',
      description: 'Tiket ditandai selesai',
      actor: actor,
    );
  }

  /// User menutup tiket (closed) setelah konfirmasi
  Future<void> closeTicket(String ticketId, String actor) async {
    await _client
        .from('tickets')
        .update({'status': 'closed'})
        .eq('id', ticketId);

    await _addHistory(
      ticketId: ticketId,
      status: 'closed',
      description: 'Tiket ditutup oleh pengguna',
      actor: actor,
    );
  }

  // ---------------------------------------------------------------------------
  // TICKET HISTORY
  // ---------------------------------------------------------------------------

  /// Ambil semua riwayat satu tiket, urut dari terlama
  Future<List<TicketHistoryModel>> getHistoryByTicketId(
      String ticketId) async {
    final response = await _client
        .from('ticket_history')
        .select()
        .eq('ticket_id', ticketId)
        .order('timestamp', ascending: true);

    return (response as List)
        .map((row) => TicketHistoryModel.fromMap(row))
        .toList();
  }

  /// Internal helper — tulis satu baris histori
  Future<void> _addHistory({
    required String ticketId,
    required String status,
    required String description,
    required String actor, // UUID user atau label role
  }) async {
    await _client.from('ticket_history').insert({
      'ticket_id': ticketId,
      'status': status,
      'description': description,
      'actor': actor,
    });
  }

  // ---------------------------------------------------------------------------
  // COMMENTS
  // ---------------------------------------------------------------------------

  /// Ambil semua komentar untuk satu tiket
  Future<List<CommentModel>> getCommentsByTicketId(String ticketId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((row) => CommentModel.fromMap(row))
        .toList();
  }

  /// Tambah komentar baru
  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    final response = await _client
        .from('comments')
        .insert({
      'ticket_id': ticketId,
      'user_id': userId,
      'user_name': userName,
      'message': message,
    })
        .select()
        .single();

    return CommentModel.fromMap(response);
  }

  // ---------------------------------------------------------------------------
  // ANNOUNCEMENTS
  // ---------------------------------------------------------------------------

  /// Ambil semua pengumuman, terbaru duluan
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    final response = await _client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => AnnouncementModel.fromMap(row))
        .toList();
  }

  /// Buat pengumuman baru (hanya Admin)
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String description,
    required String createdBy, // UUID admin
  }) async {
    final response = await _client
        .from('announcements')
        .insert({
      'title': title,
      'description': description,
      'created_by': createdBy,
    })
        .select()
        .single();

    return AnnouncementModel.fromMap(response);
  }

  // ---------------------------------------------------------------------------
  // ANNOUNCEMENTS (dipakai admin_provider)
  // ---------------------------------------------------------------------------

  /// Ambil semua pengumuman sebagai raw Map (tanpa model)
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await _client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Tambah pengumuman baru — createdBy diambil dari session aktif
  Future<void> addAnnouncement({
    required String title,
    required String description,
  }) async {
    final userId = _client.auth.currentUser?.id;
    await _client.from('announcements').insert({
      'title': title,
      'description': description,
      if (userId != null) 'created_by': userId,
    });
  }

  /// Hapus pengumuman berdasarkan ID
  Future<void> deleteAnnouncement(String id) async {
    await _client.from('announcements').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // STATISTICS (dashboard)
  // ---------------------------------------------------------------------------

  /// Hitung jumlah tiket per status sekaligus lewat satu query
  Future<Map<String, int>> getTicketStats() async {
    final response = await _client.from('tickets').select('status');

    final list = response as List;
    final stats = <String, int>{
      'total': list.length,
      'pending': 0,
      'assigned': 0,
      'in_progress': 0,
      'forwarded': 0,
      'resolved': 0,
      'closed': 0,
    };

    for (final row in list) {
      final status = row['status'] as String;
      if (stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      }
    }

    return stats;
  }

  /// Hitung jumlah tiket per kategori → { 'Hardware': 5, 'Akun': 3, ... }
  Future<Map<String, int>> getTicketStatsByCategory() async {
    final response = await _client.from('tickets').select('category');

    final result = <String, int>{};
    for (final row in response as List) {
      final cat = (row['category'] as String?) ?? 'Lainnya';
      result[cat] = (result[cat] ?? 0) + 1;
    }
    return result;
  }

  /// N tiket terbaru untuk ringkasan dashboard
  /// Returned: List<Map> dengan key: id, title, status, created_by_name
  Future<List<Map<String, dynamic>>> getRecentTickets({int limit = 3}) async {
    final response = await _client
        .from('tickets')
        .select('''
          id,
          title,
          status,
          created_by_user:users!tickets_created_by_fkey(name)
        ''')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((row) {
      return {
        'id': row['id'],
        'title': row['title'],
        'status': row['status'],
        'created_by_name': row['created_by_user']?['name'] ?? '-',
      };
    }).toList();
  }

  /// Helpdesk aktif beserta jumlah tiket yang sedang ditangani
  /// Returned: List<Map> dengan key: name, ticket_count
  Future<List<Map<String, dynamic>>> getHelpdeskWithTicketCounts() async {
    // Ambil semua user role helpdesk
    final usersResp = await _client
        .from('users')
        .select('id, name')
        .eq('role', 'helpdesk');

    // Ambil tiket aktif (bukan closed/resolved) yang punya assignee
    final ticketsResp = await _client
        .from('tickets')
        .select('assigned_to')
        .inFilter('status', ['assigned', 'forwarded', 'in_progress']);

    // Hitung per assignee
    final counts = <String, int>{};
    for (final row in ticketsResp as List) {
      final id = row['assigned_to'] as String?;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }

    return (usersResp as List).map((u) {
      return {
        'name': u['name'] as String,
        'ticket_count': counts[u['id'] as String] ?? 0,
      };
    }).toList();
  }
}