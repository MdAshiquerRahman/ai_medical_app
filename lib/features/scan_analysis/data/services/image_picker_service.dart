import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery (mobile) or file picker (desktop)
  Future<File?> pickImageFromGallery() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Web platform is not supported');
      }

      // Check if running on desktop (Linux, Windows, macOS)
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        return await _pickImageFromFilePicker();
      } else {
        // Mobile platforms (Android, iOS)
        return await _pickImageFromImagePicker(ImageSource.gallery);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      rethrow;
    }
  }

  // Pick image from camera (mobile only)
  Future<File?> pickImageFromCamera() async {
    try {
      if (kIsWeb) {
        throw UnsupportedError('Web platform is not supported');
      }

      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        throw UnsupportedError('Camera is not available on desktop platforms');
      }

      return await _pickImageFromImagePicker(ImageSource.camera);
    } catch (e) {
      print('Error picking image from camera: $e');
      rethrow;
    }
  }

  // Internal method to pick image using image_picker (mobile)
  Future<File?> _pickImageFromImagePicker(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error in _pickImageFromImagePicker: $e');
      rethrow;
    }
  }

  // Internal method to pick image using file_picker (desktop)
  Future<File?> _pickImageFromFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      print('Error in _pickImageFromFilePicker: $e');
      rethrow;
    }
  }

  // Check if camera is available (mobile only)
  bool get isCameraAvailable {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
