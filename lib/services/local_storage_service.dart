import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vision_gallery_saver/vision_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class LocalStorageService {
  static final ImagePicker _picker = ImagePicker();

  // 📸 Capture (optimized)
  static Future<XFile?> captureImage() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
      maxWidth: 1024,
    );
  }

  // ⚡ Instant return + background save
  static Future<String?> saveStudentImage(
      String studentId, XFile image) async {
    try {
      final originalPath = image.path;

      _processAndSaveInBackground(studentId, originalPath);

      return originalPath; // instant preview
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // 🧠 Background processing
  static Future<void> _processAndSaveInBackground(
      String studentId, String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Uint8List fixedBytes = await compute(_processImage, path);

      // delete old image
      final oldName = prefs.getString('gallery_$studentId');
      if (oldName != null) {
        final dir = Directory('/storage/emulated/0/Pictures/GCloud');
        final oldFile = File('${dir.path}/$oldName.jpg');
        if (await oldFile.exists()) await oldFile.delete();
      }

      // save new image
      final fileName =
          "$studentId-${DateTime.now().millisecondsSinceEpoch}";

      await VisionGallerySaver.saveImage(
        fixedBytes,
        name: fileName,
        androidRelativePath: "Pictures/GCloud",
      );

      await prefs.setString('gallery_$studentId', fileName);

      // save local copy
      final dir = await getApplicationDocumentsDirectory();
      final localPath = p.join(dir.path, '$studentId.jpg');

      await File(localPath).writeAsBytes(fixedBytes, flush: true);
    } catch (e) {
      print("Background error: $e");
    }
  }

  // isolate work
  static Future<Uint8List> _processImage(String path) async {
    final bytes = await File(path).readAsBytes();

    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception("Decode failed");

    final fixed = img.bakeOrientation(decoded);

    return Uint8List.fromList(img.encodeJpg(fixed, quality: 90));
  }

  // 📂 Load saved image
  static Future<List<String>> getStudentImages(String studentId) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, '$studentId.jpg');

    final file = File(filePath);
    if (await file.exists()) return [file.path];

    return [];
  }
}