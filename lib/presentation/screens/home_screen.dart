import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/presentation/screens/camera_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScanType? _selectedScanType;

  IconData _getScanTypeIcon(ScanType scanType) {
    switch (scanType) {
      case ScanType.chestXRay:
        return Icons.medical_services;
      case ScanType.chestCTScan:
        return Icons.monitor_heart;
      case ScanType.mri:
        return Icons.psychology;
      case ScanType.skinLesion:
        return Icons.face_retouching_natural;
    }
  }

  void _onSelectImage() {
    if (_selectedScanType != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CameraPreviewScreen(scanType: _selectedScanType!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Medical Diagnosis'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Scan Type',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose the type of medical scan you want to analyze',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),

              // Dropdown Selector
              _buildDropdownSelector(),

              const SizedBox(height: 24),

              // Selected Scan Info Display
              if (_selectedScanType != null) ...[
                _buildSelectedScanInfo(),
                const SizedBox(height: 32),
              ],

              // Select Image Button
              _buildSelectImageButton(),

              const SizedBox(height: 32),

              // Medical Disclaimer
              _MedicalDisclaimerCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedScanType != null
              ? const Color(0xFFDC143C)
              : Colors.grey.shade700,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ScanType>(
          value: _selectedScanType,
          hint: Row(
            children: [
              Icon(Icons.medical_information, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              Text(
                'Select scan type...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            ],
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF2C2C2C),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: _selectedScanType != null
                ? const Color(0xFFDC143C)
                : Colors.grey.shade500,
          ),
          items: ScanType.values.map((scanType) {
            return DropdownMenuItem<ScanType>(
              value: scanType,
              child: Row(
                children: [
                  Icon(
                    _getScanTypeIcon(scanType),
                    color: const Color(0xFFDC143C),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    scanType.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (ScanType? newValue) {
            setState(() {
              _selectedScanType = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSelectedScanInfo() {
    return Card(
      color: const Color(0xFFDC143C).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFDC143C).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC143C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getScanTypeIcon(_selectedScanType!),
                    size: 32,
                    color: const Color(0xFFDC143C),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _selectedScanType!.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedScanType!.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectImageButton() {
    final bool isEnabled = _selectedScanType != null;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? _onSelectImage : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC143C),
          disabledBackgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 3 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEnabled ? Icons.camera_alt : Icons.camera_alt_outlined,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Select Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalDisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Disclaimer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This app is for informational purposes only and should not be used as a substitute for professional medical diagnosis. Always consult with a qualified healthcare provider.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
