import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/bird_class.dart';
import '../services/data_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = DataService.getStatistics();
      final dailyCount = DataService.getClassificationsByDay();
      final weeklyCount = DataService.getClassificationsByWeek();

      setState(() {
        _statistics = {
          'birdStats': stats,
          'dailyCount': dailyCount,
          'weeklyCount': weeklyCount,
          'totalClassifications': DataService.getTotalClassifications(),
          'mostClassified': DataService.getMostClassifiedBird(),
          'averageConfidence': DataService.getAverageConfidence(),
          'topBirds': DataService.getTopBirds(5),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/img/Gemini_Generated_Image_4h2abv4h2abv4h2a (1).png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Statistics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32), // Deep green from logo
        foregroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background with gradient matching logo colors (same as homepage)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  const Color(0xFF2E7D32), // Deep green
                  const Color(0xFF1976D2), // Blue
                  const Color(0xFF00ACC1), // Cyan/Teal
                ],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 20),
                        _buildBirdClassificationChart(),
                        const SizedBox(height: 20),
                        _buildDailyActivityChart(),
                        const SizedBox(height: 20),
                        _buildTopBirdsList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Classifications',
                '${_statistics['totalClassifications'] ?? 0}',
                Icons.camera_alt,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Most Classified',
                '${_statistics['mostClassified'] ?? 'None'}',
                Icons.favorite,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Avg Confidence',
                '${((_statistics['averageConfidence'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Unique Birds',
                '${(_statistics['birdStats'] as Map).length}',
                Icons.category,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withOpacity(0.2),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirdClassificationChart() {
    final birdStats = _statistics['birdStats'] as Map<String, dynamic>? ?? {};

    if (birdStats.isEmpty) {
      return _buildEmptyChart('No bird classification data available');
    }

    final data = birdStats.entries.map((entry) {
      final birdClass = birdClasses.firstWhere(
        (bird) => bird.name.toLowerCase() == entry.key.toLowerCase(),
        orElse: () => birdClasses[0],
      );
      return BarChartGroupData(
        x: birdClasses.indexOf(birdClass),
        barRods: [
          BarChartRodData(
            toY: entry.value.classificationCount.toDouble(),
            color: Colors.green[600],
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Text(
              'Bird Classifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    birdStats.values
                        .map((e) => e.classificationCount)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.grey[800]!,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final birdClass = birdClasses[group.x.toInt()];
                      return BarTooltipItem(
                        '${birdClass.name}\n${rod.toY.toInt()} classifications',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= birdClasses.length)
                          return const SizedBox();
                        final birdClass = birdClasses[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            birdClass.name.length > 8
                                ? '${birdClass.name.substring(0, 6)}...'
                                : birdClass.name,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyActivityChart() {
    final dailyCount = _statistics['dailyCount'] as Map<String, int>? ?? {};

    if (dailyCount.isEmpty) {
      return _buildEmptyChart('No daily activity data available');
    }

    final sortedDays = dailyCount.keys.toList()..sort();
    final maxCount = dailyCount.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Text(
              'Daily Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedDays.length)
                          return const SizedBox();
                        final dateStr = sortedDays[value.toInt()];
                        final date = DateTime.parse(dateStr);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM dd').format(date),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedDays.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        dailyCount[entry.value]?.toDouble() ?? 0.0,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue[600],
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue[100]!,
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxCount.toDouble() * 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBirdsList() {
    final topBirds = _statistics['topBirds'] as List? ?? [];

    if (topBirds.isEmpty) {
      return _buildEmptyChart('No bird statistics available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Text(
              'Top Classified Birds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...topBirds.asMap().entries.map((entry) {
            final index = entry.key;
            final birdStat = entry.value;
            final birdClass = birdClasses.firstWhere(
              (bird) =>
                  bird.name.toLowerCase() == birdStat.birdName.toLowerCase(),
              orElse: () => birdClasses[0],
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: index < 3
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      border: Border.all(
                        color: index < 3
                            ? Colors.orange.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: index < 3
                              ? Colors.orange[800]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundImage: AssetImage(birdClass.imagePath),
                    radius: 20,
                    backgroundColor: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          birdClass.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${birdStat.classificationCount} classifications',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: birdStat.averageConfidence > 0.5
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          border: Border.all(
                            color: birdStat.averageConfidence > 0.5
                                ? Colors.green.withOpacity(0.5)
                                : Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '${(birdStat.averageConfidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: birdStat.averageConfidence > 0.5
                                ? Colors.green[800]
                                : Colors.orange[800],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'avg confidence',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
