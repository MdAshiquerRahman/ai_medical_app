import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/scan_analysis/data/services/model_service_factory.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/presentation/screens/patient_info_form_screen.dart';

class ImageCropScreen extends StatefulWidget {
  final File imageFile;
  final ScanType scanType;

  const ImageCropScreen({
    super.key,
    required this.imageFile,
    required this.scanType,
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  bool _isLoading = true;
  Rect _cropRect = const Rect.fromLTWH(50, 100, 300, 300);
  Offset? _dragStart;
  Rect? _resizeDragStart;
  String?
  _resizeHandle; // 'topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'top', 'bottom', 'left', 'right'

  static const double minSize = 30;
  static const double handleSize = 40;
  Size? _imageSize;
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final data = await widget.imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      setState(() {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        _isLoading = false;
        // Start with full image selected
        _cropRect = Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        );
      });
    } catch (e) {
      debugPrint('Error loading image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPanStart(DragStartDetails details, Size widgetSize) {
    if (_imageSize == null) return;

    final localPosition = details.localPosition;

    // Calculate proper scale considering BoxFit.contain
    final scaleX = widgetSize.width / _imageSize!.width;
    final scaleY = widgetSize.height / _imageSize!.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate image display offset (centered)
    final displayWidth = _imageSize!.width * scale;
    final displayHeight = _imageSize!.height * scale;
    final offsetX = (widgetSize.width - displayWidth) / 2;
    final offsetY = (widgetSize.height - displayHeight) / 2;

    // Convert widget position to image coordinates
    final imageX = (localPosition.dx - offsetX) / scale;
    final imageY = (localPosition.dy - offsetY) / scale;
    final imagePosition = Offset(imageX, imageY);

    // Check if touching a handle
    final handle = _getHandleAtPosition(imagePosition);
    if (handle != null) {
      _resizeHandle = handle;
      _resizeDragStart = _cropRect;
    } else if (_cropRect.contains(imagePosition)) {
      _dragStart = imagePosition - _cropRect.topLeft;
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size widgetSize) {
    if (_imageSize == null) return;

    final localPosition = details.localPosition;

    // Calculate proper scale considering BoxFit.contain
    final scaleX = widgetSize.width / _imageSize!.width;
    final scaleY = widgetSize.height / _imageSize!.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate image display offset (centered)
    final displayWidth = _imageSize!.width * scale;
    final displayHeight = _imageSize!.height * scale;
    final offsetX = (widgetSize.width - displayWidth) / 2;
    final offsetY = (widgetSize.height - displayHeight) / 2;

    // Convert widget position to image coordinates
    final imageX = (localPosition.dx - offsetX) / scale;
    final imageY = (localPosition.dy - offsetY) / scale;
    final imagePosition = Offset(imageX, imageY);

    setState(() {
      if (_resizeHandle != null && _resizeDragStart != null) {
        _updateCropRectResize(imagePosition);
      } else if (_dragStart != null) {
        _updateCropRectMove(imagePosition);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _dragStart = null;
    _resizeDragStart = null;
    _resizeHandle = null;
  }

  String? _getHandleAtPosition(Offset position) {
    const double tolerance = handleSize;

    // Corner handles
    if ((position - _cropRect.topLeft).distance < tolerance) return 'topLeft';
    if ((position - _cropRect.topRight).distance < tolerance) return 'topRight';
    if ((position - _cropRect.bottomLeft).distance < tolerance)
      return 'bottomLeft';
    if ((position - _cropRect.bottomRight).distance < tolerance)
      return 'bottomRight';

    // Edge handles
    if ((position.dx - _cropRect.left).abs() < tolerance / 2 &&
        position.dy > _cropRect.top &&
        position.dy < _cropRect.bottom)
      return 'left';
    if ((position.dx - _cropRect.right).abs() < tolerance / 2 &&
        position.dy > _cropRect.top &&
        position.dy < _cropRect.bottom)
      return 'right';
    if ((position.dy - _cropRect.top).abs() < tolerance / 2 &&
        position.dx > _cropRect.left &&
        position.dx < _cropRect.right)
      return 'top';
    if ((position.dy - _cropRect.bottom).abs() < tolerance / 2 &&
        position.dx > _cropRect.left &&
        position.dx < _cropRect.right)
      return 'bottom';

    return null;
  }

  void _updateCropRectMove(Offset imagePosition) {
    if (_dragStart == null || _imageSize == null) return;

    var newLeft = imagePosition.dx - _dragStart!.dx;
    var newTop = imagePosition.dy - _dragStart!.dy;

    // Constrain to image bounds
    newLeft = newLeft.clamp(0.0, _imageSize!.width - _cropRect.width);
    newTop = newTop.clamp(0.0, _imageSize!.height - _cropRect.height);

    _cropRect = Rect.fromLTWH(
      newLeft,
      newTop,
      _cropRect.width,
      _cropRect.height,
    );
  }

  void _updateCropRectResize(Offset imagePosition) {
    if (_resizeDragStart == null || _imageSize == null) return;

    double newLeft = _cropRect.left;
    double newTop = _cropRect.top;
    double newRight = _cropRect.right;
    double newBottom = _cropRect.bottom;

    switch (_resizeHandle) {
      case 'topLeft':
        newLeft = imagePosition.dx.clamp(0.0, _cropRect.right - minSize);
        newTop = imagePosition.dy.clamp(0.0, _cropRect.bottom - minSize);
        break;
      case 'topRight':
        newRight = imagePosition.dx.clamp(
          _cropRect.left + minSize,
          _imageSize!.width,
        );
        newTop = imagePosition.dy.clamp(0.0, _cropRect.bottom - minSize);
        break;
      case 'bottomLeft':
        newLeft = imagePosition.dx.clamp(0.0, _cropRect.right - minSize);
        newBottom = imagePosition.dy.clamp(
          _cropRect.top + minSize,
          _imageSize!.height,
        );
        break;
      case 'bottomRight':
        newRight = imagePosition.dx.clamp(
          _cropRect.left + minSize,
          _imageSize!.width,
        );
        newBottom = imagePosition.dy.clamp(
          _cropRect.top + minSize,
          _imageSize!.height,
        );
        break;
      case 'left':
        newLeft = imagePosition.dx.clamp(0.0, _cropRect.right - minSize);
        break;
      case 'right':
        newRight = imagePosition.dx.clamp(
          _cropRect.left + minSize,
          _imageSize!.width,
        );
        break;
      case 'top':
        newTop = imagePosition.dy.clamp(0.0, _cropRect.bottom - minSize);
        break;
      case 'bottom':
        newBottom = imagePosition.dy.clamp(
          _cropRect.top + minSize,
          _imageSize!.height,
        );
        break;
    }

    _cropRect = Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }

  Future<void> _processCropAndAnalyze() async {
    if (_imageSize == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const CircularProgressIndicator(color: Color(0xFFDC143C)),
        ),
      ),
    );

    try {
      // Read the original image file
      final bytes = await widget.imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Convert to RGB format to fix color channel issues
      final rgbImage = originalImage.convert(numChannels: 3);

      // Crop the image based on the selected area
      final croppedImage = img.copyCrop(
        rgbImage,
        x: _cropRect.left.toInt(),
        y: _cropRect.top.toInt(),
        width: _cropRect.width.toInt(),
        height: _cropRect.height.toInt(),
      );

      // Save the cropped image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final croppedFile = File('${tempDir.path}/cropped_$timestamp.jpg');

      // Encode as JPEG with proper color format
      final encodedBytes = img.encodeJpg(croppedImage, quality: 90);
      await croppedFile.writeAsBytes(encodedBytes);

      // Load and run ML model
      final modelService = ModelServiceFactory.create(widget.scanType);
      final loadResult = await modelService.loadModel();

      if (loadResult is Failure) {
        throw Exception('Failed to load model');
      }

      final analysisResult = await modelService.analyzeImage(croppedFile);
      await modelService.dispose();

      if (analysisResult is Failure) {
        throw Exception('Failed to analyze image');
      }

      final diagnosisResult = (analysisResult as Success<DiagnosisResult>).data;

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientInfoFormScreen(
              imageFile: croppedFile,
              scanType: widget.scanType,
              diagnosisResult: diagnosisResult,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to crop image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFDC143C)),
            )
          : Column(
              children: [
                // Top bar
                SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.scanType.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                'Adjust selection area',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Image with crop overlay
                Expanded(
                  child: _imageSize == null
                      ? const Center(
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onPanStart: (details) =>
                                  _onPanStart(details, constraints.biggest),
                              onPanUpdate: (details) =>
                                  _onPanUpdate(details, constraints.biggest),
                              onPanEnd: _onPanEnd,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Display actual image
                                  Image.file(
                                    widget.imageFile,
                                    fit: BoxFit.contain,
                                  ),
                                  // Crop overlay
                                  CustomPaint(
                                    size: constraints.biggest,
                                    painter: _CropOverlayPainter(
                                      imageSize: _imageSize!,
                                      cropRect: _cropRect,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Bottom controls
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Retake',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _processCropAndAnalyze,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC143C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.psychology),
                                SizedBox(width: 8),
                                Text(
                                  'Analyze',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Size imageSize;
  final Rect cropRect;

  _CropOverlayPainter({required this.imageSize, required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale to fit image in widget
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Center the image
    final double scaledWidth = imageSize.width * scale;
    final double scaledHeight = imageSize.height * scale;
    final double offsetX = (size.width - scaledWidth) / 2;
    final double offsetY = (size.height - scaledHeight) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Draw dimmed overlay outside crop rect
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Top
    canvas.drawRect(
      Rect.fromLTRB(0, 0, imageSize.width, cropRect.top),
      overlayPaint,
    );
    // Bottom
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.bottom, imageSize.width, imageSize.height),
      overlayPaint,
    );
    // Left
    canvas.drawRect(
      Rect.fromLTRB(0, cropRect.top, cropRect.left, cropRect.bottom),
      overlayPaint,
    );
    // Right
    canvas.drawRect(
      Rect.fromLTRB(
        cropRect.right,
        cropRect.top,
        imageSize.width,
        cropRect.bottom,
      ),
      overlayPaint,
    );

    // Draw crop rect border
    final borderPaint = Paint()
      ..color = const Color(0xFFDC143C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(cropRect, borderPaint);

    // Draw grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Vertical lines
    canvas.drawLine(
      Offset(cropRect.left + cropRect.width / 3, cropRect.top),
      Offset(cropRect.left + cropRect.width / 3, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + 2 * cropRect.width / 3, cropRect.top),
      Offset(cropRect.left + 2 * cropRect.width / 3, cropRect.bottom),
      gridPaint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + cropRect.height / 3),
      Offset(cropRect.right, cropRect.top + cropRect.height / 3),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + 2 * cropRect.height / 3),
      Offset(cropRect.right, cropRect.top + 2 * cropRect.height / 3),
      gridPaint,
    );

    // Draw corner handles
    final handlePaint = Paint()
      ..color = const Color(0xFFDC143C)
      ..style = PaintingStyle.fill;

    final handleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final handleSize = 12.0;

    void drawHandle(Offset position) {
      canvas.drawCircle(position, handleSize, handlePaint);
      canvas.drawCircle(position, handleSize, handleBorderPaint);
    }

    // Corner handles
    drawHandle(cropRect.topLeft);
    drawHandle(cropRect.topRight);
    drawHandle(cropRect.bottomLeft);
    drawHandle(cropRect.bottomRight);

    // Edge handles (for better UX)
    drawHandle(Offset(cropRect.center.dx, cropRect.top));
    drawHandle(Offset(cropRect.center.dx, cropRect.bottom));
    drawHandle(Offset(cropRect.left, cropRect.center.dy));
    drawHandle(Offset(cropRect.right, cropRect.center.dy));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
