import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

// Dummy users
final List<UserModel> dummyUsers = [
  UserModel(id: 'u1', name: 'Anggarani Setia Putri', email: 'ranoy@mail.com', role: 'user'),
  UserModel(id: 'u2', name: 'Siti Jaenab Helpdesk', email: 'jae@mail.com', role: 'helpdesk'),
  UserModel(id: 'u3', name: 'Admin Sistem', email: 'admin@mail.com', role: 'admin'),
];

// Dummy tickets
List<TicketModel> dummyTickets = [
  TicketModel(
    id: 't1',
    title: 'Komputer tidak bisa menyala',
    description: 'Komputer di ruang lab A tidak bisa dinyalakan sejak pagi.',
    status: 'open',
    category: 'Hardware',
    createdBy: 'u1',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  TicketModel(
    id: 't2',
    title: 'Koneksi WiFi lambat',
    description: 'WiFi di lantai 2 sangat lambat, tidak bisa digunakan untuk akses sistem.',
    status: 'in_progress',
    category: 'Jaringan',
    createdBy: 'u1',
    assignedTo: 'u2',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TicketModel(
    id: 't3',
    title: 'Printer error',
    description: 'Printer di ruang TU mengeluarkan pesan error saat mencetak.',
    status: 'resolved',
    category: 'Hardware',
    createdBy: 'u1',
    assignedTo: 'u2',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  TicketModel(
    id: 't4',
    title: 'Akun SIAKAD tidak bisa login',
    description: 'Tidak bisa masuk ke SIAKAD sejak kemarin, password sudah benar.',
    status: 'closed',
    category: 'Software',
    createdBy: 'u1',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

// Dummy comments
List<CommentModel> dummyComments = [
  CommentModel(
    id: 'c1',
    ticketId: 't2',
    userId: 'u2',
    userName: 'Siti Helpdesk',
    message: 'Sudah dicek, sedang dalam proses perbaikan router.',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  CommentModel(
    id: 'c2',
    ticketId: 't2',
    userId: 'u1',
    userName: 'Anggarani Setia Putri',
    message: 'Baik, ditunggu ya. Terima kasih.',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
];

// Dummy logged in user (simulasi login)
UserModel currentUser = dummyUsers[0]; // default login sebagai 'user'