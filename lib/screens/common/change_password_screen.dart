import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/custom_snackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().resetPassword(_newPassCtrl.text.trim());
        if (mounted) {
          CustomSnackbar.showSuccess(context, "Password updated successfully!");
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.showError(context, "Error: $e");
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
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0F2027), Color(0xff203A43), Color(0xff2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GradientCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _newPassCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => (v != null && v.length < 6) ? "Min 6 characters" : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        labelText: "New Password",
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => v != _newPassCtrl.text ? "Passwords do not match" : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_reset_rounded),
                        labelText: "Confirm Password",
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loading ? null : _updatePassword,
                        child: loading ? const CircularProgressIndicator() : const Text("UPDATE PASSWORD"),
                      ),
                    ),
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
