// lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── AUTH ──────────────────────────────────────────────

  static Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── STUDENTS ──────────────────────────────────────────

  /// Fetch a single student by their Firestore document ID (= QR content)
  static Future<Student?> getStudentById(String id) async {
    try {
      final doc = await _db.collection('students').doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return Student.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all students (for dashboard listing)
  static Stream<List<Student>> getStudentsStream() {
    return _db
        .collection('students')
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Student.fromFirestore(d.data(), d.id))
            .toList());
  }

  /// Mark a student's swag as claimed
  static Future<void> markClaimed(String studentId) async {
    await _db.collection('students').doc(studentId).update({
      'claimed': true,
      'claimedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get stats snapshot
  static Future<Map<String, int>> getStats() async {
    final snap = await _db.collection('students').get();
    final total = snap.docs.length;
    final claimed = snap.docs.where((d) => d.data()['claimed'] == true).length;
    return {'total': total, 'claimed': claimed, 'pending': total - claimed};
  }
}
