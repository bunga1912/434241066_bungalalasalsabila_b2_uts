import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../auth/presentation/providers/auth_provider.dart';

final tsTicketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

/// User TS yang sedang login
final currentTsProvider = Provider((ref) {
  return ref.watch(currentUserProvider);
});

class TsTicketNotifier
    extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String _assigneeId;

  TsTicketNotifier(this._repository, this._assigneeId)
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
}

final tsTicketProvider = StateNotifierProvider.autoDispose<
    TsTicketNotifier,
    AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(tsTicketRepositoryProvider);
  final user = ref.watch(currentTsProvider);
  final assigneeId = user?.id ?? '';
  return TsTicketNotifier(repository, assigneeId);
});

/// Statistik tugas TS untuk dashboard
final tsStatsProvider =
FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(tsTicketRepositoryProvider);
  final user = ref.watch(currentTsProvider);
  if (user == null) {
    return {'forwarded': 0, 'in_progress': 0, 'close': 0, 'total': 0};
  }

  final tickets = await repo.getTicketsByAssignee(user.id);

  return {
    'forwarded': tickets.where((t) => t.status == 'forwarded').length,
    'in_progress': tickets.where((t) => t.status == 'in_progress').length,
    'close': tickets.where((t) => t.status == 'close').length,
    'total': tickets.length,
  };
});

/// Jumlah tiket baru forwarded (badge notifikasi)
final tsUnreadCountProvider =
FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(tsTicketRepositoryProvider);
  final user = ref.watch(currentTsProvider);
  if (user == null) return 0;

  final tickets = await repo.getTicketsByAssignee(user.id);
  return tickets.where((t) => t.status == 'forwarded').length;
});

/// Selected nav index untuk TS shell
final tsNavIndexProvider = StateProvider<int>((ref) => 0);