import 'dart:io';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/common/errors/result.dart';

abstract class MLModelRepository {
  Future<Result<void>> loadModel(ScanType scanType);

  Future<Result<DiagnosisResult>> analyzeImage(File imageFile);

  Future<void> disposeCurrentModel();

  bool get hasModelLoaded;

  ScanType? get currentScanType;
}
