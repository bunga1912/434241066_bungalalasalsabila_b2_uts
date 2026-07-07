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
      'status': 'open',
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
      status: 'open',
      description: 'Tiket dibuat',
      actor: createdBy,
    );

    return ticket;
  }

  // ---------------------------------------------------------------------------
  // STATUS TRANSITIONS
  // ---------------------------------------------------------------------------

  /// Admin men-assign tiket ke helpdesk (UUID)
  ///
  /// [actor] harus berupa UUID user (kolom `ticket_history.actor` bertipe uuid).
  /// Kalau tidak diisi eksplisit oleh pemanggil, akan diambil dari user yang
  /// sedang login (auth.currentUser), dan sebagai fallback terakhir memakai
  /// helpdeskId itu sendiri supaya tidak pernah mengirim string non-uuid
  /// seperti "Admin".
  Future<void> assignToHelpdesk(
      String ticketId,
      String helpdeskId, {
        String? actor,
      }) async {
    await _client.from('tickets').update({
      'status': 'in_progress',
      'assigned_to': helpdeskId,
    }).eq('id', ticketId);

    await _addHistory(
      ticketId: ticketId,
      status: 'in_progress',
      description: 'Ditugaskan ke helpdesk dan mulai dikerjakan',
      actor: actor ?? _client.auth.currentUser?.id ?? helpdeskId,
    );
  }

  /// Helpdesk meneruskan tiket ke Technical Support (UUID)
  ///
  /// [actor] harus berupa UUID user (kolom `ticket_history.actor` bertipe uuid).
  /// Kalau tidak diisi eksplisit oleh pemanggil, akan diambil dari user yang
  /// sedang login (auth.currentUser), dan sebagai fallback terakhir memakai
  /// tsId itu sendiri supaya tidak pernah mengirim string non-uuid
  /// seperti "Helpdesk".
  Future<void> forwardToTechnicalSupport(
      String ticketId,
      String tsId, {
        String? actor,
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
      actor: actor ?? _client.auth.currentUser?.id ?? tsId,
    );
  }

  Future<void> closeTicket(String ticketId, String actor) async {
    await _client
        .from('tickets')
        .update({'status': 'close'})
        .eq('id', ticketId);

    await _addHistory(
      ticketId: ticketId,
      status: 'close',
      description: 'Tiket diselesaikan',
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

  /// Ambil semua riwayat yang dilakukan oleh satu user (actor) tertentu,
  /// beserta judul tiketnya, terbaru duluan. Dipakai untuk halaman
  /// History milik helpdesk/TS (menggantikan halaman Notifikasi).
  ///
  /// Catatan: query ini mengasumsikan ada relasi foreign key dari
  /// ticket_history.ticket_id -> tickets.id sehingga embed `tickets(title)`
  /// bisa dipakai. Kalau Supabase tidak otomatis mendeteksi relasinya,
  /// sesuaikan nama constraint FK-nya, misal:
  /// `tickets!ticket_history_ticket_id_fkey(title)`.
  Future<List<Map<String, dynamic>>> getHistoryByActor(String actorId) async {
    final response = await _client
        .from('ticket_history')
        .select('id, ticket_id, status, description, timestamp, tickets(title)')
        .eq('actor', actorId)
        .order('timestamp', ascending: false);

    return (response as List).map((row) {
      return {
        'id': row['id'],
        'ticket_id': row['ticket_id'],
        'status': row['status'],
        'description': row['description'],
        'timestamp': row['timestamp'],
        'ticket_title': row['tickets']?['title'] ?? '-',
      };
    }).toList();
  }

  /// Internal helper — tulis satu baris histori
  Future<void> _addHistory({
    required String ticketId,
    required String status,
    required String description,
    required String actor, // UUID user (kolom actor bertipe uuid)
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
      'open': 0,
      'in_progress': 0,
      'forwarded': 0,
      'close': 0,
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
        .inFilter('status', ['forwarded', 'in_progress']);

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