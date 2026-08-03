import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';

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

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
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
          _durationMinutes
        );
        setState(() => _qrData = data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating QR: $e')));
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
        title: const Text('Generate QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                  'Set up Class Session',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _codeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Subject Code (e.g., CS101)',
                    prefixIcon: Icon(Icons.code),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter subject code' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    prefixIcon: Icon(Icons.book),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter subject name' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _durationMinutes,
                  dropdownColor: const Color(0xff203A43),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Duration (Minutes)',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  items: [5, 10, 15, 30, 60].map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('$m Minutes'),
                  )).toList(),
                  onChanged: (v) => setState(() => _durationMinutes = v!),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                          ],
                        ),
                        child: QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: 250.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'QR Code for ${_nameController.text}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Expires in $_durationMinutes minutes',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: Icon(_qrData == null ? Icons.qr_code : Icons.refresh),
                      label: Text(_qrData == null ? 'GENERATE QR' : 'GENERATE NEW QR'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _generateQR,
                    ),
              if (_qrData != null)
                TextButton(
                  onPressed: () => setState(() => _qrData = null),
                  child: const Text('Back to Setup', style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
