import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/classification_history.dart';
import '../models/bird_class.dart';

class DataService {
  static const String _historyKey = 'classification_history';
  static const String _statisticsKey = 'bird_statistics';

  static List<ClassificationHistory> _history = [];
  static Map<String, BirdStatistics> _statistics = {};

  static Future<void> initialize() async {
    await _loadHistory();
    await _loadStatistics();
  }

  static Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        _history = historyList
            .map((json) => ClassificationHistory.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading history: $e');
      _history = [];
    }
  }

  static Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statisticsKey);

      if (statsJson != null) {
        final Map<String, dynamic> statsMap = jsonDecode(statsJson);
        _statistics = statsMap.map(
          (key, value) => MapEntry(key, BirdStatistics.fromJson(value)),
        );
      } else {
        // Initialize statistics for all bird classes
        _initializeStatistics();
      }
    } catch (e) {
      print('Error loading statistics: $e');
      _initializeStatistics();
    }
  }

  static void _initializeStatistics() {
    _statistics = {};
    for (final birdClass in birdClasses) {
      _statistics[birdClass.name] = BirdStatistics(
        birdName: birdClass.name,
        lastClassified: DateTime.now(),
      );
    }
  }

  static Future<void> saveClassification({
    required String imagePath,
    required String predictedBird,
    required double confidence,
    required Map<String, double> allPredictions,
  }) async {
    final historyItem = ClassificationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      timestamp: DateTime.now(),
      predictedBird: predictedBird,
      confidence: confidence,
      allPredictions: allPredictions,
    );

    _history.insert(0, historyItem); // Add to beginning of list

    // Update statistics
    if (_statistics.containsKey(predictedBird)) {
      _statistics[predictedBird]!.addClassification(confidence);
    } else {
      _statistics[predictedBird] = BirdStatistics(
        birdName: predictedBird,
        classificationCount: 1,
        totalConfidence: confidence,
        lastClassified: DateTime.now(),
      );
    }

    await _saveHistory();
    await _saveStatistics();
  }

  static Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _history.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  static Future<void> _saveStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(
        _statistics.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_statisticsKey, statsJson);
    } catch (e) {
      print('Error saving statistics: $e');
    }
  }

  static List<ClassificationHistory> getHistory() {
    return List.unmodifiable(_history);
  }

  static Map<String, BirdStatistics> getStatistics() {
    return Map.unmodifiable(_statistics);
  }

  static List<BirdStatistics> getTopBirds(int count) {
    final sortedBirds = _statistics.values.toList()
      ..sort((a, b) => b.classificationCount.compareTo(a.classificationCount));

    return sortedBirds.take(count).toList();
  }

  static int getTotalClassifications() {
    return _history.length;
  }

  static String getMostClassifiedBird() {
    if (_statistics.isEmpty) return 'None';

    return _statistics.values
        .reduce((a, b) => a.classificationCount > b.classificationCount ? a : b)
        .birdName;
  }

  static double getAverageConfidence() {
    if (_history.isEmpty) return 0.0;

    final totalConfidence = _history.fold<double>(
      0.0,
      (sum, item) => sum + item.confidence,
    );

    return totalConfidence / _history.length;
  }

  static Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
  }

  static Future<void> clearStatistics() async {
    _initializeStatistics();
    await _saveStatistics();
  }

  static Map<String, int> getClassificationsByDay() {
    final Map<String, int> dailyCount = {};

    for (final item in _history) {
      final dayKey = DateFormat('yyyy-MM-dd').format(item.timestamp);
      dailyCount[dayKey] = (dailyCount[dayKey] ?? 0) + 1;
    }

    return dailyCount;
  }

  static Map<String, int> getClassificationsByWeek() {
    final Map<String, int> weeklyCount = {};

    for (final item in _history) {
      final weekKey = _getWeekKey(item.timestamp);
      weeklyCount[weekKey] = (weeklyCount[weekKey] ?? 0) + 1;
    }

    return weeklyCount;
  }

  static String _getWeekKey(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return DateFormat('MMM dd').format(firstDayOfWeek);
  }
}
