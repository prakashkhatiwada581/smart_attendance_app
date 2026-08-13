import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/attendance_record.dart';
import '../../utils/theme.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/section_header.dart';

class StudentReportsScreen extends StatelessWidget {
  const StudentReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final dbService = context.read<DatabaseService>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Attendance Analytics'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const EmptyStateWidget(
              icon: Icons.person_off_rounded,
              title: 'Not Logged In',
              subtitle: 'Please sign in to view your reports',
            )
          : StreamBuilder<List<AttendanceRecord>>(
              stream: dbService.getStudentAttendance(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.analytics_outlined,
                    title: 'No Records Found',
                    subtitle: 'Your attendance records will appear here once you scan class QR codes.',
                  );
                }

                final records = snapshot.data!;
                
                // Group by weekday (1 = Mon, 7 = Sun)
                Map<int, int> attendanceByWeekday = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
                for (var record in records) {
                  int day = record.timestamp.weekday;
                  attendanceByWeekday[day] = (attendanceByWeekday[day] ?? 0) + 1;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Weekly Activity Bar Chart Header
                      const SectionHeader(
                        title: 'Weekly Attendance Outline',
                        icon: Icons.bar_chart_rounded,
                      ),
                      
                      GradientCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 10,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                          int index = value.toInt() - 1;
                                          if (index >= 0 && index < days.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                days[index],
                                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: true, interval: 2, reservedSize: 28),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: attendanceByWeekday.entries.map((entry) {
                                    return BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.toDouble(),
                                          gradient: AppTheme.primaryGradient,
                                          width: 18,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                          ),
                                        )
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),

                      const SizedBox(height: 28),

                      // Attendance Summary Breakdown Card
                      const SectionHeader(
                        title: 'Overall Status Ratio',
                        icon: Icons.pie_chart_outline_rounded,
                      ),
                      
                      GradientCard(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 28,
                                  sections: [
                                    PieChartSectionData(
                                      color: AppTheme.successGreen,
                                      value: user.attendancePercentage,
                                      title: '${user.attendancePercentage.toInt()}%',
                                      radius: 20,
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    PieChartSectionData(
                                      color: AppTheme.errorRed.withValues(alpha: 0.8),
                                      value: (100 - user.attendancePercentage).clamp(0, 100),
                                      title: '',
                                      radius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLegendItem(AppTheme.successGreen, "Attended Classes", "${records.length} sessions"),
                                  const SizedBox(height: 10),
                                  _buildLegendItem(
                                    AppTheme.accentBlue,
                                    "Target Goal",
                                    "75.0% Minimum",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 28),

                      // Attendance Logs List
                      const SectionHeader(
                        title: 'Detailed Session Logs',
                        icon: Icons.history_rounded,
                      ),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return GradientCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Class Attendance Marked',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat.yMMMMd().add_jm().format(record.timestamp),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successGreen.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'PRESENT',
                                    style: TextStyle(
                                      color: AppTheme.successGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 80 * index));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLegendItem(Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
