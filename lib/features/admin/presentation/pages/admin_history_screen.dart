import 'package:flutter/material.dart';

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  final List<Map<String, dynamic>> _logs = [
    {
      'title': 'Tiket TKT-001 di-assign ke Helpdesk - Rina',
      'actor': 'Admin Sistem',
      'time': DateTime.now().subtract(const Duration(minutes: 10)),
      'icon': Icons.assignment_turned_in_rounded,
      'color': primaryBlue,
    },
    {
      'title': 'Tiket TKT-004 diteruskan ke TS - Fajar',
      'actor': 'Helpdesk - Rina',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'icon': Icons.forward_rounded,
      'color': accentGold,
    },
    {
      'title': 'Tiket TKT-006 ditandai selesai',
      'actor': 'Helpdesk - Rina',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Tiket TKT-007 ditutup oleh pengguna',
      'actor': 'Rio Pratama',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.lock_rounded,
      'color': Colors.grey,
    },
    {
      'title': 'User baru terdaftar: Maya Putri',
      'actor': 'Sistem',
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      'icon': Icons.person_add_rounded,
      'color': const Color(0xFF9575CD),
    },
    {
      'title': 'Tiket TKT-005 diteruskan ke TS - Fajar',
      'actor': 'Helpdesk - Joko',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.forward_rounded,
      'color': accentGold,
    },
    {
      'title': 'Akun Helpdesk baru ditambahkan: Dimas Pratama',
      'actor': 'Admin Sistem',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'icon': Icons.person_add_rounded,
      'color': primaryNavy,
    },
  ];

  String _formatDate(DateTime time) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${time.day} ${months[time.month - 1]} ${time.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Map<String, List<Map<String, dynamic>>> get _groupedLogs {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var log in _logs) {
      final dateKey = _formatDate(log['time'] as DateTime);
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedLogs;

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryNavy, primaryBlue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -10,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentGold.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Aktivitas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Log seluruh aktivitas sistem',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          bottom: 10,
                          top: 8,
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...entry.value.map((log) => _logItem(log)),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logItem(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (log['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              log['icon'] as IconData,
              color: log['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['title'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'oleh ${log['actor']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(log['time'] as DateTime),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}