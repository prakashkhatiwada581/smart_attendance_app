class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'teacher' or 'student'
  final String course;
  final double attendancePercentage;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.course,
    this.attendancePercentage = 0.0,
    this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      course: data['course'] ?? '',
      attendancePercentage: (data['attendancePercentage'] ?? 0.0).toDouble(),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'course': course,
      'attendancePercentage': attendancePercentage,
      'profileImageUrl': profileImageUrl,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? course,
    double? attendancePercentage,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      course: course ?? this.course,
      attendancePercentage: attendancePercentage ?? this.attendancePercentage,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
