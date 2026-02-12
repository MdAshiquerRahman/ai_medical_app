import 'dart:io';
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
      final batchSize = inputShape[0];
      final inputHeight = inputShape[1];
      final inputWidth = inputShape[2];
      final inputChannels = inputShape[3];

      print('Input shape: $inputShape');
      print(
        'Expected: [$batchSize, $inputHeight, $inputWidth, $inputChannels]',
      );

      // Resize image to model input size
      img.Image resizedImage = img.copyResize(
        image,
        width: inputWidth,
        height: inputHeight,
      );

      print('Original image size: ${image.width}x${image.height}');
      print('Resized image size: ${resizedImage.width}x${resizedImage.height}');

      // Create proper nested list structure for TFLite
      // Structure: [batch][height][width][channels]
      var input = List.generate(
        batchSize,
        (b) => List.generate(
          inputHeight,
          (y) => List.generate(inputWidth, (x) {
            final pixel = resizedImage.getPixel(x, y);
            // Normalize to [0, 1] - this is what Keras models typically expect
            return [
              pixel.r.toDouble() / 255.0,
              pixel.g.toDouble() / 255.0,
              pixel.b.toDouble() / 255.0,
            ];
          }),
        ),
      );

      // Debug: print sample pixel values
      print('Sample input values [0][0][0]: ${input[0][0][0]}');
      print('Sample input values [0][0][1]: ${input[0][0][1]}');
      print('Sample input values [0][1][0]: ${input[0][1][0]}');

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

      // Create output buffer as nested list structure
      var output;

      if (outputShape.length == 2) {
        // 2D: [batch, classes]
        output = List.generate(
          outputShape[0],
          (i) => List.filled(outputShape[1], 0.0),
        );
      } else if (outputShape.length == 1) {
        // 1D: [classes]
        output = List.filled(outputShape[0], 0.0);
      } else {
        throw Exception('Unsupported output shape: $outputShape');
      }

      print('Running inference...');
      print('Input tensor type: ${_interpreter!.getInputTensor(0).type}');
      print('Output tensor type: ${_interpreter!.getOutputTensor(0).type}');

      // Run inference
      _interpreter!.run(input, output);

      print('Inference completed successfully');
      print('Output after inference: $output');

      // Process results based on output shape
      List<double> results;

      print('Processing output with shape: $outputShape');

      if (outputShape.length == 2) {
        // 2D output: [batch, classes]
        final batchSize = outputShape[0];
        final numClasses = outputShape[1];

        print('Batch size: $batchSize, Num classes: $numClasses');

        // Take the first batch's results
        results = List<double>.from(output[0]);
        print('Extracted 2D results from batch 0: $results');

        // Also print second batch for comparison (if exists)
        if (batchSize > 1) {
          print('Batch 1 results (for verification): ${output[1]}');
        }
      } else if (outputShape.length == 1) {
        // 1D output: [classes]
        results = List<double>.from(output);
        print('Extracted 1D results: ${results.length} classes');
      } else {
        throw Exception(
          'Unsupported output shape for processing: $outputShape',
        );
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
        // MRI classes based on the trained model
        const mriClasses = ['glioma', 'meningioma', 'notumor', 'pituitary'];
        return index < mriClasses.length ? mriClasses[index] : 'Class $index';

      case ModelType.chestXRay:
        // Chest X-Ray classes based on the trained model
        const xrayClasses = ['COVID19', 'NORMAL', 'PNEUMONIA', 'TURBERCULOSIS'];
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
