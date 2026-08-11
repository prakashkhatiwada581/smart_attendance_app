import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'qr_generator_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  // Mock data for teacher's subjects and attendance
  static const List<Map<String, dynamic>> mockSubjects = [
    {
      "subject": "Mathematics",
      "totalStudents": 45,
      "present": 40
    },
    {
      "subject": "Science",
      "totalStudents": 38,
      "present": 35
    },
    {
      "subject": "Computer",
      "totalStudents": 52,
      "present": 49
    },
    {
      "subject": "English",
      "totalStudents": 30,
      "present": 27
    }
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    // Calculate Summary Stats
    final int totalSubjects = mockSubjects.length;
    final int totalStudents = mockSubjects.fold<int>(0, (sum, item) => sum + (item['totalStudents'] as int));
    final int totalPresent = mockSubjects.fold<int>(0, (sum, item) => sum + (item['present'] as int));
    final int totalAbsent = totalStudents - totalPresent;

    // Layout helper to determine screen size
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome & Generate QR Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back,',
                            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'John Doe',
                            style: const TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Department / Course: ${user?.course.isNotEmpty == true ? user?.course : "Science & Tech"}',
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.qr_code_scanner, color: theme.primaryColor),
                      label: Text(
                        'Generate QR',
                        style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QRGeneratorScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Stats Grid
            GridView.count(
              crossAxisCount: isDesktop ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.0 : 1.3,
              children: [
                _buildSummaryCard(
                  context,
                  title: 'Total Subjects',
                  value: totalSubjects.toString(),
                  icon: Icons.book,
                  color: Colors.blue,
                ),
                _buildSummaryCard(
                  context,
                  title: 'Total Students',
                  value: totalStudents.toString(),
                  icon: Icons.people,
                  color: theme.primaryColor,
                ),
                _buildSummaryCard(
                  context,
                  title: 'Present Today',
                  value: totalPresent.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildSummaryCard(
                  context,
                  title: 'Absent Today',
                  value: totalAbsent.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section Header
            const Text(
              'Subjects & Attendance Graphical Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Subject Cards List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockSubjects.length,
              itemBuilder: (context, index) {
                final subjectData = mockSubjects[index];
                final String subjectName = subjectData['subject'];
                final int total = subjectData['totalStudents'];
                final int present = subjectData['present'];
                final int absent = total - present;
                final double attendancePercentage = (present / total) * 100;

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Subject Title & Student Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subjectName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$total Students',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Progress Indicator
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: present / total,
                                  backgroundColor: Colors.red.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${attendancePercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Responsive visualizer (Bar Chart and Pie Chart side-by-side or stacked)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final showHorizontal = constraints.maxWidth > 500;
                            return Flex(
                              direction: showHorizontal ? Axis.horizontal : Axis.vertical,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Stats Info block
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLegendItem('Total', total, Colors.blue),
                                      const SizedBox(height: 6),
                                      _buildLegendItem('Present', present, Colors.green),
                                      const SizedBox(height: 6),
                                      _buildLegendItem('Absent', absent, Colors.red),
                                    ],
                                  ),
                                ),
                                if (!showHorizontal) const SizedBox(height: 16),

                                // Bar Chart Widget
                                SizedBox(
                                  height: 120,
                                  width: 140,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: total.toDouble(),
                                      barGroups: [
                                        BarChartGroupData(
                                          x: 0,
                                          barRods: [
                                            BarChartRodData(
                                              toY: present.toDouble(),
                                              color: Colors.green,
                                              width: 16,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(6),
                                                topRight: Radius.circular(6),
                                              ),
                                            ),
                                          ],
                                        ),
                                        BarChartGroupData(
                                          x: 1,
                                          barRods: [
                                            BarChartRodData(
                                              toY: absent.toDouble(),
                                              color: Colors.red,
                                              width: 16,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(6),
                                                topRight: Radius.circular(6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      gridData: const FlGridData(show: false),
                                      borderData: FlBorderData(show: false),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              if (value == 0) {
                                                return const Text(
                                                  'Present',
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                );
                                              }
                                              if (value == 1) {
                                                return const Text(
                                                  'Absent',
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                );
                                              }
                                              return const SizedBox();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!showHorizontal) const SizedBox(height: 16),

                                // Donut/Pie Chart Widget
                                SizedBox(
                                  height: 120,
                                  width: 120,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      PieChart(
                                        PieChartData(
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 32,
                                          startDegreeOffset: -90,
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.green,
                                              value: present.toDouble(),
                                              title: '',
                                              radius: 12,
                                            ),
                                            PieChartSectionData(
                                              color: Colors.red,
                                              value: absent.toDouble(),
                                              title: '',
                                              radius: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${attendancePercentage.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            'Rate',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
