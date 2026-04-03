// // lib/screens/scanner_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../services/firebase_service.dart';
// import '../models/student.dart';
// import '../theme.dart';
// import '../widgets/student_card.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen>
//     with SingleTickerProviderStateMixin {
//   MobileScannerController? _controller;
//   bool _scanning = true;
//   bool _processing = false;
//   Student? _foundStudent;
//   String? _errorMsg;

//   @override
//   void initState() {
//     super.initState();
//     _controller = MobileScannerController(
//       detectionSpeed: DetectionSpeed.normal,
//       facing: CameraFacing.back,
//       torchEnabled: false,
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   Future<void> _onDetect(BarcodeCapture capture) async {
//     if (_processing || !_scanning) return;

//     final barcode = capture.barcodes.firstOrNull;
//     if (barcode?.rawValue == null) return;

//     final scannedId = barcode!.rawValue!;
//     setState(() { _processing = true; _scanning = false; });

//     // Haptic feedback
//     HapticFeedback.mediumImpact();

//     // Pause scanner
//     await _controller?.stop();

//     // Fetch student from Firestore
//     final student = await FirebaseService.getStudentById(scannedId);

//     if (mounted) {
//       setState(() {
//         _processing = false;
//         if (student != null) {
//           _foundStudent = student;
//           _errorMsg = null;
//         } else {
//           _errorMsg = 'Student not found.\nThis QR code is not registered.';
//           _foundStudent = null;
//         }
//       });
//     }
//   }

//   void _resetScanner() {
//     setState(() {
//       _scanning = true;
//       _foundStudent = null;
//       _errorMsg = null;
//       _processing = false;
//     });
//     _controller?.start();
//   }

//   Future<void> _markClaimed() async {
//     if (_foundStudent == null) return;
//     setState(() => _processing = true);

//     await FirebaseService.markClaimed(_foundStudent!.id);
//     HapticFeedback.heavyImpact();

//     if (mounted) {
//       setState(() {
//         _foundStudent = Student(
//           id: _foundStudent!.id,
//           name: _foundStudent!.name,
//           email: _foundStudent!.email,
//           department: _foundStudent!.department,
//           year: _foundStudent!.year,
//           claimed: true,
//           tshirtSize: _foundStudent!.tshirtSize,
//           claimedAt: DateTime.now(),
//         );
//         _processing = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // ── CAMERA VIEW ───────────────────────────────
//           if (_scanning || _processing)
//             MobileScanner(
//               controller: _controller!,
//               onDetect: _onDetect,
//             ),

//           // ── SCANNER OVERLAY ───────────────────────────
//           if (_scanning)
//             _ScannerOverlay(
//               onTorch: () => _controller?.toggleTorch(),
//               onManual: _showManualEntry,
//             ),

//           // ── PROCESSING SPINNER ────────────────────────
//           if (_processing)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(color: AppColors.blue),
//                     SizedBox(height: 16),
//                     Text('Verifying student...',
//                         style: TextStyle(color: Colors.white, fontSize: 16)),
//                   ],
//                 ),
//               ),
//             ),

//           // ── RESULT PANEL ──────────────────────────────
//           if (_foundStudent != null || _errorMsg != null)
//             _ResultPanel(
//               student: _foundStudent,
//               errorMsg: _errorMsg,
//               onClaim: _markClaimed,
//               onReset: _resetScanner,
//               isProcessing: _processing,
//             ),
//         ],
//       ),
//     );
//   }

//   void _showManualEntry() {
//     final ctrl = TextEditingController();
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.card,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       isScrollControlled: true,
//       builder: (ctx) => Padding(
//         padding: EdgeInsets.only(
//           left: 24, right: 24, top: 24,
//           bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Manual ID Entry',
//                 style: TextStyle(
//                     color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             const Text('Enter the student\'s ID from their registration',
//                 style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
//             const SizedBox(height: 20),
//             TextField(
//               controller: ctrl,
//               autofocus: true,
//               style: const TextStyle(color: AppColors.text),
//               decoration: const InputDecoration(
//                 labelText: 'Student ID',
//                 hintText: 'e.g. abc123xyz',
//                 prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textMuted),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   final id = ctrl.text.trim();
//                   if (id.isNotEmpty) {
//                     Navigator.pop(ctx);
//                     setState(() { _scanning = false; _processing = true; });
//                     FirebaseService.getStudentById(id).then((student) {
//                       if (mounted) {
//                         setState(() {
//                           _processing = false;
//                           _foundStudent = student;
//                           _errorMsg = student == null
//                               ? 'Student not found.\nThis ID is not registered.'
//                               : null;
//                         });
//                       }
//                     });
//                   }
//                 },
//                 child: const Text('Look Up Student'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── SCANNER FRAME OVERLAY ────────────────────────────────────────────────────

// class _ScannerOverlay extends StatelessWidget {
//   final VoidCallback onTorch;
//   final VoidCallback onManual;

//   const _ScannerOverlay({required this.onTorch, required this.onManual});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Dimmed areas around the scan box
//         CustomPaint(
//           size: MediaQuery.of(context).size,
//           painter: _OverlayPainter(),
//         ),

//         // Top bar
//         SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('Scan QR Code',
//                         style: TextStyle(
//                             color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
//                     Text('Point at student\'s QR code',
//                         style: TextStyle(color: Colors.white70, fontSize: 13)),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     _IconBtn(icon: Icons.flashlight_on_outlined, onTap: onTorch),
//                     const SizedBox(width: 8),
//                     _IconBtn(icon: Icons.keyboard_outlined, onTap: onManual, label: 'Manual'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Corner brackets around scan area
//         Center(
//           child: SizedBox(
//             width: 260,
//             height: 260,
//             child: CustomPaint(painter: _CornerPainter()),
//           ),
//         ),

//         // Bottom hint
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 40),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   'Align QR code within the frame',
//                   style: TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _IconBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   final String? label;

