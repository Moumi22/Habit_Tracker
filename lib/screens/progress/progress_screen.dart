import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';

import '../../models/habit_model.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedTimeframe = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    if (authProvider.currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final overallStats = habitProvider.getOverallStats();
    final categoryStats = habitProvider.getCategoryStats();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Progress & Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFF06B6D4),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    // Timeframe selector
                    Positioned(
                      top: 100,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              _selectedTimeframe = value;
                            });
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'week',
                                  child: Text('This Week'),
                                ),
                                const PopupMenuItem(
                                  value: 'month',
                                  child: Text('This Month'),
                                ),
                                const PopupMenuItem(
                                  value: 'year',
                                  child: Text('This Year'),
                                ),
                              ],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getTimeframeText(_selectedTimeframe),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Progress Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // First row of stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernStatsCard(
                                context,
                                'Total Habits',
                                overallStats['totalHabits'].toString(),
                                Icons.dashboard_outlined,
                                const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernStatsCard(
                                context,
                                'Completion Rate',
                                '${overallStats['completionRate'].toStringAsFixed(1)}%',
                                Icons.analytics_outlined,
                                const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Second row of stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernStatsCard(
                                context,
                                'Total Streak',
                                overallStats['totalStreak'].toString(),
                                Icons.local_fire_department_outlined,
                                const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernStatsCard(
                                context,
                                'Completed Today',
                                '${overallStats['completedToday']}/${overallStats['totalHabits']}',
                                Icons.check_circle_outline,
                                const Color(0xFF8B5CF6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Progress Chart Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress Over Time',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Modern Chart Container
                        Container(
                          height: 320,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _buildModernProgressChart(),
                        ),
                      ],
                    ),
                  ),

                  // Category Progress Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress by Category',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Modern Category Cards
                        ...categoryStats.entries.map((entry) {
                          final category = entry.key;
                          final stats = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: _buildModernCategoryCard(
                              context,
                              category.displayName,
                              '${stats['completedToday']}/${stats['totalHabits']}',
                              'Completed today',
                              stats['totalHabits'] > 0
                                  ? stats['completedToday'] /
                                      stats['totalHabits']
                                  : 0.0,
                              _getCategoryIcon(category),
                              _getCategoryColor(category),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernProgressChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 60),
              const FlSpot(1, 80),
              const FlSpot(2, 70),
              const FlSpot(3, 90),
              const FlSpot(4, 85),
              const FlSpot(5, 95),
              const FlSpot(6, 88),
            ],
            isCurved: true,
            color: const Color(0xFF06B6D4),
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: const Color(0xFF06B6D4),
                  strokeWidth: 3,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF06B6D4).withOpacity(0.3),
                  const Color(0xFF06B6D4).withOpacity(0.05),
                ],
              ),
            ),
          ),
        ],
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
      ),
    );
  }

  Widget _buildModernStatsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategoryCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),

              const SizedBox(width: 16),

              // Title and Value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeframeText(String timeframe) {
    switch (timeframe) {
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return 'This Week';
    }
  }

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Icons.health_and_safety;
      case HabitCategory.study:
        return Icons.school;
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.productivity:
        return Icons.work;
      case HabitCategory.mentalHealth:
        return Icons.psychology;
      case HabitCategory.others:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return const Color(0xFF10B981); // Emerald
      case HabitCategory.study:
        return const Color(0xFF3B82F6); // Blue
      case HabitCategory.fitness:
        return const Color(0xFFF59E0B); // Amber
      case HabitCategory.productivity:
        return const Color(0xFF8B5CF6); // Violet
      case HabitCategory.mentalHealth:
        return const Color(0xFF06B6D4); // Cyan
      case HabitCategory.others:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
