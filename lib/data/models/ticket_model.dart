class TicketModel {
  final String id;
  final String title;
  final String description;
  String status; // 'pending' | 'assigned' | 'in_progress' | 'forwarded' | 'resolved' | 'closed'
  final String category;
  final String createdBy;
  String? assignedTo;
  final DateTime createdAt;
  final List<TicketHistory> history;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    List<TicketHistory>? history,
  }) : history = history ?? [];

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Diproses';
      case 'forwarded':
        return 'Diteruskan ke TS';
      case 'resolved':
        return 'Selesai';
      case 'closed':
        return 'Ditutup';
      default:
        return status;
    }
  }
}

class TicketHistory {
  final String status;
  final String description;
  final DateTime timestamp;
  final String actor;

  TicketHistory({
    required this.status,
    required this.description,
    required this.timestamp,
    required this.actor,
  });
}