//   const _IconBtn({required this.icon, required this.onTap, this.label});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.black45,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.white24),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 18),
//             if (label != null) ...[
//               const SizedBox(width: 6),
//               Text(label!, style: const TextStyle(color: Colors.white, fontSize: 12)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _OverlayPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = Colors.black.withOpacity(0.6);
//     const scanSize = 260.0;
//     final left = (size.width - scanSize) / 2;
//     final top = (size.height - scanSize) / 2;
//     final scanRect = Rect.fromLTWH(left, top, scanSize, scanSize);

//     final path = Path()
//       ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
//       ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)));
//     canvas.drawPath(path, paint..blendMode = BlendMode.srcOver);

//     // Draw inner border
//     canvas.drawRRect(
//       RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
//       Paint()
//         ..color = AppColors.blue.withOpacity(0.6)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.5,
//     );
//   }

//   @override
//   bool shouldRepaint(_) => false;
// }

// class _CornerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = AppColors.blue
//       ..strokeWidth = 4
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;

//     const len = 32.0;
//     const r = 16.0;

//     // Top-left
//     canvas.drawLine(const Offset(r, 0), const Offset(r + len, 0), paint);
//     canvas.drawLine(const Offset(0, r), const Offset(0, r + len), paint);
//     canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);

//     // Top-right
//     canvas.drawLine(Offset(size.width - r - len, 0), Offset(size.width - r, 0), paint);
//     canvas.drawLine(Offset(size.width, r), Offset(size.width, r + len), paint);
//     canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), -1.57, 1.57, false, paint);

//     // Bottom-left
//     canvas.drawLine(Offset(r, size.height), Offset(r + len, size.height), paint);
//     canvas.drawLine(Offset(0, size.height - r), Offset(0, size.height - r - len), paint);
//     canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 1.57, 1.57, false, paint);

//     // Bottom-right
//     canvas.drawLine(Offset(size.width - r - len, size.height), Offset(size.width - r, size.height), paint);
//     canvas.drawLine(Offset(size.width, size.height - r), Offset(size.width, size.height - r - len), paint);
//     canvas.drawArc(
//         Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, 1.57, false, paint);
//   }

//   @override
//   bool shouldRepaint(_) => false;
// }

// // ── RESULT PANEL ─────────────────────────────────────────────────────────────

// class _ResultPanel extends StatelessWidget {
//   final Student? student;
//   final String? errorMsg;
//   final VoidCallback onClaim;
//   final VoidCallback onReset;
//   final bool isProcessing;

//   const _ResultPanel({
//     this.student,
//     this.errorMsg,
//     required this.onClaim,
//     required this.onReset,
//     required this.isProcessing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.bg,
//       child: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: onReset,
//                     child: Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: AppColors.surface,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: AppColors.border),
//                       ),
//                       child: const Icon(Icons.arrow_back, color: AppColors.text, size: 20),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     student != null ? 'Student Verified' : 'Not Found',
//                     style: const TextStyle(
//                         color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),

//               if (student != null) ...[
//                 StudentCard(student: student!, onClaim: onClaim, isProcessing: isProcessing),
//               ] else if (errorMsg != null) ...[
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: AppColors.redBg,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: AppColors.red.withOpacity(0.3)),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(Icons.qr_code, color: AppColors.red, size: 48),
//                       const SizedBox(height: 16),
//                       Text(errorMsg!,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                               color: AppColors.red, fontSize: 16, fontWeight: FontWeight.w500)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: onReset,
//                     icon: const Icon(Icons.qr_code_scanner),
//                     label: const Text('Scan Again'),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// // lib/screens/scanner_screen.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../services/firebase_service.dart';
// import '../models/student.dart';
// import '../theme.dart';
// import '../widgets/student_card.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen> {
//   late MobileScannerController _controller;

