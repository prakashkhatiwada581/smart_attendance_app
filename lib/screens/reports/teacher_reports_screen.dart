import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/class_session.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';

class TeacherReportsScreen extends StatelessWidget {
  const TeacherReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final dbService = context.read<DatabaseService>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Session History"),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const EmptyStateWidget(
              icon: Icons.person_off_rounded,
              title: "Unauthorized",
              message: "Please sign in to view reports.",
            )
          : StreamBuilder<List<ClassSession>>(
              stream: dbService.getTeacherClasses(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load sessions.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.history_rounded,
                    title: "No Sessions",
                    message: "Generated QR sessions will appear here.",
                  );
                }

                final sessions = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return GradientCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.class_rounded, color: AppTheme.primaryBlue),
                        ),
                        title: Text(
                          session.subjectName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${session.subjectCode} • ${DateFormat.yMMMd().add_jm().format(session.createdAt)}",
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        trailing: Icon(
                          session.isActive ? Icons.timer_outlined : Icons.timer_off_outlined,
                          color: session.isActive ? AppTheme.successGreen : AppTheme.errorRed,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
