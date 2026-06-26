import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../../data/repositories/user_repository.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Statistik untuk dashboard admin
final adminStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketStats();
});

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

  Future<void> refresh() async => await loadTickets();

  /// Assign tiket ke helpdesk
  Future<void> assignToHelpdesk(String ticketId, String helpdeskName) async {
    await _repository.assignToHelpdesk(ticketId, helpdeskName);
    await loadTickets();
  }
}

final adminTicketListProvider = StateNotifierProvider.autoDispose<
    AdminTicketListNotifier,
    AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(ticketRepositoryProvider);
  return AdminTicketListNotifier(repository);
});

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

Future<void> refresh() async => await loadUsers();

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
    AdminUserListNotifier,
    AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AdminUserListNotifier(repository);
});

/// Daftar helpdesk untuk dropdown assign
final helpdeskListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
final repo = ref.watch(userRepositoryProvider);
return repo.getUsersByRole('helpdesk');
});

/// Selected nav index untuk admin shell
final adminNavIndexProvider = StateProvider<int>((ref) => 0);