//   bool _processing = false;
//   Student? _foundStudent;
//   String? _errorMsg;

//   @override
//   void initState() {
//     super.initState();
//     _controller = MobileScannerController(
//       detectionSpeed: DetectionSpeed.normal,
//       facing: CameraFacing.back,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   // 🔍 SCAN LOGIC (scan once only)
//   Future<void> _onDetect(BarcodeCapture capture) async {
//     if (_processing || _foundStudent != null || _errorMsg != null) return;

//     final barcode = capture.barcodes.firstOrNull;
//     if (barcode?.rawValue == null) return;

//     final scannedId = barcode!.rawValue!;

//     setState(() => _processing = true);

//     HapticFeedback.mediumImpact();

//     await _controller.stop(); // pause camera

//     final student = await FirebaseService.getStudentById(scannedId);

//     if (!mounted) return;

//     setState(() {
//       _processing = false;

//       if (student != null) {
//         _foundStudent = student;
//         _errorMsg = null;
//       } else {
//         _foundStudent = null;
//         _errorMsg = 'Student not found.\nInvalid QR code.';
//       }
//     });
//   }

//   // 🔁 Restart scanning
//   void _resetScanner() async {
//     setState(() {
//       _foundStudent = null;
//       _errorMsg = null;
//       _processing = false;
//     });

//     await _controller.start();
//   }

//   // ✅ Mark claimed
//   Future<void> _markClaimed() async {
//     if (_foundStudent == null) return;

//     setState(() => _processing = true);

//     await FirebaseService.markClaimed(_foundStudent!.id);

//     HapticFeedback.heavyImpact();

//     if (!mounted) return;

//     setState(() {
//       _foundStudent = Student(
//         id: _foundStudent!.id,
//         name: _foundStudent!.name,
//         email: _foundStudent!.email,
//         department: _foundStudent!.department,
//         year: _foundStudent!.year,
//         claimed: true,
//         tshirtSize: _foundStudent!.tshirtSize,
//         claimedAt: DateTime.now(),
//       );
//       _processing = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // 📷 CAMERA (always mounted)
//           MobileScanner(
//             controller: _controller,
//             onDetect: _onDetect,
//           ),

//           // 🧭 TOP BAR
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Scan QR Code',
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.flash_on, color: Colors.white),
//                     onPressed: () => _controller.toggleTorch(),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ⏳ LOADING
//           if (_processing)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),

//           // 📄 RESULT PANEL
//           if (_foundStudent != null || _errorMsg != null)
//             _ResultPanel(
//               student: _foundStudent,
//               errorMsg: _errorMsg,
//               onClaim: _markClaimed,
//               onReset: _resetScanner,
//               isProcessing: _processing,
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ───────────────── RESULT PANEL ─────────────────

// class _ResultPanel extends StatelessWidget {
//   final Student? student;
//   final String? errorMsg;
//   final VoidCallback onClaim;
//   final VoidCallback onReset;
//   final bool isProcessing;

//   const _ResultPanel({
//     this.student,
//     this.errorMsg,
//     required this.onClaim,
//     required this.onReset,
//     required this.isProcessing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.bg,
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: onReset, // 🔁 restart scan
//               ),
//               Text(
//                 student != null ? 'Student Found' : 'Error',
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           if (student != null)
//             StudentCard(
//               student: student!,
//               onClaim: onClaim,
//               isProcessing: isProcessing,
//             )
//           else
//             Text(errorMsg ?? ''),
//         ],
//       ),
//     );
//   }
// }



