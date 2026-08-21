import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final ready = await _authService.initialize();
    if (!ready) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _authService.userStream.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _user = null;
      } else {
        _user = await _authService.getCurrentUser();
        if (_user != null) {
          _notificationService.init(_user!.id);
        }
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.login(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name, String role, String course) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.register(email, password, name, role, course);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.signInWithGoogle();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.sendOtp(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _authService.verifyOtp(email, otp);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPassword(newPassword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.logout();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? profilePath}) async {
    if (_user == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        profileImageUrl: profilePath
      );
      
      await _authService.updateUser(updatedUser);
      _user = updatedUser;
    } catch (e) {
      debugPrint("Update profile error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
