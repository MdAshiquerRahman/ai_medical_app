import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:ai_medical_app/features/scan_analysis/domain/preprocessing/image_preprocessor.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/model_config.dart';
import 'package:ai_medical_app/common/errors/exceptions.dart';

class MRIPreprocessor implements ImagePreprocessor {
  @override
  Future<dynamic> preprocess(File imageFile, ModelConfig config) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw ImageProcessingException('Failed to decode image');
      }

      img.Image resizedImage = img.copyResize(
        image,
        width: config.inputWidth,
        height: config.inputHeight,
      );

      final input = List.generate(
        config.batchSize,
        (b) => List.generate(
          config.inputHeight,
          (y) => List.generate(config.inputWidth, (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
          }),
        ),
      );

      return input;
    } catch (e) {
      if (e is ImageProcessingException) rethrow;
      throw ImageProcessingException('Preprocessing failed: $e');
    }
  }
}
