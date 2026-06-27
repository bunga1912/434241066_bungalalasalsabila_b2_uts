class CommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      ticketId: map['ticket_id'],
      userId: map['user_id'],
      userName: map['user_name'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}