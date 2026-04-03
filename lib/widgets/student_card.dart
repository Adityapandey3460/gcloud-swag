// lib/widgets/student_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../theme.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback? onClaim;
  final VoidCallback? onScanNext;
  final bool isProcessing;

  const StudentCard({
    super.key,
    required this.student,
    this.onClaim,
    this.onScanNext,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy • h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: student.claimed ? AppColors.greenBg : AppColors.blueBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: student.claimed
                  ? AppColors.green.withOpacity(0.3)
                  : AppColors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                student.claimed ? Icons.check_circle_outline : Icons.pending_outlined,
                color: student.claimed ? AppColors.green : AppColors.blue,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                student.claimed ? 'Swag Already Claimed' : 'Eligible for Swag',
                style: TextStyle(
                  color: student.claimed ? AppColors.green : AppColors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Main info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.blueBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          student.name.isNotEmpty
                              ? student.name.split(' ').map((w) => w[0]).take(2).join()
                              : '??',
                          style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
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
                                  color: AppColors.text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(student.email,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 16),

                // Details grid
                ...[
                  _DetailRow(
                      icon: Icons.school_outlined,
                      label: 'department',
                      value: student.department),
                    _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'year',
                        value: student.year),
                  _DetailRow(
                        icon: Icons.checkroom, // Built-in shirt icon
                        label: 'T-shirt Size',
                        value: student.tshirtSize),
                  _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Student ID',
                      value: student.id,
                      mono: true),
                  if (student.claimedAt != null)
                    _DetailRow(
                        icon: Icons.verified_outlined,
                        label: 'Claimed At',
                        value: fmt.format(student.claimedAt!),
                        valueColor: AppColors.green),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons
        if (student.claimed) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle, color: AppColors.green, size: 36),
                SizedBox(height: 8),
                Text('Swag Already Distributed',
                    style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                SizedBox(height: 4),
                Text('This student has already received their swag.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: isProcessing
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.redeem_outlined, size: 22),
              label: Text(
                isProcessing ? 'Processing...' : 'Distribute Swag ✓',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Scan next
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onScanNext, // handled by parent
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textMuted,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.qr_code_scanner, size: 18),
            label: const Text('Scan Next Student'),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
