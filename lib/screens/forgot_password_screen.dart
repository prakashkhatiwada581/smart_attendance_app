import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/gradient_card.dart';
import '../widgets/custom_snackbar.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().sendOtp(_emailCtrl.text.trim());
        if (mounted) {
          CustomSnackbar.showInfo(context, "Verification code sent to email.");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(email: _emailCtrl.text.trim()),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(context, "Error sending code: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.transparent,
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
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                          Icons.mark_email_read_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 24),
                      const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(),

                      const SizedBox(height: 8),
                      Text(
                        "Enter your registered email address and we'll send you a 4-digit verification code.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _emailCtrl,
                        style: const TextStyle(color: Colors.white),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Enter email address" : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                          labelText: "Email Address",
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _sendOtp,
                          child: loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Text("SEND VERIFICATION CODE"),
                        ),
                      ).animate().fadeIn(delay: 300.ms),
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
