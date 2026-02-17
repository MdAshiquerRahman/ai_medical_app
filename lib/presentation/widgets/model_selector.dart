import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';

class ModelSelector extends StatelessWidget {
  final ScanType? selectedScanType;
  final Function(ScanType) onScanTypeSelected;
  final bool isEnabled;

  const ModelSelector({
    super.key,
    required this.selectedScanType,
    required this.onScanTypeSelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1: Select Scan Type',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ScanType.values.map((scanType) {
              return RadioListTile<ScanType>(
                title: Text(
                  scanType.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  scanType.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                value: scanType,
                groupValue: selectedScanType,
                onChanged: isEnabled
                    ? (ScanType? value) {
                        if (value != null) {
                          onScanTypeSelected(value);
                        }
                      }
                    : null,
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
