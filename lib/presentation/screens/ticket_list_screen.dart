import 'package:flutter/material.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/ticket_model.dart';
import '../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  final VoidCallback? onRefresh;
  const TicketListScreen({super.key, this.onRefresh});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TicketModel> get _baseTickets {
    return currentUser.role == 'user'
        ? dummyTickets.where((t) => t.createdBy == currentUser.id).toList()
        : dummyTickets;
  }

  List<TicketModel> _filtered(String? status) {
    var list = _baseTickets;
    if (status != null) list = list.where((t) => t.status == status).toList();
    if (_search.isNotEmpty) {
      list = list.where((t) =>
      t.title.toLowerCase().contains(_search.toLowerCase()) ||
          t.category.toLowerCase().contains(_search.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Text('Tiket',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_baseTickets.length} total',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Cari tiket...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter tabs
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: const Color(0xFF4F46E5),
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: const Color(0xFF4F46E5),
            unselectedLabelColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: [
              _buildTab('Semua', _filtered(null).length),
              _buildTab('Baru', _filtered('open').length, color: const Color(0xFFF59E0B)),
              _buildTab('Diproses', _filtered('in_progress').length, color: const Color(0xFF4F46E5)),
              _buildTab('Selesai', _filtered('resolved').length, color: const Color(0xFF10B981)),
              _buildTab('Ditutup', _filtered('closed').length, color: const Color(0xFF64748B)),
            ],
          ),
          const Divider(height: 0, thickness: 0.5),

          // Ticket lists
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _TicketList(tickets: _filtered(null), onRefresh: _refresh),
                _TicketList(tickets: _filtered('open'), onRefresh: _refresh),
                _TicketList(tickets: _filtered('in_progress'), onRefresh: _refresh),
                _TicketList(tickets: _filtered('resolved'), onRefresh: _refresh),
                _TicketList(tickets: _filtered('closed'), onRefresh: _refresh),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _refresh() {
    setState(() {});
    widget.onRefresh?.call();
  }

  Tab _buildTab(String label, int count, {Color? color}) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: (color ?? const Color(0xFF4F46E5)).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color ?? const Color(0xFF4F46E5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  final List tickets;
  final VoidCallback onRefresh;

  const _TicketList({required this.tickets, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('Tidak ada tiket', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: const Color(0xFF4F46E5),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: tickets.length,
        itemBuilder: (context, index) => TicketCard(
          ticket: tickets[index],
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(
                builder: (_) => TicketDetailScreen(ticket: tickets[index])));
            onRefresh();
          },
        ),
      ),
    );
  }
}