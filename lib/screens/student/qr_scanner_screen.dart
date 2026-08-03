import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';

class QRScannerScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  
  const QRScannerScreen({super.key, this.onSuccess});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? qrData = barcodes.first.rawValue;
      if (qrData != null) {
        setState(() => _isProcessing = true);
        
        try {
          final user = context.read<AuthProvider>().user;
          final dbService = context.read<DatabaseService>();
          if (user != null) {
            bool success = await dbService.markAttendance(user.id, qrData);
            if (!mounted) return;
            
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance Marked Successfully!'), backgroundColor: Colors.green));
              if (widget.onSuccess != null) {
                widget.onSuccess!();
              } else {
                Navigator.pop(context);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid or Expired QR Code!'), backgroundColor: Colors.red));
              setState(() => _isProcessing = false);
            }
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
