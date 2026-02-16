class MLModelConstants {
  MLModelConstants._();

  static const String chestXRayModelPath =
      'assets/ml_models/Chest_X_Ray.tflite';
  static const String mriModelPath = 'assets/ml_models/mri_cnn.tflite';
  static const String chestCTScanModelPath =
      'assets/ml_models/Chest_CT_Scan.tflite';
  static const String skinLesionModelPath = 'assets/ml_models/skin_cnn.tflite';

  static const List<String> chestCTScanClasses = [
    'adenocarcinoma',
    'large.cell.carcinoma',
    'normal',
    'squamous.cell.carcinoma',
  ];

  static const List<String> chestXRayClasses = [
    'COVID19',
    'NORMAL',
    'PNEUMONIA',
    'TURBERCULOSIS',
  ];

  static const List<String> mriClasses = [
    'glioma',
    'meningioma',
    'notumor',
    'pituitary',
  ];

  static const List<String> skinLesionClasses = [
    'Melanoma',
    'Basal Cell Carcinoma',
    'Benign Keratosis',
    'Dermatofibroma',
    'Melanocytic Nevi',
    'Vascular Lesions',
    'Actinic Keratosis',
  ];

  static const int defaultInputSize = 224;
  static const int defaultChannels = 3;

  static const int chestXRayBatchSize = 16;
  static const int mriBatchSize = 1;
  static const int chestCTScanBatchSize = 1;
  static const int skinLesionBatchSize = 1;
}
