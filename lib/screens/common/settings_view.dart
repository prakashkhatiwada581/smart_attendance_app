import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/gradient_card.dart';
import '../login_screen.dart';
import 'profile_screen.dart';
import 'notification_settings_screen.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  ImageProvider? _getAvatarProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) {
      return CachedNetworkImageProvider(url);
    }
    return FileImage(File(url));
  }

  

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Summary Card
            GradientCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.25),
                    backgroundImage: _getAvatarProvider(user?.profileImageUrl),
                    child: user?.profileImageUrl == null
                        ? const Icon(Icons.person_rounded, size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? "User Profile",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? "",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            (user?.role ?? "student").toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.accentCyan,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 30),
            
            // Settings Options List
            _buildSettingItem(
              context: context,
              icon: Icons.edit_note_rounded,
              title: "Edit Profile",
              subtitle: "Update full name & profile picture",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ));
              },
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 14),

            _buildSettingItem(
              context: context,
              icon: Icons.notifications_none_rounded,
              title: "Notifications",
              subtitle: "Manage session & attendance alerts",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ));
              },
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 14),

            _buildSettingItem(
              context: context,
              icon: Icons.lock_outline_rounded,
              title: "Privacy & Password",
              subtitle: "Change account password",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ));
              },
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 14),

            _buildSettingItem(
              context: context,
              icon: Icons.help_outline_rounded,
              title: "Help & Project Info",
              subtitle: "FAQ, system details & guide",
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ));
              },
            ).animate().fadeIn(delay: 250.ms),
            
            const SizedBox(height: 40),
            
            // Logout Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text("SIGN OUT"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorRed,
                  side: const BorderSide(color: AppTheme.errorRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GradientCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.accentBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
        ],
      ),
    );
  }
}
