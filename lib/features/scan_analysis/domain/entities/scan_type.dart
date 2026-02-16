enum ScanType {
  chestXRay('Chest X-Ray', 'Detect respiratory conditions from X-Ray images'),
  chestCTScan('Chest CT Scan', 'Analyze chest CT scans for lung pathologies'),
  mri('MRI', 'Analyze MRI brain scans for abnormalities'),
  skinLesion('Skin Lesion', 'Classify skin lesions and conditions');

  final String displayName;
  final String description;

  const ScanType(this.displayName, this.description);
}
