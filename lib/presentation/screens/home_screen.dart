import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Medical Diagnosis'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 32),
              _ScanTypeCard(
                title: 'Chest X-Ray',
                description: 'Detect respiratory conditions from X-Ray images',
                icon: Icons.medical_services,
                scanType: ScanType.chestXRay,
                onTap: () => _navigateToAnalysis(context, ScanType.chestXRay),
              ),
              const SizedBox(height: 16),
              _ScanTypeCard(
                title: 'Chest CT Scan',
                description: 'Analyze chest CT scans for pathologies',
                icon: Icons.monitor_heart,
                scanType: ScanType.chestCTScan,
                onTap: () => _navigateToAnalysis(context, ScanType.chestCTScan),
              ),
              const SizedBox(height: 16),
              _ScanTypeCard(
                title: 'MRI Scan',
                description: 'Analyze MRI brain scans for abnormalities',
                icon: Icons.psychology,
                scanType: ScanType.mri,
                onTap: () => _navigateToAnalysis(context, ScanType.mri),
              ),
              const SizedBox(height: 16),
              _ScanTypeCard(
                title: 'Skin Lesion',
                description: 'Classify skin lesions and conditions',
                icon: Icons.face_retouching_natural,
                scanType: ScanType.skinLesion,
                onTap: () => _navigateToAnalysis(context, ScanType.skinLesion),
              ),
              const SizedBox(height: 32),
              _MedicalDisclaimerCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAnalysis(BuildContext context, ScanType scanType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${scanType.displayName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ScanTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ScanType scanType;
  final VoidCallback onTap;

  const _ScanTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.scanType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ],
          ),
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
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
