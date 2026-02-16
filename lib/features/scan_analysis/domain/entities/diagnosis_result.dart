import 'package:flutter/foundation.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';

@immutable
class DiagnosisResult {
  final ScanType scanType;
  final String predictedClass;
  final double confidence;
  final Map<String, double> allProbabilities;
  final Duration processingTime;
  final DateTime timestamp;

  const DiagnosisResult({
    required this.scanType,
    required this.predictedClass,
    required this.confidence,
    required this.allProbabilities,
    required this.processingTime,
    required this.timestamp,
  });

  double get confidencePercentage => confidence * 100;

  bool get isHighConfidence => confidence > 0.8;

  String get confidenceLevel {
    if (confidence > 0.9) return 'Very High';
    if (confidence > 0.7) return 'High';
    if (confidence > 0.5) return 'Moderate';
    return 'Low';
  }

  Map<String, dynamic> toMap() {
    return {
      'scanType': scanType.displayName,
      'predictedClass': predictedClass,
      'confidence': confidencePercentage.toStringAsFixed(2),
      'confidenceLevel': confidenceLevel,
      'allProbabilities': allProbabilities.map(
        (key, value) => MapEntry(key, value.toStringAsFixed(2)),
      ),
      'processingTime': '${processingTime.inMilliseconds}ms',
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
