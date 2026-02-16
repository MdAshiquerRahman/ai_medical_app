import 'dart:io';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/model_config.dart';

abstract class ImagePreprocessor {
  Future<dynamic> preprocess(File imageFile, ModelConfig config);
}
