import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/custom_snackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      try {
        await auth.resetPassword(_newPassCtrl.text.trim());
        if (mounted) {
          CustomSnackbar.showSuccess(context, "Password updated successfully!");
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(context, "Failed to change password: $e");
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
        title: const Text("Change Password"),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GradientCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: const Icon(Icons.lock_reset_rounded, size: 36, color: Colors.white),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 20),
                    const Text(
                      "Security Settings",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ).animate().fadeIn(),

                    const SizedBox(height: 6),
                    Text(
                      "Your new password must be at least 6 characters long.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    ).animate().fadeIn(delay: 50.ms),

                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _currentPassCtrl,
                      obscureText: _obscureCurrent,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => (v == null || v.isEmpty) ? "Enter current password" : null,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white38),
                          onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _newPassCtrl,
                      obscureText: _obscureNew,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => (v != null && v.length < 6) ? "Password must be at least 6 characters" : null,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        prefixIcon: const Icon(Icons.key_off_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white38),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v != _newPassCtrl.text ? "Passwords do not match" : null,
                      decoration: InputDecoration(
                        labelText: "Confirm New Password",
                        prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white38),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: loading ? null : _changePassword,
                        child: loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text("UPDATE PASSWORD"),
                      ),
                    ).animate().fadeIn(delay: 250.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
