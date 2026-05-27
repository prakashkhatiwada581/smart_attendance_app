import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'qr_scanner_screen.dart';
import '../reports/student_reports_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text('Welcome, ${user?.name ?? "Student"}', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Overall Attendance: ${user?.attendancePercentage.toStringAsFixed(1) ?? "0.0"}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: const Text('SCAN QR CODE', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QRScannerScreen()));
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart, size: 28, color: Colors.black),
                label: const Text('VIEW REPORTS', style: TextStyle(fontSize: 18, color: Colors.black)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), backgroundColor: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentReportsScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
