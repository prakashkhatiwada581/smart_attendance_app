import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

// IMPORTANT: Run `flutter fire configure` to generate `firebase_options.dart`,
// and then import it here and pass DefaultFirebaseOptions.currentPlatform
// to Firebase.initializeApp().
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // If you have firebase_options.dart:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp(); 
  } catch (e) {
    debugPrint("Firebase initialization failed. Please run flutterfire configure.");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SmartAttendanceApp(),
    ),
  );
}

class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
