import 'package:ai_medical_app/features/health_report/domain/repositories/health_report_repository.dart';
import 'package:ai_medical_app/features/health_report/domain/services/ai_report_service.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/health_report.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';
import 'package:ai_medical_app/features/health_report/data/utils/health_report_prompt_builder.dart';
import 'package:ai_medical_app/features/health_report/data/utils/health_report_parser.dart';
import 'package:ai_medical_app/common/errors/result.dart';

class HealthReportRepositoryImpl implements HealthReportRepository {
  final AIReportService _aiService;

  HealthReportRepositoryImpl({required AIReportService aiService})
    : _aiService = aiService;

  @override
  Future<Result<HealthReport>> generateReport({
    required DiagnosisResult diagnosis,
    required PatientInfo patientInfo,
  }) async {
    try {
      // Check if AI service is configured
      if (!_aiService.isConfigured) {
        return const Failure(
          'AI service is not configured. Please check API key.',
        );
      }

      // Build prompts from diagnosis and patient info
      final systemInstruction =
          HealthReportPromptBuilder.buildSystemInstruction();
      final userPrompt = HealthReportPromptBuilder.buildUserPrompt(
        diagnosis: diagnosis,
        patientInfo: patientInfo,
        scanType: diagnosis.scanType,
      );

      // Generate report using AI service
      final result = await _aiService.generateHealthReport(
        prompt: userPrompt,
        systemInstruction: systemInstruction,
      );

      // Handle AI service result
      return result.fold(
        onSuccess: (rawResponse) {
          try {
            // Parse and validate the response
            final healthReport = HealthReportParser.parseAndValidate(
              rawResponse,
            );
            return Success(healthReport);
          } on HealthReportParseException catch (e) {
            return Failure('Failed to parse AI response: ${e.message}', e);
          } on HealthReportValidationException catch (e) {
            return Failure('Invalid AI response: ${e.message}', e);
          } catch (e) {
            return Failure('Unexpected error while processing response: $e');
          }
        },
        onFailure: (message, exception) {
          return Failure(message, exception);
        },
      );
    } catch (e) {
      return Failure('Failed to generate report: $e');
    }
  }
}

// Extension to handle Result pattern more elegantly
extension ResultExtension<T> on Result<T> {
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Exception? exception) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else if (this is Failure<T>) {
      final failure = this as Failure<T>;
      return onFailure(failure.message, failure.exception);
    }
    throw Exception('Unknown Result type');
  }
}
