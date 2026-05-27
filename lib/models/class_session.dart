import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSession {
  final String id;
  final String teacherId;
  final String course;
  final DateTime createdAt;
  final DateTime activeUntil;
  final String qrData; // JSON or encrypted token

  ClassSession({
    required this.id,
    required this.teacherId,
    required this.course,
    required this.createdAt,
    required this.activeUntil,
    required this.qrData,
  });

  factory ClassSession.fromMap(Map<String, dynamic> data, String documentId) {
    return ClassSession(
      id: documentId,
      teacherId: data['teacherId'] ?? '',
      course: data['course'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      activeUntil: (data['activeUntil'] as Timestamp).toDate(),
      qrData: data['qrData'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacherId': teacherId,
      'course': course,
      'createdAt': Timestamp.fromDate(createdAt),
      'activeUntil': Timestamp.fromDate(activeUntil),
      'qrData': qrData,
    };
  }

  bool get isActive => DateTime.now().isBefore(activeUntil);
}
