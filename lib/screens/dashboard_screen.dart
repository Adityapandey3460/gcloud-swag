// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/student.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Dashboard'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.blueBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Live',
                  style: TextStyle(color: AppColors.blue, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseService.signOut();
              // if (context.mounted) {
              //   Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              // }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Student>>(
        stream: FirebaseService.getStudentsStream(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.blue));
          }

          final students = snap.data ?? [];
          final total = students.length;
          final claimed = students.where((s) => s.claimed).length;
          final pending = total - claimed;
          final pct = total > 0 ? (claimed / total * 100).round() : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Admin info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.blueBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: AppColors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FirebaseService.currentUser?.email ?? 'Admin',
                              style: const TextStyle(
                                  color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const Text('Google Cloud Event Admin',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Active',
                            style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text('Overview',
                    style: TextStyle(
                        color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // Stats grid
                Row(
                  children: [
                    Expanded(child: _StatCard(
                        label: 'Total', value: '$total',
                        color: AppColors.blue, icon: Icons.people_outline)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                        label: 'Claimed', value: '$claimed',
                        color: AppColors.green, icon: Icons.redeem_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                        label: 'Pending', value: '$pending',
                        color: const Color(0xFFFBBC04),
                        icon: Icons.pending_outlined)),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Distribution Progress',
                              style: TextStyle(
                                  color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('$pct%',
                              style: const TextStyle(
                                  color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: total > 0 ? claimed / total : 0,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(AppColors.green),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$claimed of $total swags distributed',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text('$pending remaining',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent activity
                const Text('Recent Claims',
                    style: TextStyle(
                        color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                ...(() {
                  final recent = students
                      .where((s) => s.claimed && s.claimedAt != null)
                      .toList();
                  recent.sort((a, b) => (b.claimedAt ?? DateTime(0))
                      .compareTo(a.claimedAt ?? DateTime(0)));
                  return recent.take(10).map((s) => _RecentRow(student: s)).toList();
                })(),

                if (students.where((s) => s.claimed).isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 36),
                        SizedBox(height: 8),
                        Text('No swags claimed yet',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final Student student;

  const _RecentRow({required this.student});

  @override
  Widget build(BuildContext context) {
     final fmt = DateFormat('MMM d, yyyy • h:mm a');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.check, color: AppColors.green, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(student.department,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            student.claimedAt != null ? fmt.format(student.claimedAt!) : '',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


