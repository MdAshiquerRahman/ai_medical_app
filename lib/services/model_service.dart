import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

enum ModelType {
  mri('MRI', 'assets/ml_models/mri_cnn.tflite'),
  chestXRay('Chest X-Ray', 'assets/ml_models/Chest_X_Ray.tflite'),
  chestCTScan('Chest CT Scan', 'assets/ml_models/Chest_CT_Scan.tflite'),
  skin('Skin', 'assets/ml_models/skin_cnn.tflite');

  final String displayName;
  final String modelPath;

  const ModelType(this.displayName, this.modelPath);
}

class ModelService {
  Interpreter? _interpreter;
  ModelType? _currentModelType;

  // Load the selected model
  Future<void> loadModel(ModelType modelType) async {
    try {
      // Dispose previous interpreter if exists
      _interpreter?.close();
      _interpreter = null;
      _currentModelType = null;

      print('Loading model: ${modelType.displayName}');
      print('Model path: ${modelType.modelPath}');

      // Load the model
      _interpreter = await Interpreter.fromAsset(modelType.modelPath);
      _currentModelType = modelType;

      print('✅ Model ${modelType.displayName} loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('❌ Error loading model: $e');
      _interpreter = null;
      _currentModelType = null;

      // Provide more helpful error message
      if (e.toString().contains('Failed to load dynamic library')) {
        throw Exception(
          'TensorFlow Lite library not found. '
          'On Linux: Please follow LINUX_SETUP.md to install the library. '
          'On Android/iOS: This should work automatically.',
        );
      }
      rethrow;
    }
  }

  // Preprocess image for model input
  Future<dynamic> preprocessImage(File imageFile) async {
    try {
      // Read image file
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Get input shape from the model
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputHeight = inputShape[1];
      final inputWidth = inputShape[2];
      final inputChannels = inputShape[3];

      print('Input shape: $inputShape');
      print('Expected: [1, $inputHeight, $inputWidth, $inputChannels]');

      // Resize image to model input size
      img.Image resizedImage = img.copyResize(
        image,
        width: inputWidth,
        height: inputHeight,
      );

      // Convert to Float32List for better compatibility with TFLite
      var inputBytes = Float32List(
        1 * inputHeight * inputWidth * inputChannels,
      );
      var pixelIndex = 0;

      for (var i = 0; i < inputHeight; i++) {
        for (var j = 0; j < inputWidth; j++) {
          final pixel = resizedImage.getPixel(j, i);
          // Normalize to [0, 1]
          inputBytes[pixelIndex++] = pixel.r.toDouble() / 255.0;
          inputBytes[pixelIndex++] = pixel.g.toDouble() / 255.0;
          inputBytes[pixelIndex++] = pixel.b.toDouble() / 255.0;
        }
      }

      // Reshape to [1, height, width, channels]
      var input = inputBytes.reshape([
        1,
        inputHeight,
        inputWidth,
        inputChannels,
      ]);

      return input;
    } catch (e) {
      print('Error preprocessing image: $e');
      rethrow;
    }
  }

  // Run inference on the image
  Future<Map<String, dynamic>> runInference(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Model not loaded. Please select a model first.');
    }

    try {
      // Preprocess image
      final input = await preprocessImage(imageFile);

      // Prepare output buffer
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputType = _interpreter!.getOutputTensor(0).type;

      print('Output shape: $outputShape');
      print('Output type: $outputType');

      // Calculate total output size
      int outputSize = outputShape.reduce((a, b) => a * b);

      // Create output buffer as Float32List
      var outputBuffer = Float32List(outputSize);

      // Reshape to match output shape
      var output = outputBuffer.reshape(outputShape);

      print('Running inference...');

      // Run inference
      _interpreter!.run(input, output);

      print('Inference completed successfully');

      // Process results based on output shape
      List<double> results;

      print('Processing output with shape: $outputShape');
      print('Output buffer size: ${outputBuffer.length}');

      if (outputShape.length == 2) {
        // 2D output: [batch, classes]
        final numClasses = outputShape[1];
        results = outputBuffer.sublist(0, numClasses);
        print('Extracted 2D results: $numClasses classes');
      } else if (outputShape.length == 4) {
        // 4D output: [batch, height, width, classes]
        // Take the last dimension as class probabilities
        final numClasses = outputShape[3];
        results = outputBuffer.sublist(0, numClasses);
        print('Extracted 4D results: $numClasses classes');
      } else if (outputShape.length == 1) {
        // 1D output: [classes]
        results = List<double>.from(outputBuffer);
        print('Extracted 1D results: ${results.length} classes');
      } else {
        // Default: assume the buffer contains class probabilities
        print('Unknown output shape, using full buffer');
        results = List<double>.from(outputBuffer);
      }

      print('Results: $results');
      print('Number of classes: ${results.length}');

      // Validate results
      if (results.isEmpty) {
        throw Exception('Model returned empty results');
      }

      // Find the class with highest probability
      int maxIndex = 0;
      double maxValue = results[0];

      for (int i = 1; i < results.length; i++) {
        if (results[i] > maxValue) {
          maxValue = results[i];
          maxIndex = i;
        }
      }

      // Get class labels based on model type
      final classLabel = _getClassLabel(maxIndex);

      print(
        'Predicted: $classLabel with confidence: ${(maxValue * 100).toStringAsFixed(2)}%',
      );

      // Build all probabilities map with error handling
      final allProbabilities = <String, String>{};
      for (int i = 0; i < results.length; i++) {
        try {
          final label = _getClassLabel(i);
          allProbabilities[label] = (results[i] * 100).toStringAsFixed(2);
        } catch (e) {
          print('Warning: Could not get label for index $i: $e');
          allProbabilities['Class $i'] = (results[i] * 100).toStringAsFixed(2);
        }
      }

      return {
        'predictedClass': classLabel,
        'confidence': (maxValue * 100).toStringAsFixed(2),
        'classIndex': maxIndex,
        'allProbabilities': allProbabilities,
      };
    } catch (e) {
      print('Error running inference: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Get class label based on model type and index
  String _getClassLabel(int index) {
    switch (_currentModelType) {
      case ModelType.mri:
        // Example MRI classes - adjust based on your model
        const mriClasses = ['Normal', 'Tumor', 'Abnormality'];
        return index < mriClasses.length ? mriClasses[index] : 'Class $index';

      case ModelType.chestXRay:
        // Example X-Ray classes - adjust based on your model
        const xrayClasses = ['Normal', 'Pneumonia', 'COVID-19', 'Tuberculosis'];
        return index < xrayClasses.length ? xrayClasses[index] : 'Class $index';

      case ModelType.chestCTScan:
        // Example CT Scan classes - adjust based on your model
        const ctClasses = ['Normal', 'Cancer', 'Infection'];
        return index < ctClasses.length ? ctClasses[index] : 'Class $index';

      case ModelType.skin:
        // Example Skin classes - adjust based on your model
        const skinClasses = [
          'Melanoma',
          'Basal Cell Carcinoma',
          'Benign Keratosis',
          'Dermatofibroma',
          'Melanocytic Nevi',
          'Vascular Lesions',
          'Actinic Keratosis',
        ];
        return index < skinClasses.length ? skinClasses[index] : 'Class $index';

      default:
        return 'Class $index';
    }
  }

  // Get current model type
  ModelType? get currentModelType => _currentModelType;

  // Check if model is loaded
  bool get isModelLoaded => _interpreter != null;

  // Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _currentModelType = null;
  }
}
