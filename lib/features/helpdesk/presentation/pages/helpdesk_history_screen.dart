import 'package:flutter/material.dart';

class HelpdeskHistoryScreen extends StatefulWidget {
  const HelpdeskHistoryScreen({super.key});

  @override
  State<HelpdeskHistoryScreen> createState() => _HelpdeskHistoryScreenState();
}

class _HelpdeskHistoryScreenState extends State<HelpdeskHistoryScreen> {
  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  final List<Map<String, dynamic>> _history = [
    {
      'ticketId': 'TKT-006',
      'title': 'Reset password email kampus',
      'action': 'Diselesaikan',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF4CAF50),
    },
    {
      'ticketId': 'TKT-009',
      'title': 'Aplikasi presensi tidak bisa absen',
      'action': 'Diteruskan ke TS - Fajar',
      'time': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'icon': Icons.forward_rounded,
      'color': Color(0xFF9575CD),
    },
    {
      'ticketId': 'TKT-010',
      'title': 'Akun mahasiswa tidak terdaftar di SIAKAD',
      'action': 'Diselesaikan',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF4CAF50),
    },
    {
      'ticketId': 'TKT-011',
      'title': 'Komputer lab rusak total',
      'action': 'Diteruskan ke TS - Dimas',
      'time': DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      'icon': Icons.forward_rounded,
      'color': Color(0xFF9575CD),
    },
    {
      'ticketId': 'TKT-012',
      'title': 'Lupa password portal jurnal',
      'action': 'Diselesaikan',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF4CAF50),
    },
    {
      'ticketId': 'TKT-013',
      'title': 'Sinkronisasi data dosen error',
      'action': 'Diselesaikan',
      'time': DateTime.now().subtract(const Duration(days: 4)),
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF4CAF50),
    },
  ];

  String _formatDate(DateTime time) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${time.day} ${months[time.month - 1]} ${time.year}';
  }

  Map<String, List<Map<String, dynamic>>> get _groupedHistory {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _history) {
      final dateKey = _formatDate(item['time'] as DateTime);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedHistory;
    final resolvedCount =
        _history.where((h) => h['action'] == 'Diselesaikan').length;
    final forwardedCount = _history.length - resolvedCount;

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
                        'Riwayat Tugas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Histori tiket yang sudah ditangani',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _miniStat(
                              icon: Icons.check_circle_rounded,
                              label: 'Diselesaikan',
                              value: '$resolvedCount',
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _miniStat(
                              icon: Icons.forward_rounded,
                              label: 'Diteruskan',
                              value: '$forwardedCount',
                              color: const Color(0xFF9575CD),
                            ),
                          ),
                        ],
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
                      ...entry.value.map((item) => _historyItem(item)),
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

  Widget _miniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyItem(Map<String, dynamic> item) {
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
              color: (item['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['ticketId'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item['action'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: (item['color'] as Color),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}