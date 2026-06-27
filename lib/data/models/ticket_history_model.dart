class TicketHistoryModel {
  final String id;
  final String ticketId;
  final String status;
  final String description;
  final String actor;
  final DateTime timestamp;

  const TicketHistoryModel({
    required this.id,
    required this.ticketId,
    required this.status,
    required this.description,
    required this.actor,
    required this.timestamp,
  });

  factory TicketHistoryModel.fromMap(Map<String, dynamic> map) {
    return TicketHistoryModel(
      id: map['id'],
      ticketId: map['ticket_id'],
      status: map['status'],
      description: map['description'],
      actor: map['actor'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_id': ticketId,
      'status': status,
      'description': description,
      'actor': actor,
    };
  }
}