import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/database_service.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

// IMPORTANT: Run `flutter fire configure` to generate `firebase_options.dart`,
// and then import it here and pass DefaultFirebaseOptions.currentPlatform
// to Firebase.initializeApp().
// import 'firebase_options.dart';
// Main application entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // We initialize Firebase in the background or within the AuthProvider
  // to prevent the app from hanging if configuration is missing.
  
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
