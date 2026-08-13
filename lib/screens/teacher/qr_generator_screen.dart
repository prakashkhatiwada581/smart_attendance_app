import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/custom_snackbar.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  int _durationMinutes = 5;
  String? _qrData;
  bool _isLoading = false;

  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = minutes * 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          CustomSnackbar.showWarning(context, "QR Code session has expired!");
        }
      }
    });
  }

  String get _formattedTimeLeft {
    int mins = _secondsRemaining ~/ 60;
    int secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _generateQR() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().user;
      final dbService = context.read<DatabaseService>();
      if (user != null) {
        final data = await dbService.createClassSession(
          user.id, 
          user.course, 
          _codeController.text.trim(),
          _nameController.text.trim(),
          _durationMinutes,
        );
        setState(() => _qrData = data);
        _startTimer(_durationMinutes);
        if (mounted) {
          CustomSnackbar.showSuccess(context, "QR Code session activated!");
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error generating QR: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Generate Attendance QR'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_qrData == null) ...[
                const Text(
                  'Setup New Class Session',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Students will scan this QR code to register their live attendance.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                ),
                const SizedBox(height: 24),

                GradientCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _codeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Subject Code',
                          hintText: 'e.g. CS101',
                          prefixIcon: Icon(Icons.code_rounded),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter subject code' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Subject Name',
                          hintText: 'e.g. Data Structures & Algorithms',
                          prefixIcon: Icon(Icons.book_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter subject name' : null,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<int>(
                        initialValue: _durationMinutes,
                        dropdownColor: AppTheme.surfaceColor,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Session Duration',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        items: [5, 10, 15, 30, 60].map((m) => DropdownMenuItem(
                          value: m,
                          child: Text('$m Minutes'),
                        )).toList(),
                        onChanged: (v) => setState(() => _durationMinutes = v!),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      // Active Timer Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _secondsRemaining > 0
                              ? AppTheme.successGreen.withValues(alpha: 0.15)
                              : AppTheme.errorRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _secondsRemaining > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _secondsRemaining > 0 ? Icons.timer_outlined : Icons.timer_off_outlined,
                              color: _secondsRemaining > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _secondsRemaining > 0 ? 'Time Left: $_formattedTimeLeft' : 'SESSION EXPIRED',
                              style: TextStyle(
                                color: _secondsRemaining > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                            begin: const Offset(0.97, 0.97),
                            end: const Offset(1.03, 1.03),
                            duration: 1.2.seconds,
                          ),

                      const SizedBox(height: 24),

                      // QR Container Card
                      GradientCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black38, blurRadius: 15, spreadRadius: 2),
                                ],
                              ),
                              child: QrImageView(
                                data: _qrData!,
                                version: QrVersions.auto,
                                size: 240.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _nameController.text,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Code: ${_codeController.text}',
                              style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                            begin: const Offset(0.98, 0.98),
                            end: const Offset(1.02, 1.02),
                            duration: 1200.ms,
                          ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: Icon(_qrData == null ? Icons.qr_code_rounded : Icons.refresh_rounded),
                        label: Text(_qrData == null ? 'GENERATE QR CODE' : 'GENERATE NEW SESSION'),
                        onPressed: _generateQR,
                      ),
                    ),

              if (_qrData != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    setState(() {
                      _qrData = null;
                      _secondsRemaining = 0;
                    });
                  },
                  child: const Text('Back to Setup', style: TextStyle(color: Colors.white60, fontSize: 14)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
