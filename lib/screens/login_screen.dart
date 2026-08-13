import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/gradient_card.dart';
import '../widgets/custom_snackbar.dart';
import 'register_screen.dart';
import 'teacher/teacher_dashboard.dart';
import 'student/student_dashboard.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );

        if (!mounted) return;

        final user = authProvider.user;

        if (user != null) {
          CustomSnackbar.showSuccess(context, "Welcome back, ${user.name}!");
          _navigateToDashboard(user.role);
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(context, e.toString());
        }
      }
    }
  }

  void _signInWithGoogle() async {
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithGoogle();

      if (!mounted) return;
      final user = authProvider.user;
      if (user != null) {
        CustomSnackbar.showSuccess(context, "Signed in with Google as ${user.name}");
        _navigateToDashboard(user.role);
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, e.toString());
    }
  }

  void _navigateToDashboard(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => role == 'teacher' 
          ? const TeacherDashboard() 
          : const StudentDashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
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
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Icon
                      Container(
                        padding: const EdgeInsets.all(22),
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
                          Icons.qr_code_scanner_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 24),
                      const Text(
                        "Smart Attendance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 6),
                      const Text(
                        "Sign in to continue to your dashboard",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 32),

                      // Email Input
                      TextFormField(
                        controller: _emailCtrl,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Enter email address" : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                          labelText: "Email Address",
                          hintText: "student@univ.edu or teacher@univ.edu",
                        ),
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 18),

                      // Password Input
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Enter password" : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.white38,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          labelText: "Password",
                        ),
                      ).animate().fadeIn(delay: 350.ms),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: AppTheme.accentBlue, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 12),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _login,
                          child: loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text("SIGN IN"),
                        ),
                      ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15))),
                        ],
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 20),

                      // Google Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: loading ? null : _signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.white),
                          label: const Text("CONTINUE WITH GOOGLE"),
                        ),
                      ).animate().fadeIn(delay: 550.ms),

                      const SizedBox(height: 28),

                      // Register Navigation Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?", style: TextStyle(color: Colors.white60, fontSize: 14)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              "Create Account",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan, fontSize: 14),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
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
