import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/classification_history.dart';
import '../models/bird_class.dart';
import '../services/data_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ClassificationHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = DataService.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshHistory() async {
    await _loadHistory();
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all classification history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DataService.clearHistory();
      await _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('History cleared')));
      }
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
              'History',
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
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearHistory,
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
            child: RefreshIndicator(
              onRefresh: _refreshHistory,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _history.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No classification history yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start classifying birds to see your history here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final historyItem = _history[index];
        return _buildHistoryCard(historyItem);
      },
    );
  }

  Widget _buildHistoryCard(ClassificationHistory historyItem) {
    final birdClass = birdClasses.firstWhere(
      (bird) =>
          bird.name.toLowerCase() == historyItem.predictedBird.toLowerCase(),
      orElse: () => birdClasses[0],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(birdClass.imagePath),
          radius: 25,
          backgroundColor: Colors.white.withOpacity(0.8),
        ),
        title: Text(
          birdClass.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat(
                  'MMM dd, yyyy - HH:mm',
                ).format(historyItem.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: historyItem.confidence > 0.5
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  border: Border.all(
                    color: historyItem.confidence > 0.5
                        ? Colors.green.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '${(historyItem.confidence * 100).toStringAsFixed(1)}% Confidence',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: historyItem.confidence > 0.5
                        ? Colors.green[800]
                        : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
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
                  child: Text(
                    birdClass.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'All Predictions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                ...historyItem.allPredictions.entries.map((entry) {
                  final bird = birdClasses.firstWhere(
                    (b) => b.name.toLowerCase() == entry.key.toLowerCase(),
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
                        SizedBox(
                          width: 70,
                          child: Text(
                            bird.name.length > 8
                                ? '${bird.name.substring(0, 7)}...'
                                : bird.name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[300],
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: entry.value.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: entry.value > 0.5
                                      ? Colors.green[600]
                                      : Colors.orange[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 45,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: entry.value > 0.5
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                          ),
                          child: Text(
                            '${(entry.value * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: entry.value > 0.5
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
