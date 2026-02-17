import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';

class DiagnosisDisplayCard extends StatelessWidget {
  final DiagnosisResult diagnosisResult;
  final ScanType scanType;

  const DiagnosisDisplayCard({
    super.key,
    required this.diagnosisResult,
    required this.scanType,
  });

  @override
  Widget build(BuildContext context) {
    final alternatives =
        diagnosisResult.allProbabilities.entries
            .where((e) => e.key != diagnosisResult.predictedClass)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      color: const Color(0xFF2C2C2C),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC143C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: Color(0xFFDC143C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scanType.displayName,
                        style: const TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'AI Diagnosis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Diagnosis Result
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFDC143C).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detected Condition:',
                    style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diagnosisResult.predictedClass,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(
                            diagnosisResult.confidence,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getConfidenceColor(
                              diagnosisResult.confidence,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getConfidenceIcon(diagnosisResult.confidence),
                              color: _getConfidenceColor(
                                diagnosisResult.confidence,
                              ),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Confidence: ${diagnosisResult.confidencePercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: _getConfidenceColor(
                                  diagnosisResult.confidence,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Alternative Predictions
            if (alternatives.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Alternative Possibilities:',
                style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...alternatives
                  .take(2)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fiber_manual_record,
                            size: 6,
                            color: Color(0xFF606060),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '${(entry.value * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Color(0xFF606060),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],

            const SizedBox(height: 16),

            // Info Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF4CAF50),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please provide your information for a comprehensive health report',
                      style: TextStyle(
                        color: const Color(0xFFB0B0B0),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return const Color(0xFF4CAF50); // Green
    if (confidence > 0.6) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence > 0.8) return Icons.check_circle;
    if (confidence > 0.6) return Icons.warning;
    return Icons.error;
  }
}
