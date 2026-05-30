class TicketModel {
  final String id;
  final String title;
  final String description;
  String status; // 'open' | 'in_progress' | 'resolved' | 'closed'
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