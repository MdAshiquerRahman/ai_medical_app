import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/health_report.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';

abstract class HealthReportRepository {
  /// Generates a comprehensive health report based on diagnosis and patient information
  Future<Result<HealthReport>> generateReport({
    required DiagnosisResult diagnosis,
    required PatientInfo patientInfo,
  });
}
