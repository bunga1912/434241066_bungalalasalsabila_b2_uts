import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../../data/repositories/user_repository.dart';

final helpdeskTicketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

final helpdeskUserRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Nama helpdesk yang sedang login (dummy, hardcode dulu)
final currentHelpdeskNameProvider = Provider<String>((ref) {
  return 'Helpdesk - Rina';
});

/// Tiket yang ditugaskan ke helpdesk ini
class HelpdeskTicketListNotifier
    extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String _assignee;

  HelpdeskTicketListNotifier(this._repository, this._assignee)
      : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getTicketsByAssignee(_assignee);
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async => await loadTickets();

  /// Resolve tiket sendiri
  Future<void> resolveTicket(String ticketId) async {
    await _repository.markResolved(ticketId, _assignee);
    await loadTickets();
  }

  /// Forward tiket ke TS
  Future<void> forwardToTs(String ticketId, String tsName, {String? note}) async {
    await _repository.forwardToTechnicalSupport(ticketId, tsName, note: note);
    await loadTickets();
  }
}

final helpdeskTicketListProvider =
StateNotifierProvider.autoDispose<
    HelpdeskTicketListNotifier,
    AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(helpdeskTicketRepositoryProvider);
  final assignee = ref.watch(currentHelpdeskNameProvider);

  return HelpdeskTicketListNotifier(repository, assignee);
});

/// Statistik tugas helpdesk untuk dashboard
final helpdeskStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
final repo = ref.watch(helpdeskTicketRepositoryProvider);
final assignee = ref.watch(currentHelpdeskNameProvider);
final tickets = await repo.getTicketsByAssignee(assignee);

return {
'assigned': tickets.where((t) => t.status == 'assigned').length,
'forwarded': tickets.where((t) => t.status == 'forwarded').length,
'resolved': tickets.where((t) => t.status == 'resolved').length,
'in_progress': tickets.where((t) => t.status == 'in_progress').length,
};
});

/// Daftar Technical Support untuk forward
final technicalSupportListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) async {
final repo = ref.watch(helpdeskUserRepositoryProvider);
return repo.getUsersByRole('technical_support');
});

/// Selected nav index untuk helpdesk shell
final helpdeskNavIndexProvider = StateProvider<int>((ref) => 0);