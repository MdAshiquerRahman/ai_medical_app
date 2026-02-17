import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ai_medical_app/features/health_report/domain/services/ai_report_service.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/common/constants/gemini_constants.dart';

class GeminiAIService implements AIReportService {
  final String _apiKey;
  GenerativeModel? _model;

  GeminiAIService({required String apiKey}) : _apiKey = apiKey;

  GenerativeModel _getModel({String? systemInstruction}) {
    return GenerativeModel(
      model: GeminiConstants.modelName,
      apiKey: _apiKey,
      systemInstruction: systemInstruction != null
          ? Content.system(systemInstruction)
          : null,
      generationConfig: GenerationConfig(
        temperature: GeminiConstants.temperature,
        maxOutputTokens: GeminiConstants.maxOutputTokens,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
  }

  @override
  Future<Result<String>> generateHealthReport({
    required String prompt,
    String? systemInstruction,
  }) async {
    try {
      _model = _getModel(systemInstruction: systemInstruction);

      final content = [Content.text(prompt)];

      final response = await _model!
          .generateContent(content)
          .timeout(GeminiConstants.timeout);

      if (response.text == null || response.text!.isEmpty) {
        return const Failure('Empty response from AI service');
      }

      final responseText = response.text!.trim();

      return Success(responseText);
    } on TimeoutException {
      return const Failure(
        'Request timed out. Please check your internet connection and try again.',
      );
    } on GenerativeAIException catch (e) {
      return Failure('AI service error: ${e.message}');
    } catch (e) {
      return Failure('Failed to generate health report: $e');
    }
  }

  @override
  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'your_api_key_here';
}
