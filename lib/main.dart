import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

// Main application entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initializing Firebase with a timeout to prevent the app from hanging 
    // if there are configuration or network issues.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    debugPrint("Firebase initialized successfully.");
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint("The app will continue in Demo Mode.");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => DatabaseService()),
      ],
      child: const SmartAttendanceApp(),
    ),
  );
}

class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance System',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
