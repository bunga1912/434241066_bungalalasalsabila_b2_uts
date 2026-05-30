class AppConstants {
  static const String appName = 'HelpDesk UNAIR';

  static const List<String> ticketCategories = [
    'Hardware',
    'Software',
    'Jaringan',
    'Akun & Akses',
    'Lainnya',
  ];

  static const List<String> ticketStatuses = [
    'open',
    'in_progress',
    'resolved',
    'closed',
  ];

  // Tracking steps per status
  static const Map<String, int> statusStep = {
    'open': 0,
    'in_progress': 1,
    'resolved': 2,
    'closed': 3,
  };
}