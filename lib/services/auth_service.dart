import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Get current user model
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    }
    return null;
  }

  // Register
  Future<UserModel?> register(String email, String password, String name, String role, String course) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        final userModel = UserModel(
          id: cred.user!.uid,
          name: name,
          email: email,
          role: role,
          course: course,
          attendancePercentage: 100.0,
        );
        await _db.collection('users').doc(userModel.id).set(userModel.toMap());
        return userModel;
      }
    } catch (e) {
      print("Error registering: $e");
      rethrow;
    }
    return null;
  }

  // Login
  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        final doc = await _db.collection('users').doc(cred.user!.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
      }
    } catch (e) {
      print("Error logging in: $e");
      rethrow;
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
