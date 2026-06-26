import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/ticket_model.dart';
import '../../../../data/repositories/ticket_repository.dart';

final tsTicketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

/// Nama TS yang sedang login (dummy)
final currentTsNameProvider = Provider<String>((ref) {
  return 'TS - Fajar';
});

class TsTicketNotifier
    extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String _assignee;

  TsTicketNotifier(
      this._repository,
      this._assignee,
      ) : super(const AsyncValue.loading()) {
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

  Future<void> refresh() async {
    await loadTickets();
  }

  Future<void> markInProgress(String ticketId) async {
    await _repository.markInProgress(ticketId, _assignee);
    await loadTickets();
  }

  Future<void> resolveTicket(String ticketId) async {
    await _repository.markResolved(ticketId, _assignee);
    await loadTickets();
  }
}

final tsTicketProvider = StateNotifierProvider.autoDispose<
    TsTicketNotifier,
    AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(tsTicketRepositoryProvider);
  final assignee = ref.watch(currentTsNameProvider);

  return TsTicketNotifier(repository, assignee);
});

final tsStatsProvider =
FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(tsTicketRepositoryProvider);
  final assignee = ref.watch(currentTsNameProvider);

  final tickets = await repo.getTicketsByAssignee(assignee);

  return {
    'forwarded': tickets.where((t) => t.status == 'forwarded').length,
    'in_progress': tickets.where((t) => t.status == 'in_progress').length,
    'resolved': tickets.where((t) => t.status == 'resolved').length,
    'total': tickets.length,
  };
});

final tsNavIndexProvider = StateProvider<int>((ref) => 0);