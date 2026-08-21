import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/class_session.dart';
import '../models/attendance_record.dart';
import '../models/user_model.dart';

class DatabaseService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool _isFirebaseAvailable() {
    try {
      return FirebaseFirestore.instance.app.name.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Create a new class session
  Future<String> createClassSession(String teacherId, String course, String subjectCode, String subjectName, int durationMinutes) async {
    final now = DateTime.now();
    final activeUntil = now.add(Duration(minutes: durationMinutes));
    
    final docRef = _db.collection('classes').doc();
    final qrData = '{"classId":"${docRef.id}", "subjectCode":"$subjectCode", "token":"${now.millisecondsSinceEpoch}"}';
    
    if (!_isFirebaseAvailable()) {
      debugPrint("Firebase not available. Simulating session creation.");
      return qrData;
    }

    try {
      final session = ClassSession(
        id: docRef.id,
        teacherId: teacherId,
        course: course,
        subjectCode: subjectCode,
        subjectName: subjectName,
        createdAt: now,
        activeUntil: activeUntil,
        qrData: qrData,
      );

      await _db.collection('classes').doc(session.id).set(session.toMap());
      return qrData;
    } catch (e) {
      debugPrint("Error creating session: $e");
      return qrData;
    }
  }

  // Mark attendance
  Future<bool> markAttendance(String studentId, String qrDataPayload) async {
    if (!_isFirebaseAvailable()) {
      debugPrint("Firebase not available. Simulating attendance marking.");
      return true; 
    }

    try {
      final classQuery = await _db.collection('classes').where('qrData', isEqualTo: qrDataPayload).limit(1).get();
      
      if (classQuery.docs.isEmpty) return false;

      final doc = classQuery.docs.first;
      final session = ClassSession.fromMap(doc.data(), doc.id);

      if (!session.isActive) return false;

      final existing = await _db.collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('classId', isEqualTo: session.id)
          .get();

      if (existing.docs.isNotEmpty) return true; // Already marked

      final record = AttendanceRecord(
        id: '',
        studentId: studentId,
        classId: session.id,
        date: DateTime.now(),
        status: 'present',
        timestamp: DateTime.now(),
      );

      await _db.collection('attendance').add(record.toMap());
      return true;
    } catch (e) {
      debugPrint("Error marking attendance: $e");
      return false;
    }
  }

  // Get student attendance - REMOVED ALL FILTERS TO AVOID INDEX ERROR
  Stream<List<AttendanceRecord>> getStudentAttendance(String studentId) {
    if (!_isFirebaseAvailable()) {
      return Stream.value([
        AttendanceRecord(
          id: '1',
          studentId: studentId,
          classId: 'c1',
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: 'present',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
    }
    
    // We fetch the whole collection and filter in Dart to avoid needing an Index.
    return _db.collection('attendance')
        .snapshots()
        .map((snap) {
          final list = snap.docs
            .map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id))
            .where((r) => r.studentId == studentId)
            .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort descending
          return list;
        });
  }

  // Get teacher classes - REMOVED ALL FILTERS TO AVOID INDEX ERROR
  Stream<List<ClassSession>> getTeacherClasses(String teacherId) {
    if (!_isFirebaseAvailable()) {
      return Stream.value([]);
    }
    
    return _db.collection('classes')
        .snapshots()
        .map((snap) {
          final list = snap.docs
            .map((doc) => ClassSession.fromMap(doc.data(), doc.id))
            .where((s) => s.teacherId == teacherId)
            .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort descending
          return list;
        });
  }

  // Get low attendance students - REMOVED ALL FILTERS TO AVOID INDEX ERROR
  Stream<List<UserModel>> getLowAttendanceStudents(String? course) {
    if (!_isFirebaseAvailable()) {
      return Stream.value([
        UserModel(id: 's1', name: 'John Doe', email: 'john@test.com', role: 'student', course: course ?? 'CS', attendancePercentage: 65.5),
        UserModel(id: 's2', name: 'Jane Smith', email: 'jane@test.com', role: 'student', course: course ?? 'CS', attendancePercentage: 72.0),
      ]);
    }

    // We fetch the whole users collection and filter manually in Dart
    // This ensures NO INDEX IS REQUIRED.
    return _db.collection('users')
        .snapshots()
        .map((snap) {
          return snap.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .where((u) => u.role == 'student' && (course == null || u.course == course) && u.attendancePercentage < 75)
            .toList();
        });
  }
}
