import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../firebase_options.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  bool _isReady = false;

  // For Prototype/Demo mode when Firebase is not configured
  UserModel? _mockUser;

  bool get isReady => _isReady;

  Future<bool> initialize() async {
    if (_isReady) return true;

    try {
      if (Firebase.apps.isEmpty) {
        // Add a timeout to prevent hanging if Firebase is not configured
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 10));
      }
      _isReady = true;
      return true;
    } catch (e) {
      debugPrint('Firebase initialization failed or timed out: $e');
      _isReady = false;
      return false;
    }
  }

  // Stream of auth changes
  Stream<User?> get userStream {
    if (!_isReady) {
      return const Stream.empty();
    }
    return _auth.authStateChanges();
  }

  // Get current user model
  Future<UserModel?> getCurrentUser() async {
    if (!_isReady) return _mockUser;

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
    if (!_isReady) {
      _mockUser = UserModel(
        id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
        name: name.isNotEmpty ? name : 'Demo User',
        email: email,
        role: role,
        course: course,
        attendancePercentage: 100.0,
      );
      return _mockUser;
    }

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
      debugPrint('Error registering: $e');
      rethrow;
    }
    return null;
  }

  // Login
  Future<UserModel?> login(String email, String password) async {
    if (!_isReady) {
      // For the prototype, if no one registered yet, create a default
      // If someone registered (in _mockUser), check if email matches or just allow it
      if (_mockUser != null && _mockUser!.email == email) {
        return _mockUser;
      }
      
      // Default demo user if no registration happened in this session
      _mockUser = UserModel(
        id: 'demo-user',
        name: email.split('@').first,
        email: email,
        role: email.contains('teacher') ? 'teacher' : 'student',
        course: 'Computer Science',
        attendancePercentage: 85.0,
      );
      return _mockUser;
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        final doc = await _db.collection('users').doc(cred.user!.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
      }
    } catch (e) {
      debugPrint('Error logging in: $e');
      rethrow;
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    if (!_isReady) {
      _mockUser = null;
      return;
    }
    await _auth.signOut();
  }

  Future<void> updateUser(UserModel user) async {
    if (!_isReady) {
      _mockUser = user;
      return;
    }
    await _db.collection('users').doc(user.id).update(user.toMap());
  }
}
