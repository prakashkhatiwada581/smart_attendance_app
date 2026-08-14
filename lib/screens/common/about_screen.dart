import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../widgets/gradient_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("About & System Info"),
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
            child: Column(
              children: [
                // App Logo & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 16),

                      const Text(
                        "Smart Attendance System",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(),

                      const SizedBox(height: 4),

                      Text(
                        "Version 2.0.0 (Build 2026.1)",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ).animate().fadeIn(delay: 50.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Feature Highlights
                GradientCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Key Features",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      _buildFeatureRow(Icons.qr_code_rounded, "Dynamic QR Code Generation", "Timed class sessions for instant verification"),
                      const SizedBox(height: 12),
                      _buildFeatureRow(Icons.camera_alt_rounded, "High-Speed Mobile Scanner", "Seamless QR capture with flash & camera controls"),
                      const SizedBox(height: 12),
                      _buildFeatureRow(Icons.analytics_rounded, "Real-time Attendance Analytics", "Interactive weekly bar charts and ratio breakdown"),
                      const SizedBox(height: 12),
                      _buildFeatureRow(Icons.security_rounded, "Role-Based Access Control", "Dedicated dashboards for Teachers & Students"),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 20),

                // Credits Card
                GradientCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.code_rounded, color: AppTheme.accentCyan, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Developed with Flutter",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Engineered for modern high-performance institutional attendance tracking.",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Legal / Footer
                Text(
                  "© 2026 Smart Attendance App. All Rights Reserved.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                ).animate().fadeIn(delay: 250.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
