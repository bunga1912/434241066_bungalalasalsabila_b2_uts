import 'ticket_history_model.dart';

class TicketModel {
  final String id;

  /// Nomor urut tiket yang human-friendly, misal 1, 2, 3...
  /// Ditampilkan di UI sebagai "TKT-0001", bukan UUID mentah.
  final int ticketNumber;

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
    required this.ticketNumber,
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

  /// Nomor tiket yang sudah diformat untuk ditampilkan, misal "TKT-0001"
  String get displayNumber => 'TKT-${ticketNumber.toString().padLeft(4, '0')}';

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    final rawHistory = map['ticket_history'] as List?;

    return TicketModel(
      id: map['id'],
      ticketNumber: map['ticket_number'] ?? 0,
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
    int? ticketNumber,
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
      ticketNumber: ticketNumber ?? this.ticketNumber,
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

  /// PENTING: status penutupan tiket memakai kata 'close' (TANPA huruf "d"),
  /// konsisten dengan yang disimpan TicketRepository.closeTicket().
  /// Jangan tulis 'closed' di mana pun, supaya tidak mismatch lagi.
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
      case 'resolved':
        return 'Selesai';
      case 'close':
        return 'Ditutup';
      default:
        return status;
    }
  }
}