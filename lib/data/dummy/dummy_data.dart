import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

final List<UserModel> dummyUsers = [
  UserModel(id: 'u1', name: 'Anggarani Setia Putri', email: 'angga@mail.com', role: 'user'),
  UserModel(id: 'u2', name: 'Siti Jaenab', email: 'siti@mail.com', role: 'helpdesk'),
  UserModel(id: 'u3', name: 'Admin Sistem', email: 'admin@mail.com', role: 'admin'),
  UserModel(id: 'u4', name: 'Budi Santoso', email: 'budi@mail.com', role: 'user'),
];

List<TicketModel> dummyTickets = [
  TicketModel(
    id: 't1',
    title: 'Komputer tidak bisa menyala',
    description: 'Komputer di ruang lab A tidak bisa dinyalakan sejak pagi. Sudah dicoba cabut colok tapi tetap tidak menyala.',
    status: 'open',
    category: 'Hardware',
    createdBy: 'u1',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    history: [
      TicketHistory(
        status: 'open',
        description: 'Tiket dibuat',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        actor: 'Anggarani Setia Putri',
      ),
    ],
  ),
  TicketModel(
    id: 't2',
    title: 'Koneksi WiFi sangat lambat',
    description: 'WiFi di lantai 2 sangat lambat, tidak bisa digunakan untuk akses sistem akademik.',
    status: 'in_progress',
    category: 'Jaringan',
    createdBy: 'u1',
    assignedTo: 'u2',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    history: [
      TicketHistory(
        status: 'open',
        description: 'Tiket dibuat',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actor: 'Anggarani Setia Putri',
      ),
      TicketHistory(
        status: 'in_progress',
        description: 'Tiket diassign ke helpdesk dan sedang ditangani',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        actor: 'Admin Sistem',
      ),
    ],
  ),
  TicketModel(
    id: 't3',
    title: 'Printer error saat mencetak',
    description: 'Printer di ruang TU mengeluarkan pesan error "Paper Jam" saat mencetak, padahal tidak ada kertas yang tersangkut.',
    status: 'resolved',
    category: 'Hardware',
    createdBy: 'u1',
    assignedTo: 'u2',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    history: [
      TicketHistory(
        status: 'open',
        description: 'Tiket dibuat',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        actor: 'Anggarani Setia Putri',
      ),
      TicketHistory(
        status: 'in_progress',
        description: 'Helpdesk mulai menangani tiket',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
        actor: 'Admin Sistem',
      ),
      TicketHistory(
        status: 'resolved',
        description: 'Masalah berhasil diselesaikan — sensor kertas dibersihkan',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        actor: 'Siti Jaenab',
      ),
    ],
  ),
  TicketModel(
    id: 't4',
    title: 'Akun SIAKAD tidak bisa login',
    description: 'Tidak bisa masuk ke SIAKAD sejak kemarin, password sudah benar tapi tetap error.',
    status: 'closed',
    category: 'Akun & Akses',
    createdBy: 'u1',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    history: [
      TicketHistory(
        status: 'open',
        description: 'Tiket dibuat',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        actor: 'Anggarani Setia Putri',
      ),
      TicketHistory(
        status: 'in_progress',
        description: 'Tim IT sedang menyelidiki masalah akun',
        timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 12)),
        actor: 'Admin Sistem',
      ),
      TicketHistory(
        status: 'resolved',
        description: 'Akun berhasil direset dan dapat diakses kembali',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        actor: 'Siti Jaenab',
      ),
      TicketHistory(
        status: 'closed',
        description: 'Tiket ditutup — masalah selesai dikonfirmasi user',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        actor: 'Anggarani Setia Putri',
      ),
    ],
  ),
];

List<CommentModel> dummyComments = [
  CommentModel(
    id: 'c1',
    ticketId: 't2',
    userId: 'u2',
    userName: 'Siti Jaenab',
    message: 'Sudah dicek, router lantai 2 mengalami overload. Sedang dalam proses penggantian unit.',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  CommentModel(
    id: 'c2',
    ticketId: 't2',
    userId: 'u1',
    userName: 'Anggarani Setia Putri',
    message: 'Baik, ditunggu ya kak. Terima kasih 🙏',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  CommentModel(
    id: 'c3',
    ticketId: 't3',
    userId: 'u2',
    userName: 'Siti Jaenab',
    message: 'Sensor kertas sudah dibersihkan dan printer berjalan normal kembali.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

UserModel currentUser = dummyUsers[0];