// lib/screens/scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/firebase_service.dart';
import '../models/student.dart';
import '../theme.dart';
import '../widgets/student_card.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late MobileScannerController _controller;
  
  bool _processing = false;
  Student? _foundStudent;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔍 CORE LOOKUP LOGIC (Used by both QR and Manual Entry)
  Future<void> _handleLookup(String id) async {
    if (_processing) return;

    setState(() => _processing = true);
    HapticFeedback.mediumImpact();

    // Pause the camera hardware so it doesn't scan in the background
    await _controller.stop();

    final student = await FirebaseService.getStudentById(id);

    if (mounted) {
      setState(() {
        _processing = false;
        if (student != null) {
          _foundStudent = student;
          _errorMsg = null;
        } else {
          _errorMsg = 'Student not found.\nThis QR code is not registered.';
          _foundStudent = null;
        }
      });
    }
  }

  // 📸 QR DETECTION HANDLER
  void _onDetect(BarcodeCapture capture) {
    // Only trigger if we aren't already showing a result or loading
    if (_processing || _foundStudent != null || _errorMsg != null) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _handleLookup(barcode!.rawValue!);
    }
  }

  // 🔁 RESET / SCAN NEXT STUDENT
  void _resetScanner() async {
    setState(() {
      _foundStudent = null;
      _errorMsg = null;
      _processing = false;
    });

    // Re-activate the camera hardware for the next scan
    await _controller.start();
  }

  // ✅ MARK AS CLAIMED
  Future<void> _markClaimed() async {
    if (_foundStudent == null) return;
    setState(() => _processing = true);

    await FirebaseService.markClaimed(_foundStudent!.id);
    HapticFeedback.heavyImpact();

    if (mounted) {
      setState(() {
        _foundStudent = Student(
          id: _foundStudent!.id,
          name: _foundStudent!.name,
          email: _foundStudent!.email,
          department: _foundStudent!.department,
          year: _foundStudent!.year,
          claimed: true,
          tshirtSize: _foundStudent!.tshirtSize,
          claimedAt: DateTime.now(),
        );
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isShowingResult = _foundStudent != null || _errorMsg != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CAMERA LAYER (Always mounted for hardware stability)
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // 2. SCANNER OVERLAY (Visible only when looking for a code)
          if (!isShowingResult)
            _ScannerOverlay(
              onTorch: () => _controller.toggleTorch(),
              onManual: _showManualEntry,
            ),

          // 3. PROCESSING SPINNER
          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.blue),
                    SizedBox(height: 16),
                    Text('Verifying student...',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),

          // 4. RESULT PANEL (Student details or Error message)
          if (isShowingResult)
            _ResultPanel(
              student: _foundStudent,
              errorMsg: _errorMsg,
              onClaim: _markClaimed,
              onReset: _resetScanner, // Re-triggers the camera
              isProcessing: _processing,
            ),
        ],
      ),
    );
  }

  void _showManualEntry() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manual ID Entry',
                style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'e.g. abc123xyz',
                prefixIcon: Icon(Icons.badge_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final id = ctrl.text.trim();
                  if (id.isNotEmpty) {
                    Navigator.pop(ctx);
                    _handleLookup(id);
                  }
                },
                child: const Text('Look Up Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────── UI HELPER COMPONENTS ─────────────────

class _ScannerOverlay extends StatelessWidget {
  final VoidCallback onTorch;
  final VoidCallback onManual;

  const _ScannerOverlay({required this.onTorch, required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _OverlayPainter(),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Scan QR Code',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    Text('Point at student\'s QR code',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    _IconBtn(icon: Icons.flashlight_on_outlined, onTap: onTorch),
                    const SizedBox(width: 8),
                    _IconBtn(icon: Icons.keyboard_outlined, onTap: onManual, label: 'Manual'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(painter: _CornerPainter()),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  const _IconBtn({required this.icon, required this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(label!, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    const scanSize = 260.0;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanSize, scanSize);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)));
    canvas.drawPath(path, paint..blendMode = BlendMode.srcOver);

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
      Paint()
        ..color = AppColors.blue.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 32.0;
    const r = 16.0;

    // Top-left
    canvas.drawLine(const Offset(r, 0), const Offset(r + len, 0), paint);
    canvas.drawLine(const Offset(0, r), const Offset(0, r + len), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);

    // Top-right
    canvas.drawLine(Offset(size.width - r - len, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, r + len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), -1.57, 1.57, false, paint);

    // Bottom-left
    canvas.drawLine(Offset(r, size.height), Offset(r + len, size.height), paint);
    canvas.drawLine(Offset(0, size.height - r), Offset(0, size.height - r - len), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 1.57, 1.57, false, paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - r - len, size.height), Offset(size.width - r, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - r), Offset(size.width, size.height - r - len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, 1.57, false, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ResultPanel extends StatelessWidget {
  final Student? student;
  final String? errorMsg;
  final VoidCallback onClaim;
  final VoidCallback onReset;
  final bool isProcessing;

  const _ResultPanel({
    this.student,
    this.errorMsg,
    required this.onClaim,
    required this.onReset,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onReset,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    student != null ? 'Student Verified' : 'Not Found',
                    style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (student != null) ...[
                StudentCard(student: student!, onClaim: onClaim, isProcessing: isProcessing,onScanNext: onReset),
              ] else if (errorMsg != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code, color: AppColors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(errorMsg!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.red, fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Again'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}