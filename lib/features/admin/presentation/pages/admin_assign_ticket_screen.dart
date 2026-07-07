import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/ticket_model.dart';
import '../providers/admin_provider.dart';

class AdminAssignTicketScreen extends ConsumerStatefulWidget {
  final TicketModel ticket;

  const AdminAssignTicketScreen({super.key, required this.ticket});

  @override
  ConsumerState<AdminAssignTicketScreen> createState() =>
      _AdminAssignTicketScreenState();
}

class _AdminAssignTicketScreenState
    extends ConsumerState<AdminAssignTicketScreen> {
  static const Color primaryNavy = Color(0xFF042C53);
  static const Color primaryBlue = Color(0xFF185FA5);
  static const Color accentGold = Color(0xFFFAC775);

  String? _selectedHelpdeskId;
  String? _selectedHelpdeskName;
  bool _isLoading = false;

  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ticket.status;
  }

  void _handleAssign() async {
    if (_selectedHelpdeskId == null) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(adminTicketListProvider.notifier)
          .assignToHelpdesk(widget.ticket.id, _selectedHelpdeskId!);

      // FIX: assignToHelpdesk() sebelumnya cuma me-refresh adminTicketListProvider
      // (dipakai di halaman daftar tiket), sehingga Dashboard (stats, kategori,
      // tiket terbaru, helpdesk aktif) masih menampilkan data lama sampai
      // provider-nya di-invalidate manual seperti ini.
      ref.invalidate(adminStatsProvider);
      ref.invalidate(adminCategoryStatsProvider);
      ref.invalidate(adminRecentTicketsProvider);
      ref.invalidate(adminHelpdeskActiveProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: primaryNavy,
            content: Text(
              // FIX: pakai displayNumber ("TKT-0001"), bukan UUID mentah
              'Tiket ${widget.ticket.displayNumber} berhasil di-assign ke $_selectedHelpdeskName',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pop(context, {
          'success': true,
          'status': _currentStatus,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Gagal: $e'),
          ),
        );
      }
    }
  }

  ({String label, Color color}) _statusMeta(String status) {
    switch (status) {
      case 'open':
        return (label: 'Open', color: primaryBlue);
      case 'in_progress':
        return (label: 'In Progress', color: accentGold);
      case 'close':
        return (label: 'Close', color: Colors.green);
      default:
        return (label: status, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final helpdeskListAsync = ref.watch(helpdeskListProvider);
    final statusMeta = _statusMeta(_currentStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFF1EFE8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Assign Tiket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pilih anggota Helpdesk untuk tiket ini',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ticket info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryNavy.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FIX: badge ID pakai displayNumber ("TKT-0001").
                          // Dibungkus Wrap (bukan Row) supaya kalau 3 badge
                          // tidak muat dalam satu baris, otomatis lanjut ke
                          // baris berikutnya alih-alih overflow ke kanan.
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _badge(widget.ticket.displayNumber, primaryBlue),
                              _badge(widget.ticket.category, accentGold,
                                  textColor: primaryNavy),
                              _badge(statusMeta.label, statusMeta.color),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.ticket.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.ticket.description,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 14, color: Colors.grey[400]),
                              const SizedBox(width: 4),
                              // FIX: pakai createdByName (hasil join),
                              // dengan fallback ke UUID kalau nama tidak
                              // tersedia. Dibungkus Expanded + ellipsis
                              // supaya tidak overflow.
                              Expanded(
                                child: Text(
                                  'Dilaporkan oleh ${widget.ticket.createdByName ?? widget.ticket.createdBy}',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Pilih Petugas Helpdesk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 12),

                    helpdeskListAsync.when(
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                      data: (helpdeskList) => Column(
                        children: helpdeskList.map((helpdesk) {
                          final isSelected =
                              _selectedHelpdeskId == helpdesk.id;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedHelpdeskId = helpdesk.id;
                              _selectedHelpdeskName = helpdesk.name;
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryBlue
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    primaryNavy.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                    primaryBlue.withOpacity(0.15),
                                    child: Text(
                                      helpdesk.initials,
                                      style: const TextStyle(
                                        color: primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          helpdesk.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: primaryNavy,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          helpdesk.email,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: isSelected
                                        ? primaryBlue
                                        : Colors.grey[300],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFE8),
                boxShadow: [
                  BoxShadow(
                    color: primaryNavy.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  (_selectedHelpdeskId == null || _isLoading)
                      ? null
                      : _handleAssign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Assign Tiket',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bgColor, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor ?? bgColor,
        ),
      ),
    );
  }
}