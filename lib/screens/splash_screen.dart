import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'teacher/teacher_dashboard.dart';
import 'student/student_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoading) {
      // Wait a bit more if still loading auth state
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;
    
    if (auth.isAuthenticated && auth.user != null) {
      if (auth.user!.role == 'teacher') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TeacherDashboard()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StudentDashboard()));
      }
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
