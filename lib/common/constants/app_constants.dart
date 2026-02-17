class AppConstants {
  AppConstants._();

  static const int maxImageSizeMB = 10;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;

  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  static const int minImageWidth = 100;
  static const int minImageHeight = 100;

  static const int inferenceTimeoutSeconds = 30;

  static const double highConfidenceThreshold = 0.8;
  static const double moderateConfidenceThreshold = 0.5;
}
