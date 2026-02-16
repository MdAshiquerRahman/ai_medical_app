import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/features/scan_analysis/data/repositories/ml_model_repository_impl.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/repositories/ml_model_repository.dart';
import 'package:ai_medical_app/features/scan_analysis/data/services/image_picker_service.dart';
import 'package:ai_medical_app/presentation/widgets/model_selector.dart';
import 'package:ai_medical_app/presentation/widgets/image_preview.dart';
import 'package:ai_medical_app/presentation/widgets/prediction_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MLModelRepository _modelRepository = MLModelRepositoryImpl();
  final ImagePickerService _imagePickerService = ImagePickerService();

  ScanType? _selectedScanType;
  File? _selectedImage;
  DiagnosisResult? _diagnosisResult;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _modelRepository.disposeCurrentModel();
    super.dispose();
  }

  // Handle model selection
  Future<void> _onScanTypeSelected(ScanType scanType) async {
    setState(() {
      _selectedScanType = scanType;
      _selectedImage = null;
      _diagnosisResult = null;
      _errorMessage = null;
      _isLoading = true;
    });

    final result = await _modelRepository.loadModel(scanType);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      switch (result) {
        case Success():
          _showSnackBar('Model "${scanType.displayName}" loaded successfully!');
        case Failure(:final message):
          setState(() {
            _errorMessage = message;
          });
          _showSnackBar('Error: $message', isError: true);
      }
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    if (_selectedScanType == null) {
      _showSnackBar('Please select a scan type first!', isError: true);
      return;
    }

    try {
      final image = await _imagePickerService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _diagnosisResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    if (_selectedScanType == null) {
      _showSnackBar('Please select a scan type first!', isError: true);
      return;
    }

    try {
      final image = await _imagePickerService.pickImageFromCamera();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _diagnosisResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (e is UnsupportedError) {
        _showSnackBar(
          'Camera is not available on this platform',
          isError: true,
        );
      } else {
        _showSnackBar('Error picking image: $e', isError: true);
      }
    }
  }

  // Run prediction
  Future<void> _runPrediction() async {
    if (_selectedScanType == null) {
      _showSnackBar('Please select a scan type first!', isError: true);
      return;
    }

    if (_selectedImage == null) {
      _showSnackBar('Please select an image first!', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _modelRepository.analyzeImage(_selectedImage!);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      switch (result) {
        case Success(:final data):
          setState(() {
            _diagnosisResult = data;
          });
        case Failure(:final message):
          setState(() {
            _errorMessage = message;
          });
          _showSnackBar('Error: $message', isError: true);
      }
    }
  }

  // Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Clear all selections
  void _clearAll() {
    setState(() {
      _selectedImage = null;
      _diagnosisResult = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Medical Diagnosis'),
        centerTitle: true,
        elevation: 2,
        actions: [
          if (_selectedImage != null || _diagnosisResult != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Model Selector
              ModelSelector(
                selectedScanType: _selectedScanType,
                onScanTypeSelected: _onScanTypeSelected,
                isEnabled: !_isLoading,
              ),

              const SizedBox(height: 24),

              // Image Picker Buttons
              if (_selectedScanType != null) ...[
                Text(
                  'Step 2: Upload Image',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    if (_imagePickerService.isCameraAvailable) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickImageFromCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Image Preview
              if (_selectedImage != null) ...[
                ImagePreview(imageFile: _selectedImage!),
                const SizedBox(height: 24),

                // Analyze Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _runPrediction,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.analytics),
                    label: Text(
                      _isLoading ? 'Analyzing...' : 'Analyze Image',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Loading Indicator
              if (_isLoading && _selectedImage == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Prediction Result
              if (_diagnosisResult != null)
                PredictionResult(result: _diagnosisResult!),
            ],
          ),
        ),
      ),
    );
  }
}
