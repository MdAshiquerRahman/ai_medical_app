import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:ai_medical_app/features/scan_analysis/domain/preprocessing/image_preprocessor.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/model_config.dart';
import 'package:ai_medical_app/common/errors/exceptions.dart';

class ChestCTScanPreprocessor implements ImagePreprocessor {
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

      final sharpenedImage = _sharpenImage(resizedImage);

      final input = List.generate(
        config.batchSize,
        (b) => List.generate(
          config.inputHeight,
          (y) => List.generate(config.inputWidth, (x) {
            final pixel = sharpenedImage.getPixel(x, y);
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

  img.Image _sharpenImage(img.Image image) {
    // Apply sharpening kernel: [0, -1, 0, -1, 5, -1, 0, -1, 0]
    final sharpened = image.clone();

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = image.getPixel(x, y);
        final top = image.getPixel(x, y - 1);
        final bottom = image.getPixel(x, y + 1);
        final left = image.getPixel(x - 1, y);
        final right = image.getPixel(x + 1, y);

        // Apply kernel: 5*center - top - bottom - left - right
        final r = (5 * center.r - top.r - bottom.r - left.r - right.r)
            .clamp(0, 255)
            .toInt();
        final g = (5 * center.g - top.g - bottom.g - left.g - right.g)
            .clamp(0, 255)
            .toInt();
        final b = (5 * center.b - top.b - bottom.b - left.b - right.b)
            .clamp(0, 255)
            .toInt();

        sharpened.setPixelRgb(x, y, r, g, b);
      }
    }

    return sharpened;
  }
}
