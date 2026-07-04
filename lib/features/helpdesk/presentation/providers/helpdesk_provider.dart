import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final helpdeskTicketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

final helpdeskUserRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// User helpdesk yang sedang login
final currentHelpdeskProvider = Provider<UserModel?>((ref) {
  return ref.watch(currentUserProvider);
});

/// Tiket yang ditugaskan ke helpdesk ini
class HelpdeskTicketListNotifier
    extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String _assigneeId;

  HelpdeskTicketListNotifier(this._repository, this._assigneeId)
      : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getTicketsByAssignee(_assigneeId);
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async => await loadTickets();

  /// Tutup tiket
  Future<void> closeTicket(String ticketId) async {
    await _repository.closeTicket(ticketId, _assigneeId);
    await loadTickets();
  }

  /// Forward tiket ke Technical Support
  Future<void> forwardToTs(
      String ticketId,
      String tsId, {
        String? note,
      }) async {
    await _repository.forwardToTechnicalSupport(
      ticketId,
      tsId,
      actor: _assigneeId,
      note: note,
    );
    await loadTickets();
  }
}

final helpdeskTicketListProvider = StateNotifierProvider.autoDispose<
    HelpdeskTicketListNotifier,
    AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(helpdeskTicketRepositoryProvider);
  final user = ref.watch(currentHelpdeskProvider);
  final assigneeId = user?.id ?? '';
  return HelpdeskTicketListNotifier(repository, assigneeId);
});

/// Statistik tugas helpdesk untuk dashboard
final helpdeskStatsProvider =
FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(helpdeskTicketRepositoryProvider);
  final user = ref.watch(currentHelpdeskProvider);
  if (user == null) return {'assigned': 0, 'forwarded': 0, 'close': 0, 'in_progress': 0};

  final tickets = await repo.getTicketsByAssignee(user.id);

  return {
    'assigned': tickets.where((t) => t.status == 'assigned').length,
    'forwarded': tickets.where((t) => t.status == 'forwarded').length,
    'closed': tickets.where((t) => t.status == 'close').length,
    'in_progress': tickets.where((t) => t.status == 'in_progress').length,
  };
});

/// Daftar Technical Support untuk forward
final technicalSupportListProvider =
FutureProvider.autoDispose<List<UserModel>>((ref) async {
  final repo = ref.watch(helpdeskUserRepositoryProvider);
  return repo.getUsersByRole('technical_support');
});

/// Selected nav index untuk helpdesk shell
final helpdeskNavIndexProvider = StateProvider<int>((ref) => 0);

/// Jumlah tiket baru (badge notifikasi)
final helpdeskUnreadCountProvider =
FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(helpdeskTicketRepositoryProvider);
  final user = ref.watch(currentHelpdeskProvider);
  if (user == null) return 0;

  final tickets = await repo.getTicketsByAssignee(user.id);
  return tickets.where((t) => t.status == 'assigned').length;
});