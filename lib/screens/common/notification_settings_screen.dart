import 'package:flutter/material.dart';
import '../../widgets/gradient_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _sessionReminders = true;
  bool _attendanceAlerts = true;
  bool _systemUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Notifications"),
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
            child: Column(
              children: [
                GradientCard(
                  child: Column(
                    children: [
                      _buildToggle("Session Reminders", "Get notified before class starts", _sessionReminders, (v) => setState(() => _sessionReminders = v)),
                      const Divider(color: Colors.white10),
                      _buildToggle("Attendance Alerts", "Notifications for marked attendance", _attendanceAlerts, (v) => setState(() => _attendanceAlerts = v)),
                      const Divider(color: Colors.white10),
                      _buildToggle("System Updates", "Important announcements", _systemUpdates, (v) => setState(() => _systemUpdates = v)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      activeThumbColor: Colors.blueAccent,
    );
  }
}
