import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/ticket_model.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = AppConstants.ticketCategories.first;
  bool _isLoading = false;

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Hardware': return const Color(0xFFEF4444);
      case 'Software': return const Color(0xFF8B5CF6);
      case 'Jaringan': return const Color(0xFF06B6D4);
      case 'Akun & Akses': return const Color(0xFFF59E0B);
      default: return const Color(0xFF64748B);
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Hardware': return Icons.computer_rounded;
      case 'Software': return Icons.code_rounded;
      case 'Jaringan': return Icons.wifi_rounded;
      case 'Akun & Akses': return Icons.manage_accounts_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      _showSnack('Judul tiket tidak boleh kosong', const Color(0xFFEF4444));
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _showSnack('Deskripsi tidak boleh kosong', const Color(0xFFEF4444));
      return;
    }
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      dummyTickets.insert(0, TicketModel(
        id: 'T${dummyTickets.length + 1}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        status: 'open',
        category: _selectedCategory,
        createdBy: currentUser.id,
        createdAt: DateTime.now(),
        history: [
          TicketHistory(
            status: 'open',
            description: 'Tiket dibuat oleh ${currentUser.name}',
            timestamp: DateTime.now(),
            actor: currentUser.name,
          ),
        ],
      ));

      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Tiket berhasil dibuat!', const Color(0xFF10B981));
        Navigator.pop(context);
      }
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket Baru')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Category picker
          const Text('Kategori Masalah',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.8,
            children: AppConstants.ticketCategories.map((cat) {
              final isSelected = _selectedCategory == cat;
              final color = _getCategoryColor(cat);
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getCategoryIcon(cat), size: 16,
                          color: isSelected ? Colors.white : color),
                      const SizedBox(height: 4),
                      Text(cat,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : color,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Title
          const Text('Judul Tiket',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Deskripsikan masalah secara singkat',
              prefixIcon: Icon(Icons.title_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // Description
          const Text('Detail Masalah',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Jelaskan masalah Anda secara lengkap...',
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 32),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tiket akan segera ditinjau oleh tim helpdesk dan Anda dapat memantau progres melalui fitur tracking.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Kirim Tiket'),
            ),
          ),
        ],
      ),
    );
  }
}