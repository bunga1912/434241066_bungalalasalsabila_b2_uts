class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'open' | 'in_progress' | 'resolved' | 'closed'
  final String category;
  final String createdBy;
  String? assignedTo;
  final DateTime createdAt;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
  });
}