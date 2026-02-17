import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/health_report.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final ScanType scanType;
  final DiagnosisResult diagnosisResult;
  final PatientInfo? patientInfo;
  final HealthReport? healthReport;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.scanType,
    required this.diagnosisResult,
    this.patientInfo,
    this.healthReport,
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
    final severity = widget.healthReport?.severity.label ?? _getSeverity();
    final severityColor =
        widget.healthReport?.severity.color ?? _getSeverityColor(severity);
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

                // Health Report sections (if available) or fallback to simple sections
                if (widget.healthReport != null) ...[
                  _buildHealthReportSections(),
                ] else ...[
                  // Findings section (fallback)
                  _buildSection('Findings', Icons.assignment, findings),
                  const SizedBox(height: 20),
                  // Recommendations section (fallback)
                  _buildSection(
                    'Recommendations',
                    Icons.lightbulb_outline,
                    recommendations,
                  ),
                  const SizedBox(height: 20),
                ],

                // Disclaimer
                widget.healthReport != null
                    ? _buildAIDisclaimer(widget.healthReport!.disclaimer)
                    : _buildDisclaimer(),

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

  Widget _buildHealthReportSections() {
    final report = widget.healthReport!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Condition Analysis Section
        _buildExpandableSection(
          title: 'Condition Analysis',
          icon: Icons.medical_information,
          iconColor: const Color(0xFF2196F3),
          children: [
            _buildInfoRow('Condition', report.conditionName, bold: true),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Severity',
              report.severity.label,
              labelColor: report.severity.color,
            ),
            const SizedBox(height: 12),
            _buildSubSection('Description', [report.conditionDescription]),
            if (report.severityExplanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSubSection('Severity Explanation', [
                report.severityExplanation,
              ]),
            ],
            if (report.causes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSubSection('Possible Causes', report.causes),
            ],
            if (report.progression.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSubSection('Progression', [report.progression]),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Treatment Guidelines Section
        if (report.medications.isNotEmpty ||
            report.treatmentSteps.isNotEmpty ||
            report.homeCare.isNotEmpty)
          _buildExpandableSection(
            title: 'Treatment Guidelines',
            icon: Icons.healing,
            iconColor: const Color(0xFF4CAF50),
            children: [
              if (report.medications.isNotEmpty) ...[
                _buildSubSection('Recommended Medications', []),
                const SizedBox(height: 8),
                ...report.medications.map((med) => _buildMedicationCard(med)),
                const SizedBox(height: 12),
                _buildMedicationDisclaimer(),
                const SizedBox(height: 12),
              ],
              if (report.treatmentSteps.isNotEmpty) ...[
                _buildSubSection('Treatment Steps', report.treatmentSteps),
                const SizedBox(height: 12),
              ],
              if (report.homeCare.isNotEmpty)
                _buildSubSection('Home Care', report.homeCare),
            ],
          ),

        const SizedBox(height: 16),

        // Lifestyle Recommendations Section
        if (report.lifestyleModifications.isNotEmpty ||
            report.dietRecommendations.isNotEmpty ||
            report.exerciseGuidelines.isNotEmpty ||
            report.restAdvice.isNotEmpty)
          _buildExpandableSection(
            title: 'Lifestyle Recommendations',
            icon: Icons.favorite,
            iconColor: const Color(0xFFFF9800),
            children: [
              if (report.lifestyleModifications.isNotEmpty) ...[
                _buildSubSection(
                  'Lifestyle Modifications',
                  report.lifestyleModifications,
                ),
                const SizedBox(height: 12),
              ],
              if (report.dietRecommendations.isNotEmpty) ...[
                _buildSubSection(
                  'Diet Recommendations',
                  report.dietRecommendations,
                ),
                const SizedBox(height: 12),
              ],
              if (report.exerciseGuidelines.isNotEmpty) ...[
                _buildSubSection(
                  'Exercise Guidelines',
                  report.exerciseGuidelines,
                ),
                const SizedBox(height: 12),
              ],
              if (report.restAdvice.isNotEmpty)
                _buildSubSection('Rest & Recovery', report.restAdvice),
            ],
          ),

        const SizedBox(height: 16),

        // Specialist Recommendation Section
        if (report.specialist.type.isNotEmpty)
          _buildExpandableSection(
            title: 'Specialist Recommendation',
            icon: Icons.local_hospital,
            iconColor: const Color(0xFF9C27B0),
            children: [
              _buildInfoRow('Specialist Type', report.specialist.type),
              const SizedBox(height: 8),
              _buildInfoRow('Expertise', report.specialist.expertise),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Urgency',
                report.specialist.urgency,
                labelColor: _getUrgencyColor(report.specialist.urgency),
              ),
              if (report.nearbyFacilities.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSubSection('Recommended Facilities', []),
                const SizedBox(height: 8),
                ...report.nearbyFacilities.map(
                  (facility) => _buildFacilityCard(facility),
                ),
              ],
            ],
          ),

        const SizedBox(height: 16),

        // Warning Signs Section
        if (report.redFlags.isNotEmpty || report.emergencySymptoms.isNotEmpty)
          _buildWarningSection(
            title: 'Warning Signs',
            icon: Icons.warning_amber,
            redFlags: report.redFlags,
            emergencySymptoms: report.emergencySymptoms,
          ),

        const SizedBox(height: 16),

        // Follow-up Section
        if (report.followUpTimeline.isNotEmpty ||
            report.followUpSchedule.isNotEmpty)
          _buildExpandableSection(
            title: 'Follow-up Schedule',
            icon: Icons.event_note,
            iconColor: const Color(0xFF00BCD4),
            children: [
              if (report.followUpTimeline.isNotEmpty) ...[
                _buildInfoRow('Timeline', report.followUpTimeline),
                const SizedBox(height: 12),
              ],
              if (report.followUpSchedule.isNotEmpty)
                _buildSubSection('Schedule', report.followUpSchedule),
            ],
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Icon(icon, color: iconColor, size: 24),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white70,
          children: children,
        ),
      ),
    );
  }

  Widget _buildWarningSection({
    required String title,
    required IconData icon,
    required List<String> redFlags,
    required List<String> emergencySymptoms,
  }) {
    return Card(
      color: const Color(0xFFDC143C).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFDC143C).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Icon(icon, color: const Color(0xFFDC143C), size: 24),
          title: const Text(
            'Warning Signs',
            style: TextStyle(
              color: Color(0xFFDC143C),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconColor: const Color(0xFFDC143C),
          collapsedIconColor: const Color(0xFFDC143C),
          children: [
            if (redFlags.isNotEmpty) ...[
              _buildSubSection(
                'Red Flags',
                redFlags,
                iconColor: const Color(0xFFDC143C),
              ),
              if (emergencySymptoms.isNotEmpty) const SizedBox(height: 16),
            ],
            if (emergencySymptoms.isNotEmpty)
              _buildSubSection(
                'Emergency Symptoms - Seek Immediate Care',
                emergencySymptoms,
                iconColor: const Color(0xFFFF5252),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(
    String title,
    List<String> items, {
    Color? iconColor,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: iconColor ?? const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool bold = false,
    Color? labelColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: labelColor ?? Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(medication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, color: Color(0xFF4CAF50), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  medication.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMedicationDetail('Dosage', medication.dosage),
          _buildMedicationDetail('Frequency', medication.frequency),
          _buildMedicationDetail('Duration', medication.duration),
        ],
      ),
    );
  }

  Widget _buildMedicationDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF9800),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Do not consume these medications before consulting with a qualified healthcare expert. This is AI-generated advice for informational purposes only.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(facility) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getFacilityIcon(facility.type),
                color: const Color(0xFF9C27B0),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  facility.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (facility.address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    facility.address,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          if (facility.specialization.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Colors.white54,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    facility.specialization,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          if (facility.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.white54, size: 16),
                const SizedBox(width: 4),
                Text(
                  facility.phone,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getFacilityIcon(facilityType) {
    final type = facilityType.toString().toLowerCase();
    if (type.contains('hospital')) return Icons.local_hospital;
    if (type.contains('clinic')) return Icons.local_pharmacy;
    if (type.contains('emergency')) return Icons.emergency;
    return Icons.medical_services;
  }

  Color _getUrgencyColor(String urgency) {
    final lower = urgency.toLowerCase();
    if (lower.contains('immediate') || lower.contains('urgent')) {
      return const Color(0xFFFF5252);
    } else if (lower.contains('soon')) {
      return const Color(0xFFFF9800);
    }
    return const Color(0xFF4CAF50);
  }

  Widget _buildAIDisclaimer(String customDisclaimer) {
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
            const Icon(Icons.info_outline, color: Color(0xFFDC143C), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI-Generated Health Report',
                    style: TextStyle(
                      color: Color(0xFFDC143C),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customDisclaimer,
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
