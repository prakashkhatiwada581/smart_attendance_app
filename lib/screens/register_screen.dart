import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/gradient_card.dart';
import '../widgets/custom_snackbar.dart';
import 'teacher/teacher_dashboard.dart';
import 'student/student_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.register(
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
          _nameCtrl.text.trim(),
          _role,
          _courseCtrl.text.trim(),
        );

        if (!mounted) return;

        final user = authProvider.user;

        if (user != null) {
          CustomSnackbar.showSuccess(context, "Account created! Welcome, ${user.name}");
          if (user.role == "teacher") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const TeacherDashboard()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StudentDashboard()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        CustomSnackbar.showError(context, "Registration Failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Create Account"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GradientCard(
                borderRadius: 28,
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Role Icon Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 20),
                      const Text(
                        "Join Smart Attendance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(),

                      const SizedBox(height: 6),
                      Text(
                        "Fill in your details to set up your profile",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 28),

                      // Full Name
                      TextFormField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Enter full name" : null,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Enter email address" : null,
                        decoration: const InputDecoration(
                          labelText: "Email Address",
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 16),

                      // Course / Department
                      TextFormField(
                        controller: _courseCtrl,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Enter course or department" : null,
                        decoration: const InputDecoration(
                          labelText: "Course / Department",
                          hintText: "e.g. Computer Science, B.Tech CS",
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 16),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        dropdownColor: AppTheme.surfaceColor,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: "Account Role",
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "student",
                            child: Text("Student"),
                          ),
                          DropdownMenuItem(
                            value: "teacher",
                            child: Text("Teacher / Instructor"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _role = value);
                        },
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.length < 6) ? "Password must be at least 6 characters" : null,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.white38,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms),

                      const SizedBox(height: 28),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _register,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text("CREATE ACCOUNT"),
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Already have an account? Sign In",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ).animate().fadeIn(delay: 450.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
