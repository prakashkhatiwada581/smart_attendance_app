import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final DatabaseService _dbService = DatabaseService();
  String? _qrData;
  bool _isLoading = false;

  void _generateQR() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        // Create a 5-minute session
        final data = await _dbService.createClassSession(user.id, user.course, 5);
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
      appBar: AppBar(title: const Text('Generate QR Code')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_qrData == null)
                const Text(
                  'Generate a secure QR code for your class session. It will be valid for 5 minutes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
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
                    const Text(
                      'Scan this code to mark attendance!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(_qrData == null ? 'GENERATE QR' : 'GENERATE NEW QR'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      onPressed: _generateQR,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
