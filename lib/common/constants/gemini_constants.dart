class GeminiConstants {
  GeminiConstants._();

  static const String modelName = 'gemini-3-flash-preview';
  static const double temperature = 0.3;
  static const int maxOutputTokens = 4096;
  static const Duration timeout = Duration(seconds: 30);
}
