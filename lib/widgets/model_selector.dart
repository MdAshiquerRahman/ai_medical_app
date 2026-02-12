import 'package:flutter/material.dart';
import 'package:ai_medical_app/services/model_service.dart';

class ModelSelector extends StatelessWidget {
  final ModelType? selectedModelType;
  final Function(ModelType) onModelSelected;
  final bool isEnabled;

  const ModelSelector({
    super.key,
    required this.selectedModelType,
    required this.onModelSelected,
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
              'Step 1: Select Model Type',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ModelType.values.map((modelType) {
              return RadioListTile<ModelType>(
                title: Text(
                  modelType.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  _getModelDescription(modelType),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                value: modelType,
                groupValue: selectedModelType,
                onChanged: isEnabled
                    ? (ModelType? value) {
                        if (value != null) {
                          onModelSelected(value);
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

  String _getModelDescription(ModelType modelType) {
    switch (modelType) {
      case ModelType.mri:
        return 'Analyze MRI brain scans for abnormalities';
      case ModelType.chestXRay:
        return 'Detect respiratory conditions from X-Ray images';
      case ModelType.chestCTScan:
        return 'Analyze chest CT scans for pathologies';
      case ModelType.skin:
        return 'Classify skin lesions and conditions';
    }
  }
}
