import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final ScanType scanType;
  final DiagnosisResult diagnosisResult;
  final PatientInfo? patientInfo;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.scanType,
    required this.diagnosisResult,
    this.patientInfo,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _getSeverity() {
    final confidence = widget.diagnosisResult.confidence;
    final predictedClass = widget.diagnosisResult.predictedClass.toLowerCase();

    // For normal cases
    if (predictedClass.contains('normal') ||
        predictedClass.contains('notumor')) {
      return 'Low';
    }

    // Based on confidence level
    if (confidence > 0.85) return 'High';
    if (confidence > 0.65) return 'Moderate';
    return 'Low';
  }

  List<String> _getFindings() {
    final result = widget.diagnosisResult;
    final findings = <String>[
      'Detected: ${result.predictedClass}',
      'Confidence Level: ${result.confidenceLevel}',
      'Processing Time: ${result.processingTime.inMilliseconds}ms',
    ];

    // Add probability details for top predictions
    final sortedProbs = result.allProbabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedProbs.length > 1) {
      findings.add('Alternative possibilities:');
      for (var i = 1; i < sortedProbs.length && i < 3; i++) {
        findings.add(
          '  • ${sortedProbs[i].key}: ${(sortedProbs[i].value * 100).toStringAsFixed(1)}%',
        );
      }
    }

    return findings;
  }

  List<String> _getRecommendations() {
    final predictedClass = widget.diagnosisResult.predictedClass.toLowerCase();
    final isHighConfidence = widget.diagnosisResult.isHighConfidence;

    final recommendations = <String>[
      'Consult with a qualified healthcare professional for proper diagnosis',
      'This AI analysis is for informational purposes only',
    ];

    // Add specific recommendations based on scan type and result
    if (isHighConfidence) {
      if (predictedClass.contains('normal') ||
          predictedClass.contains('notumor')) {
        recommendations.insert(0, 'Results suggest normal findings');
        recommendations.insert(1, 'Continue regular health monitoring');
      } else {
        recommendations.insert(
          0,
          'Abnormality detected - seek medical attention',
        );
        recommendations.insert(1, 'Schedule an appointment with a specialist');
      }
    } else {
      recommendations.insert(
        0,
        'Results are inconclusive - professional evaluation recommended',
      );
      recommendations.insert(
        1,
        'Consider retaking the scan with better image quality',
      );
    }

    return recommendations;
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning;
      case 'high':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: _buildResultsView(),
    );
  }

  Widget _buildResultsView() {
    final diagnosisResult = widget.diagnosisResult;
    final severity = _getSeverity();
    final severityColor = _getSeverityColor(severity);
    final findings = _getFindings();
    final recommendations = _getRecommendations();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview
          Container(
            height: 200,
            color: Colors.black,
            child: Image.file(widget.imageFile, fit: BoxFit.contain),
          ),

          // Scan type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                Icon(
                  _getScanTypeIcon(),
                  color: const Color(0xFFDC143C),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.scanType.displayName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'Confidence: ${diagnosisResult.confidencePercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Diagnosis card
                Card(
                  color: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: severityColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getSeverityIcon(severity),
                                    color: severityColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    severity,
                                    style: TextStyle(
                                      color: severityColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          diagnosisResult.predictedClass,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Patient Demographics section (if available)
                if (widget.patientInfo != null) ...[
                  _buildPatientDemographics(),
                  const SizedBox(height: 20),
                ],

                // Findings section
                _buildSection('Findings', Icons.assignment, findings),

                const SizedBox(height: 20),

                // Recommendations section
                _buildSection(
                  'Recommendations',
                  Icons.lightbulb_outline,
                  recommendations,
                ),

                const SizedBox(height: 20),

                // Disclaimer
                _buildDisclaimer(),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('New Scan'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to history
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saved to history'),
                              backgroundColor: Color(0xFFDC143C),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC143C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getScanTypeIcon() {
    switch (widget.scanType) {
      case ScanType.chestXRay:
        return Icons.medical_services;
      case ScanType.chestCTScan:
        return Icons.monitor_heart;
      case ScanType.mri:
        return Icons.psychology;
      case ScanType.skinLesion:
        return Icons.face_retouching_natural;
    }
  }

  Widget _buildSection(String title, IconData icon, List<dynamic> items) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFDC143C), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFFDC143C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDemographics() {
    final patient = widget.patientInfo!;
    final demographics = <String>[
      'Age: ${patient.age} years',
      'Gender: ${patient.gender}',
      'Weight: ${patient.weightDisplay}',
      'Height: ${patient.heightDisplay}',
      'Location: ${patient.location}',
      '',
      'Reported Symptoms:',
      patient.symptoms,
    ];

    if (patient.systolicBP != null || patient.diastolicBP != null) {
      demographics.add('');
      demographics.add('Vital Signs:');
      if (patient.systolicBP != null && patient.diastolicBP != null) {
        demographics.add(
          'Blood Pressure: ${patient.systolicBP}/${patient.diastolicBP} mmHg',
        );
      }
    }

    if (patient.temperature != null) {
      demographics.add('Temperature: ${patient.temperatureDisplay}');
    }

    if (patient.heartRate != null) {
      demographics.add('Heart Rate: ${patient.heartRate} bpm');
    }

    if (patient.medicalHistory != null && patient.medicalHistory!.isNotEmpty) {
      demographics.add('');
      demographics.add('Medical History:');
      demographics.add(patient.medicalHistory!);
    }

    if (patient.allergies != null && patient.allergies!.isNotEmpty) {
      demographics.add('');
      demographics.add('Known Allergies:');
      demographics.add(patient.allergies!);
    }

    if (patient.currentMedications != null &&
        patient.currentMedications!.isNotEmpty) {
      demographics.add('');
      demographics.add('Current Medications:');
      demographics.add(patient.currentMedications!);
    }

    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Patient Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...demographics.map((item) {
              final isHeader = item.endsWith(':') && !item.startsWith(' ');
              final isEmpty = item.trim().isEmpty;

              if (isEmpty) {
                return const SizedBox(height: 8);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  item,
                  style: TextStyle(
                    color: isHeader ? Colors.white : const Color(0xFFB0B0B0),
                    fontSize: isHeader ? 14 : 13,
                    fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Card(
      color: const Color(0xFFDC143C).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFDC143C).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFDC143C),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medical Disclaimer',
                    style: TextStyle(
                      color: Color(0xFFDC143C),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This AI analysis is for informational purposes only and should not replace professional medical advice. Please consult with a qualified healthcare provider for proper diagnosis and treatment.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.4,
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
}
