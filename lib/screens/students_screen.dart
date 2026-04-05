// lib/screens/students_screen.dart

import 'package:flutter/material.dart';
import 'package:swag_admin_app/services/local_storage_service.dart';
import '../services/firebase_service.dart';
import '../models/student.dart';
import '../theme.dart';
import '../widgets/student_card.dart';

class StudentsScreen extends StatefulWidget {
  final VoidCallback onRedirectToScanner;
  const StudentsScreen({super.key, required this.onRedirectToScanner});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _search = '';
  String _filter = 'all'; // all | claimed | pending
  Student? _selectedStudent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            color: AppColors.card,
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              _filterItem('all', 'All Students', _filter),
              _filterItem('pending', 'Pending Only', _filter),
              _filterItem('claimed', 'Claimed Only', _filter),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                hintText: 'Search name, email, department...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // Filter badge
          if (_filter != 'all')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                      _filter == 'claimed' ? 'Showing: Claimed' : 'Showing: Pending'),
                  backgroundColor: AppColors.blueBg,
                  labelStyle: const TextStyle(color: AppColors.blue, fontSize: 12),
                  deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.blue),
                  onDeleted: () => setState(() => _filter = 'all'),
                ),
              ),
            ),

          // List of students
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: FirebaseService.getStudentsStream(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.blue));
                }
                if (snap.hasError) {
                  return Center(
                    child: Text('Error: ${snap.error}',
                        style: const TextStyle(color: AppColors.red)),
                  );
                }

                final all = snap.data ?? [];
                final filtered = all.where((s) {
                  final matchSearch = _search.isEmpty ||
                      s.name.toLowerCase().contains(_search.toLowerCase()) ||
                      s.email.toLowerCase().contains(_search.toLowerCase()) ||
                      s.department.toLowerCase().contains(_search.toLowerCase());
                  final matchFilter = _filter == 'all' ||
                      (_filter == 'claimed' && s.claimed) ||
                      (_filter == 'pending' && !s.claimed);
                  return matchSearch && matchFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, color: AppColors.textMuted, size: 48),
                        SizedBox(height: 12),
                        Text('No students found',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    return _StudentRow(
                      student: s,
                      onTap: () => _showDetail(s),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(Student student) {
    Student currentStudent = student;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // StudentCard now internally handles camera
                  StudentCard(
                    student: currentStudent,
                    onClaim: () async {
                      await FirebaseService.markClaimed(student.id);

                      setModalState(() {
                        currentStudent = Student(
                          id: student.id,
                          name: student.name,
                          email: student.email,
                          department: student.department,
                          year: student.year,
                          claimed: true,
                          tshirtSize: student.tshirtSize,
                          claimedAt: DateTime.now(),
                        );
                      });
                    },
                    onScanNext: () {
                      Navigator.pop(context);
                      widget.onRedirectToScanner();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> _filterItem(String value, String label, String current) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            current == value ? Icons.radio_button_checked : Icons.radio_button_off,
            color: current == value ? AppColors.blue : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.text)),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const _StudentRow({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blueBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  student.name.isNotEmpty
                      ? student.name.split(' ').map((w) => w[0]).take(2).join()
                      : '??',
                  style: const TextStyle(
                      color: AppColors.blue, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: const TextStyle(
                          color: AppColors.text, fontWeight: FontWeight.w500, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(student.department,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: student.claimed ? AppColors.greenBg : AppColors.blueBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student.claimed ? '✓ Claimed' : 'Pending',
                style: TextStyle(
                  color: student.claimed ? AppColors.green : AppColors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}