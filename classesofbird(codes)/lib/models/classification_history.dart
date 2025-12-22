class ClassificationHistory {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final String predictedBird;
  final double confidence;
  final Map<String, double> allPredictions;

  ClassificationHistory({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.predictedBird,
    required this.confidence,
    required this.allPredictions,
  });

  factory ClassificationHistory.fromJson(Map<String, dynamic> json) {
    return ClassificationHistory(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      predictedBird: json['predictedBird'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      allPredictions: Map<String, double>.from(
        (json['allPredictions'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'predictedBird': predictedBird,
      'confidence': confidence,
      'allPredictions': allPredictions,
    };
  }
}

class BirdStatistics {
  final String birdName;
  int classificationCount;
  double totalConfidence;
  DateTime lastClassified;

  BirdStatistics({
    required this.birdName,
    this.classificationCount = 0,
    this.totalConfidence = 0.0,
    required this.lastClassified,
  });

  double get averageConfidence =>
      classificationCount > 0 ? totalConfidence / classificationCount : 0.0;

  factory BirdStatistics.fromJson(Map<String, dynamic> json) {
    return BirdStatistics(
      birdName: json['birdName'] as String,
      classificationCount: json['classificationCount'] as int? ?? 0,
      totalConfidence: (json['totalConfidence'] as num?)?.toDouble() ?? 0.0,
      lastClassified: DateTime.parse(json['lastClassified'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birdName': birdName,
      'classificationCount': classificationCount,
      'totalConfidence': totalConfidence,
      'lastClassified': lastClassified.toIso8601String(),
    };
  }

  void addClassification(double confidence) {
    classificationCount++;
    totalConfidence += confidence;
    lastClassified = DateTime.now();
  }
}
