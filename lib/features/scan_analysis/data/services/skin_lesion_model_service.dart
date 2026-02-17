import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/services/ml_model_service.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/model_config.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/common/errors/exceptions.dart';
import 'package:ai_medical_app/common/constants/ml_model_constants.dart';
import 'package:ai_medical_app/features/scan_analysis/data/preprocessing/skin_lesion_preprocessor.dart';

class SkinLesionModelService implements MLModelService {
  final SkinLesionPreprocessor _preprocessor;
  Interpreter? _interpreter;

  SkinLesionModelService({SkinLesionPreprocessor? preprocessor})
      : _preprocessor = preprocessor ?? SkinLesionPreprocessor();

  @override
  ScanType get scanType => ScanType.skinLesion;

  @override
  ModelConfig get config => const ModelConfig(
        modelPath: MLModelConstants.skinLesionModelPath,
        classLabels: MLModelConstants.skinLesionClasses,
        inputWidth: MLModelConstants.defaultInputSize,
        inputHeight: MLModelConstants.defaultInputSize,
        inputChannels: MLModelConstants.defaultChannels,
        batchSize: MLModelConstants.skinLesionBatchSize,
      );

  @override
  bool get isModelLoaded => _interpreter != null;

  @override
  Future<Result<void>> loadModel() async {
    try {
      await dispose();

      _interpreter = await Interpreter.fromAsset(config.modelPath);

      return const Success(null);
    } catch (e) {
      throw ModelLoadException('Failed to load Skin Lesion model: $e');
    }
  }

  @override
  Future<Result<DiagnosisResult>> analyzeImage(File imageFile) async {
    if (!isModelLoaded) {
      return const Failure('Model not loaded');
    }

    try {
      final startTime = DateTime.now();

      final input = await _preprocessor.preprocess(imageFile, config);

      final outputShape = _interpreter!.getOutputTensor(0).shape;

      final List<double> results;
      if (outputShape.length == 2) {
        final output = List.generate(
          outputShape[0],
          (i) => List.filled(outputShape[1], 0.0),
        );
        _interpreter!.run(input, output);
        results = List<double>.from(output[0]);
      } else {
        final output = List.filled(outputShape[0], 0.0);
        _interpreter!.run(input, output);
        results = List<double>.from(output);
      }

      if (results.isEmpty) {
        return const Failure('Model returned empty results');
      }

      int maxIndex = 0;
      double maxValue = results[0];

      for (int i = 1; i < results.length; i++) {
        if (results[i] > maxValue) {
          maxValue = results[i];
          maxIndex = i;
        }
      }

      final allProbabilities = <String, double>{};
      for (int i = 0; i < results.length; i++) {
        if (i < config.classLabels.length) {
          allProbabilities[config.classLabels[i]] = results[i];
        }
      }

      final processingTime = DateTime.now().difference(startTime);

      final diagnosisResult = DiagnosisResult(
        scanType: scanType,
        predictedClass: config.classLabels[maxIndex],
        confidence: maxValue,
        allProbabilities: allProbabilities,
        processingTime: processingTime,
        timestamp: DateTime.now(),
      );

      return Success(diagnosisResult);
    } on ModelNotLoadedException catch (e) {
      return Failure('Model not loaded', e);
    } on ImageProcessingException catch (e) {
      return Failure('Image processing failed', e);
    } catch (e) {
      return Failure('Analysis failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
  }
}
