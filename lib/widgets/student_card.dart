// lib/widgets/student_card.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../theme.dart';
import '../services/local_storage_service.dart';

class StudentCard extends StatefulWidget {
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
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  Uint8List? _imageBytes;
  String? _imagePath;

  bool _isSaving = false;
  bool _isLoadingFromStorage = true;

  @override
  void initState() {
    super.initState();
    _loadStudentImage();
  }

  // 📂 Load image (with loader)
  Future<void> _loadStudentImage() async {
    setState(() => _isLoadingFromStorage = true);

    final paths =
        await LocalStorageService.getStudentImages(widget.student.id);

    if (paths.isNotEmpty) {
      final file = File(paths.last);
      final bytes = await file.readAsBytes();

      setState(() {
        _imageBytes = bytes;
        _imagePath = paths.last;
      });
    }

    setState(() => _isLoadingFromStorage = false);
  }

  // 📸 Capture
  Future<void> _captureImage() async {
    final image = await LocalStorageService.captureImage();

    if (image != null) {
      final bytes = await image.readAsBytes();

      setState(() {
        _imageBytes = bytes; // ⚡ instant preview
        _isSaving = true;
      });

      LocalStorageService.saveStudentImage(
        widget.student.id,
        image,
      ).then((_) {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      });
    }
  }

  // 🔍 Full screen
  void _openFullScreen() {
    if (_imageBytes == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(
            child: InteractiveViewer(
              child: Image.memory(_imageBytes!),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final fmt = DateFormat('MMM d, yyyy • h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // STATUS
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: student.claimed ? AppColors.greenBg : AppColors.blueBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                student.claimed
                    ? Icons.check_circle
                    : Icons.pending_actions,
                color:
                    student.claimed ? AppColors.green : AppColors.blue,
              ),
              const SizedBox(width: 10),
              Text(
                student.claimed
                    ? 'Swag Already Distributed'
                    : 'Eligible for Swag',
                style: TextStyle(
                  color:
                      student.claimed ? AppColors.green : AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // INFO CARD
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.blueBg,
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0]
                            : '?',
                        style: const TextStyle(
                          color: AppColors.blue,
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
                          Text(student.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(student.email,
                              style: const TextStyle(
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),

                _detail(Icons.school, "Department",
                    student.department),
                _detail(Icons.calendar_today, "Year",
                    student.year),
                _detail(Icons.shopping_bag, "T-Shirt",
                    student.tshirtSize),
                _detail(Icons.badge, "ID", student.id),

                if (student.claimedAt != null)
                  _detail(Icons.verified, "Claimed",
                      fmt.format(student.claimedAt!)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // IMAGE SECTION
        if (_isLoadingFromStorage)
          const Center(child: CircularProgressIndicator()),

        if (!_isLoadingFromStorage && _imageBytes != null) ...[
          Stack(
            children: [
              GestureDetector(
                onTap: _openFullScreen,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: MemoryImage(_imageBytes!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              if (_isSaving)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // BUTTONS
        if (!student.claimed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  widget.isProcessing ? null : widget.onClaim,
              icon: const Icon(Icons.redeem),
              label: const Text("Distribute Swag ✓"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: Text(_imageBytes == null
                  ? "Capture Student Image"
                  : "Retake Image"),
            ),
          ),
        ],

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onScanNext,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Scan Next Student"),
          ),
        ),
      ],
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text("$label: "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}