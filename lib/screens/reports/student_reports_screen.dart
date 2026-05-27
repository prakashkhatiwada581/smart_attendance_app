import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/attendance_record.dart';
import 'package:intl/intl.dart';

class StudentReportsScreen extends StatelessWidget {
  const StudentReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Reports')),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<List<AttendanceRecord>>(
              stream: dbService.getStudentAttendance(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No attendance records found.'));
                }

                final records = snapshot.data!;
                
                // Group by day for simple bar chart representation
                Map<int, int> attendanceByWeekday = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
                for (var record in records) {
                  attendanceByWeekday[record.timestamp.weekday] = (attendanceByWeekday[record.timestamp.weekday] ?? 0) + 1;
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Weekly Attendance Outline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 10,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                    return Text(days[value.toInt() - 1]);
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: true, interval: 2),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: attendanceByWeekday.entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    color: Theme.of(context).primaryColor,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text('Recent Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: const Text('Present'),
                              subtitle: Text(DateFormat.yMMMd().add_jm().format(record.timestamp)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
