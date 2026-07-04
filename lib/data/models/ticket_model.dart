import 'ticket_history_model.dart';

class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String category;

  /// UUID user pembuat tiket
  final String createdBy;

  /// UUID helpdesk/TS yang ditugaskan
  final String? assignedTo;

  final DateTime createdAt;

  /// Hasil join ke tabel users (opsional)
  final String? createdByName;
  final String? assignedToName;

  /// Cache history lokal — diisi manual jika perlu,
  /// atau biarkan kosong dan gunakan ticketHistoryProvider(id)
  final List<TicketHistoryModel> history;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    this.createdByName,
    this.assignedToName,
    this.history = const [],
  });

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    // Jika response sudah include ticket_history (lewat join), parse sekalian
    final rawHistory = map['ticket_history'] as List?;

    return TicketModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      category: map['category'],
      createdBy: map['created_by'],
      assignedTo: map['assigned_to'],
      createdAt: DateTime.parse(map['created_at']),
      createdByName: map['created_by_user']?['name'],
      assignedToName: map['assigned_to_user']?['name'],
      history: rawHistory
          ?.map((h) => TicketHistoryModel.fromMap(h))
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'category': category,
      'created_by': createdBy,
      'assigned_to': assignedTo,
    };
  }

  /// Salin model dengan field yang diubah
  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? category,
    String? createdBy,
    String? assignedTo,
    DateTime? createdAt,
    String? createdByName,
    String? assignedToName,
    List<TicketHistoryModel>? history,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      createdByName: createdByName ?? this.createdByName,
      assignedToName: assignedToName ?? this.assignedToName,
      history: history ?? this.history,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'open':
        return 'Open';
      case 'assigned':
        return 'Ditugaskan';
      case 'in_progress':
        return 'Sedang_Dikerjakan';
      case 'forwarded':
        return 'Diteruskan ke TS';
      case 'closed':
        return 'Ditutup';
      default:
        return status;
    }
  }
}