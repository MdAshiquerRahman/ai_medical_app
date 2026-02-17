import 'package:flutter/foundation.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/health_report.dart';

@immutable
class SavedReport {
  final String id;
  final String imagePath;
  final ScanType scanType;
  final DiagnosisResult diagnosisResult;
  final PatientInfo patientInfo;
  final HealthReport? healthReport;
  final DateTime timestamp;

  const SavedReport({
    required this.id,
    required this.imagePath,
    required this.scanType,
    required this.diagnosisResult,
    required this.patientInfo,
    this.healthReport,
    required this.timestamp,
  });

  SavedReport copyWith({
    String? id,
    String? imagePath,
    ScanType? scanType,
    DiagnosisResult? diagnosisResult,
    PatientInfo? patientInfo,
    HealthReport? healthReport,
    DateTime? timestamp,
  }) {
    return SavedReport(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      scanType: scanType ?? this.scanType,
      diagnosisResult: diagnosisResult ?? this.diagnosisResult,
      patientInfo: patientInfo ?? this.patientInfo,
      healthReport: healthReport ?? this.healthReport,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
