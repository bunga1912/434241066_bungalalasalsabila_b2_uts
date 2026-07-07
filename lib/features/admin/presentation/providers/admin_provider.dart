import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// ─────────────────────────────────────────────────────────────────────────────
// STATS
// ─────────────────────────────────────────────────────────────────────────────

/// Statistik ringkasan tiket (total, open, in_progress, closed, resolved, dll)
final adminStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketStats();
});

/// Statistik per kategori → { 'Software': 20, 'Hardware': 15, ... }
final adminCategoryStatsProvider =
FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketStatsByCategory();
});

// ─────────────────────────────────────────────────────────────────────────────
// TIKET
// ─────────────────────────────────────────────────────────────────────────────

/// Semua tiket (untuk admin_ticket_list_screen)
class AdminTicketListNotifier
    extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;

  AdminTicketListNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAllTickets();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async => loadTickets();

  Future<void> assignToHelpdesk(String ticketId, String helpdeskName) async {
    await _repository.assignToHelpdesk(ticketId, helpdeskName);
    await loadTickets();
  }
}

final adminTicketListProvider = StateNotifierProvider.autoDispose<
    AdminTicketListNotifier, AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  return AdminTicketListNotifier(repository);
});

/// 3 tiket terbaru untuk dashboard (id, title, status, user_name)
final adminRecentTicketsProvider =
FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getRecentTickets(limit: 3);
});

// ─────────────────────────────────────────────────────────────────────────────
// PENGGUNA
// ─────────────────────────────────────────────────────────────────────────────

/// Daftar pengguna (untuk admin_manage_users_screen)
class AdminUserListNotifier
    extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepository _repository;

  AdminUserListNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAllUsers();
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async => loadUsers();

  Future<void> deleteUser(String userId) async {
    await _repository.deleteUser(userId);
    await loadUsers();
  }

  Future<void> updateRole(String userId, String newRole) async {
    await _repository.updateUserRole(userId, newRole);
    await loadUsers();
  }
}

final adminUserListProvider = StateNotifierProvider.autoDispose<
    AdminUserListNotifier, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AdminUserListNotifier(repository);
});

// ─────────────────────────────────────────────────────────────────────────────
// HELPDESK
// ─────────────────────────────────────────────────────────────────────────────

/// Daftar helpdesk untuk dropdown assign tiket
final helpdeskListProvider =
FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUsersByRole('helpdesk');
});

/// Helpdesk aktif beserta jumlah tiket yang sedang ditangani
/// Returned: List<Map> dengan key: name, ticket_count
final adminHelpdeskActiveProvider =
FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getHelpdeskWithTicketCounts();
});
// ─────────────────────────────────────────────────────────────────────────────
// AKTIVITAS
// ─────────────────────────────────────────────────────────────────────────────

final adminRecentActivitiesProvider =
FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = Supabase.instance.client;

  // FIX: sebelumnya cuma select kolom 'actor' (UUID mentah), sehingga
  // UI menampilkan ID, bukan nama. Sekarang di-join ke tabel users lewat
  // foreign key ticket_history.actor -> users.id, supaya nama ikut terbawa.
  final response = await client
      .from('ticket_history')
      .select(
      'id, status, description, timestamp, actor, ticket_id, '
          'actor_user:users!ticket_history_actor_fkey(name)')
      .order('timestamp', ascending: false)
      .limit(10);

  final rows = List<Map<String, dynamic>>.from(response as List);

  // Ratakan hasil join supaya widget cukup baca key 'actor_name'
  // tanpa perlu tahu struktur nested map dari Supabase.
  return rows.map((row) {
    final actorUser = row['actor_user'] as Map<String, dynamic>?;
    return {
      ...row,
      'actor_name': actorUser?['name'] as String?,
    };
  }).toList();
});
// ─────────────────────────────────────────────────────────────────────────────
// PENGUMUMAN
// ─────────────────────────────────────────────────────────────────────────────

class AnnouncementNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TicketRepository _repository;

  AnnouncementNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAnnouncements();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAnnouncement({
    required String title,
    required String description,
  }) async {
    await _repository.addAnnouncement(
      title: title,
      description: description,
    );
    await _load();
  }

  Future<void> deleteAnnouncement(String id) async {
    await _repository.deleteAnnouncement(id);
    await _load();
  }
}

final adminAnnouncementProvider = StateNotifierProvider.autoDispose<
    AnnouncementNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  return AnnouncementNotifier(repository);
});

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGASI
// ─────────────────────────────────────────────────────────────────────────────