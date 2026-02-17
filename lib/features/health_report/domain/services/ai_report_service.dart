import 'package:ai_medical_app/common/errors/result.dart';

abstract class AIReportService {
  Future<Result<String>> generateHealthReport({
    required String prompt,
    String? systemInstruction,
  });

  bool get isConfigured;
}
