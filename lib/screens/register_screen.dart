import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'teacher/teacher_dashboard.dart';
import 'student/student_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _role = 'student';

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().register(
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
          _nameCtrl.text.trim(),
          _role,
          _courseCtrl.text.trim(),
        );
        final user = context.read<AuthProvider>().user;
        if (user != null && mounted) {
          if (user.role == 'teacher') {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const TeacherDashboard()), (route) => false);
          } else {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const StudentDashboard()), (route) => false);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                validator: (v) => v!.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseCtrl,
                decoration: const InputDecoration(labelText: 'Course / Department', prefixIcon: Icon(Icons.school)),
                validator: (v) => v!.isEmpty ? 'Enter course' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge)),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 24),
              isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text('REGISTER'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
