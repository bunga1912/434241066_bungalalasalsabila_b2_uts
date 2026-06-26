import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/models/comment_model.dart';
import '../../../../data/repositories/ticket_repository.dart';

final sharedTicketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

/// Provider untuk detail tiket berdasarkan id
final ticketDetailProvider =
FutureProvider.autoDispose.family<TicketModel?, String>((ref, ticketId) async {
  final repo = ref.watch(sharedTicketRepositoryProvider);
  return repo.getTicketById(ticketId);
});

/// Provider untuk komentar tiket
class CommentNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final TicketRepository _repository;
  final String _ticketId;

  CommentNotifier(this._repository, this._ticketId)
      : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getCommentsByTicketId(_ticketId);
      state = AsyncValue.data(data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addComment({
    required String userId,
    required String userName,
    required String message,
  }) async {
    try {
      await _repository.addComment(
        ticketId: _ticketId,
        userId: userId,
        userName: userName,
        message: message,
      );
      await loadComments();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final commentProvider = StateNotifierProvider.autoDispose
    .family<CommentNotifier, AsyncValue<List<CommentModel>>, String>(
      (ref, ticketId) {
    final repository = ref.watch(sharedTicketRepositoryProvider);
    return CommentNotifier(repository, ticketId);
  },
);