import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteTestPage extends StatefulWidget {
  const TFLiteTestPage({super.key});

  @override
  State<TFLiteTestPage> createState() => _TFLiteTestPageState();
}

class _TFLiteTestPageState extends State<TFLiteTestPage> {
  String _status = 'Not tested';
  bool _isLoading = false;

  Future<void> _testTFLite() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing...';
    });

    try {
      // Try to load a model
      final interpreter = await Interpreter.fromAsset(
        'assets/ml_models/skin_cnn.tflite',
      );

      setState(() {
        _status =
            '✅ SUCCESS!\n\n'
            'TensorFlow Lite is working!\n'
            'Model loaded successfully.\n\n'
            'Input: ${interpreter.getInputTensor(0).shape}\n'
            'Output: ${interpreter.getOutputTensor(0).shape}';
        _isLoading = false;
      });

      interpreter.close();
    } catch (e) {
      setState(() {
        _status =
            '❌ FAILED\n\n'
            'Error: $e\n\n'
            'Solution:\n'
            '- On Linux: Run setup_tflite_linux.sh\n'
            '- Or test on Android/iOS';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TFLite Test')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.science, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'TensorFlow Lite Status',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(_status, style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testTFLite,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Testing...' : 'Test TFLite'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This test will verify if TensorFlow Lite\ncan load models on your platform.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
