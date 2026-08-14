import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/section_header.dart';

class TeacherReportsScreen extends StatefulWidget {
  const TeacherReportsScreen({super.key});

  @override
  State<TeacherReportsScreen> createState() => _TeacherReportsScreenState();
}

class _TeacherReportsScreenState extends State<TeacherReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final dbService = context.read<DatabaseService>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Class Attendance Analytics'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const EmptyStateWidget(
              icon: Icons.person_off_rounded,
              title: 'Not Logged In',
              subtitle: 'Please sign in to view class reports',
            )
          : StreamBuilder<List<UserModel>>(
              stream: dbService.getLowAttendanceStudents(user.course),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allStudents = snapshot.data ?? [];
                final filteredStudents = allStudents.where((student) {
                  return student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      student.email.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                double avgAttendance = allStudents.isEmpty
                    ? 100
                    : allStudents.map((e) => e.attendancePercentage).reduce((a, b) => a + b) / allStudents.length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overview Metric Cards
                      const SectionHeader(
                        title: 'Course Summary',
                        icon: Icons.dashboard_outlined,
                      ),
                      
                      Row(
                        children: [
                          Expanded(
                            child: GradientCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.people_alt_rounded, color: AppTheme.accentCyan, size: 24),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${allStudents.length}',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Flagged Students',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 100.ms),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GradientCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.show_chart_rounded, color: AppTheme.successGreen, size: 24),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${avgAttendance.toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Avg Course Ratio',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 150.ms),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Attendance Distribution Bar Chart
                      const SectionHeader(
                        title: 'Attendance Risk Overview',
                        icon: Icons.bar_chart_rounded,
                      ),

                      GradientCard(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int idx = value.toInt();
                                      if (idx >= 0 && idx < filteredStudents.length && idx < 5) {
                                        final parts = filteredStudents[idx].name.split(' ');
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            parts.isNotEmpty ? parts[0] : '',
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: true, interval: 25, reservedSize: 28),
                                ),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.05)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(
                                filteredStudents.length > 5 ? 5 : filteredStudents.length,
                                (index) {
                                  final st = filteredStudents[index];
                                  final color = st.attendancePercentage < 60 ? AppTheme.errorRed : AppTheme.warningOrange;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: st.attendancePercentage,
                                        color: color,
                                        width: 22,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 28),

                      // Student Filter / Search Input
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search students by name or email...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.white38),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 20),

                      // Student Attendance List
                      const SectionHeader(
                        title: 'Student Roster & Risk Levels',
                        icon: Icons.format_list_bulleted_rounded,
                      ),

                      if (filteredStudents.isEmpty)
                        const EmptyStateWidget(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'No Risk Students Found',
                          subtitle: 'All enrolled students meet target attendance criteria.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStudents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            final isCritical = student.attendancePercentage < 60;
                            final color = isCritical ? AppTheme.errorRed : AppTheme.warningOrange;

                            return GradientCard(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: color.withValues(alpha: 0.2),
                                    child: Text(
                                      student.name.isNotEmpty ? student.name[0] : 'S',
                                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          student.email,
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: color.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      '${student.attendancePercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: Duration(milliseconds: 60 * index));
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
