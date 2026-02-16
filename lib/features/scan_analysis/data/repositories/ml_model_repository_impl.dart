import 'dart:io';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/services/ml_model_service.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/features/scan_analysis/data/services/model_service_factory.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/repositories/ml_model_repository.dart';

class MLModelRepositoryImpl implements MLModelRepository {
  MLModelService? _currentService;

  @override
  Future<Result<void>> loadModel(ScanType scanType) async {
    try {
      await _currentService?.dispose();

      _currentService = ModelServiceFactory.create(scanType);

      return await _currentService!.loadModel();
    } catch (e) {
      return Failure('Failed to load model: $e');
    }
  }

  @override
  Future<Result<DiagnosisResult>> analyzeImage(File imageFile) async {
    if (_currentService == null) {
      return const Failure('No model loaded. Please select a scan type first.');
    }

    return await _currentService!.analyzeImage(imageFile);
  }

  @override
  Future<void> disposeCurrentModel() async {
    await _currentService?.dispose();
    _currentService = null;
  }

  @override
  bool get hasModelLoaded =>
      _currentService != null && _currentService!.isModelLoaded;

  @override
  ScanType? get currentScanType => _currentService?.scanType;
}
