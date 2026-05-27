import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_session.dart';
import '../models/attendance_record.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new class session
  Future<String> createClassSession(String teacherId, String course, int durationMinutes) async {
    final now = DateTime.now();
    final activeUntil = now.add(Duration(minutes: durationMinutes));
    
    final docRef = _db.collection('classes').doc();
    final qrData = '{"classId":"${docRef.id}", "token":"${now.millisecondsSinceEpoch}"}';
    
    final session = ClassSession(
      id: docRef.id,
      teacherId: teacherId,
      course: course,
      createdAt: now,
      activeUntil: activeUntil,
      qrData: qrData,
    );

    await docRef.set(session.toMap());
    return qrData; // Goes into the QR generator
  }

  // Mark attendance
  Future<bool> markAttendance(String studentId, String qrDataPayload) async {
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
      print("Error marking attendance: $e");
      return false;
    }
  }

  // Get student attendance
  Stream<List<AttendanceRecord>> getStudentAttendance(String studentId) {
    return _db.collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => AttendanceRecord.fromMap(doc.data(), doc.id)).toList());
  }

  // Get teacher classes
  Stream<List<ClassSession>> getTeacherClasses(String teacherId) {
    return _db.collection('classes')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ClassSession.fromMap(doc.data(), doc.id)).toList());
  }
}
