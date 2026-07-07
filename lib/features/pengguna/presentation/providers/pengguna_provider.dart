import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final penggunaTicketRepositoryProvider =
Provider<TicketRepository>((ref) {
  return TicketRepository();
});

/// User yang sedang login
final currentUserProvider = Provider((ref) {
  return ref.watch(authProvider).whenOrNull(data: (u) => u);
});

/// Nama pengguna yang sedang login (dari authProvider)
final currentPenggunaNameProvider = Provider<String>((ref) {
  return ref.watch(authProvider).whenOrNull(data: (u) => u?.name) ?? '';
});

/// Notifier daftar tiket pengguna
class PenggunaTicketNotifier
    extends StateNotifier<AsyncValue<List<TicketModel>>> {
  final TicketRepository _repository;
  final String _userId;

  PenggunaTicketNotifier(
      this._repository,
      this._userId,
      ) : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getTicketsByCreator(_userId);
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadTickets();
  }

  Future<void> createTicket({
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      await _repository.createTicket(
        title: title,
        description: description,
        category: category,
        createdBy: _userId,
      );
      await loadTickets();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> closeTicket(String ticketId) async {
    await _repository.closeTicket(ticketId, _userId);
    await loadTickets();
  }
}

final penggunaTicketProvider = StateNotifierProvider.autoDispose<
    PenggunaTicketNotifier,
    AsyncValue<List<TicketModel>>>((ref) {
  final repository = ref.watch(penggunaTicketRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? '';

  return PenggunaTicketNotifier(repository, userId);
});

/// Statistik tiket pengguna.
/// PENTING: key & pengecekan status pakai 'close' (TANPA huruf "d"),
/// konsisten dengan TicketRepository.closeTicket() dan TicketModel.statusLabel.
final penggunaStatsProvider =
FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final repo = ref.watch(penggunaTicketRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? '';

  final tickets = await repo.getTicketsByCreator(userId);

  return {
    'total': tickets.length,
    'pending': tickets.where((t) => t.status == 'pending').length,
    'in_progress': tickets
        .where(
          (t) =>
      t.status == 'assigned' ||
          t.status == 'in_progress' ||
          t.status == 'forwarded',
    )
        .length,
    'resolved': tickets.where((t) => t.status == 'resolved').length,
    'close': tickets.where((t) => t.status == 'close').length,
  };
});

final penggunaNavIndexProvider = StateProvider<int>((ref) => 0);