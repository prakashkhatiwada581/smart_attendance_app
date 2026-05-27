import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'qr_generator_screen.dart';
import '../../models/user_model.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Welcome, ${user?.name ?? "Teacher"}', 
                      style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Course: ${user?.course ?? "-"}',
                      style: const TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code, color: Colors.black),
                      label: const Text('Generate Assembly QR', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QRGeneratorScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Low Attendance Students (<75%)', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .where('course', isEqualTo: user?.course)
                  .where('attendancePercentage', isLessThan: 75)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('All students have good attendance!');
                }
                final students = snapshot.data!.docs.map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.warning, color: Colors.white)),
                      title: Text(student.name),
                      subtitle: Text('${student.attendancePercentage.toStringAsFixed(1)}% attendance'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
