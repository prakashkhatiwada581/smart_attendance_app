import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/custom_snackbar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _classReminders = true;
  bool _attendanceAlerts = true;
  bool _emailWeeklyReport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Notification Settings"),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Preferences",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ).animate().fadeIn(),
                const SizedBox(height: 6),
                Text(
                  "Configure how and when you receive attendance notifications.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                ).animate().fadeIn(delay: 50.ms),

                const SizedBox(height: 24),

                GradientCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        title: "Push Notifications",
                        subtitle: "Receive live app updates and instant status alerts",
                        icon: Icons.notifications_active_rounded,
                        value: _pushEnabled,
                        onChanged: (val) => setState(() => _pushEnabled = val),
                      ),
                      const Divider(color: Colors.white10),
                      _buildSwitchTile(
                        title: "Class Reminders",
                        subtitle: "Get notified 15 minutes before session QR expires",
                        icon: Icons.alarm_rounded,
                        value: _classReminders,
                        onChanged: (val) => setState(() => _classReminders = val),
                      ),
                      const Divider(color: Colors.white10),
                      _buildSwitchTile(
                        title: "Low Attendance Alerts",
                        subtitle: "Alert when attendance drops below 75% limit",
                        icon: Icons.warning_amber_rounded,
                        value: _attendanceAlerts,
                        onChanged: (val) => setState(() => _attendanceAlerts = val),
                      ),
                      const Divider(color: Colors.white10),
                      _buildSwitchTile(
                        title: "Weekly Summary Email",
                        subtitle: "Receive automated weekly breakdown by email",
                        icon: Icons.mark_email_read_rounded,
                        value: _emailWeeklyReport,
                        onChanged: (val) => setState(() => _emailWeeklyReport = val),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      CustomSnackbar.showSuccess(context, "Notification settings saved!");
                      Navigator.pop(context);
                    },
                    child: const Text("SAVE PREFERENCES"),
                  ),
                ).animate().fadeIn(delay: 250.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.accentCyan,
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.accentBlue, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
    );
  }
}
