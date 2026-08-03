import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'teacher/teacher_dashboard.dart';
import 'student/student_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    debugPrint("SplashScreen: Starting auth check...");
    // Give time for the animation/splash to be seen
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    
    // If it's still loading, we wait a bit more, but not forever
    int retryCount = 0;
    while (auth.isLoading && retryCount < 3) {
      debugPrint("SplashScreen: Auth is still loading, waiting... ($retryCount)");
      await Future.delayed(const Duration(seconds: 1));
      retryCount++;
    }

    if (!mounted) return;
    
    debugPrint("SplashScreen: Auth check complete. Authenticated: ${auth.isAuthenticated}, User: ${auth.user?.name}");

    if (auth.isAuthenticated && auth.user != null) {
      if (auth.user!.role == 'teacher') {
        debugPrint("SplashScreen: Navigating to Teacher Dashboard");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TeacherDashboard()),
        );
      } else {
        debugPrint("SplashScreen: Navigating to Student Dashboard");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
      }
    } else {
      debugPrint("SplashScreen: Navigating to Login Screen");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Smart Attendance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
