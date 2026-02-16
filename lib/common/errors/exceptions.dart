class ModelNotLoadedException implements Exception {
  final String message;
  ModelNotLoadedException([this.message = 'Model not loaded']);

  @override
  String toString() => 'ModelNotLoadedException: $message';
}

class ImageProcessingException implements Exception {
  final String message;
  ImageProcessingException(this.message);

  @override
  String toString() => 'ImageProcessingException: $message';
}

class ImageValidationException implements Exception {
  final String message;
  ImageValidationException(this.message);

  @override
  String toString() => 'ImageValidationException: $message';
}

class ModelLoadException implements Exception {
  final String message;
  ModelLoadException(this.message);

  @override
  String toString() => 'ModelLoadException: $message';
}
