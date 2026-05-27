import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String studentId;
  final String classId;
  final DateTime date;
  final String status;
  final DateTime timestamp;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    required this.timestamp,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> data, String documentId) {
    return AttendanceRecord(
      id: documentId,
      studentId: data['studentId'] ?? '',
      classId: data['classId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'present',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classId': classId,
      'date': Timestamp.fromDate(date),
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
