import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_snackbar.dart';

class QRScannerScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  
  const QRScannerScreen({super.key, this.onSuccess});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

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
              CustomSnackbar.showSuccess(context, 'Attendance Marked Successfully!');
              if (widget.onSuccess != null) {
                widget.onSuccess!();
              } else {
                Navigator.pop(context);
              }
            } else {
              CustomSnackbar.showError(context, 'Invalid or Expired QR Code!');
              setState(() => _isProcessing = false);
            }
          }
        } catch (e) {
          if (!mounted) return;
          CustomSnackbar.showError(context, 'Error marking attendance: $e');
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindowSize = MediaQuery.of(context).size.width * 0.72;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan Class QR Code'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: state.torchState == TorchState.on
                      ? AppTheme.accentCyan
                      : Colors.white70,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white70),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Live Camera Stream
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Semi-transparent Overlay Mask
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.65),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanWindowSize,
                    height: scanWindowSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Custom Animated Corner Brackets
          SizedBox(
            width: scanWindowSize,
            height: scanWindowSize,
            child: Stack(
              children: [
                Positioned(top: 0, left: 0, child: _buildCorner(isTop: true, isLeft: true)),
                Positioned(top: 0, right: 0, child: _buildCorner(isTop: true, isLeft: false)),
                Positioned(bottom: 0, left: 0, child: _buildCorner(isTop: false, isLeft: true)),
                Positioned(bottom: 0, right: 0, child: _buildCorner(isTop: false, isLeft: false)),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                begin: const Offset(0.98, 0.98),
                end: const Offset(1.02, 1.02),
                duration: 1200.ms,
              ),

          // Instruction Guidance Text
          Positioned(
            bottom: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.center_focus_weak_rounded, color: AppTheme.accentCyan, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Align QR code inside the frame',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.accentCyan),
                    SizedBox(height: 16),
                    Text(
                      'Verifying Attendance...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppTheme.accentCyan, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppTheme.accentCyan, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppTheme.accentCyan, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppTheme.accentCyan, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
