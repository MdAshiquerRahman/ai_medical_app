import 'dart:io';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/model_config.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/common/errors/result.dart';

abstract class MLModelService {
  Future<Result<void>> loadModel();

  Future<Result<DiagnosisResult>> analyzeImage(File imageFile);

  Future<void> dispose();

  bool get isModelLoaded;

  ScanType get scanType;

  ModelConfig get config;
}
