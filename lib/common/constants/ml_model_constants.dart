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
    '1. Eczema 1677',
    '10. Warts Molluscum and other Viral Infections - 2103',
    '2. Melanoma 15.75k',
    '3. Atopic Dermatitis - 1.25k',
    '4. Basal Cell Carcinoma (BCC) 3323',
    '5. Melanocytic Nevi (NV) - 7970',
    '6. Benign Keratosis-like Lesions (BKL) 2624',
    '7. Psoriasis pictures Lichen Planus and related diseases - 2k',
    '8. Seborrheic Keratoses and other Benign Tumors - 1.8k',
    '9. Tinea Ringworm Candidiasis and other Fungal Infections - 1.7k',
  ];

  static const int defaultInputSize = 224;
  static const int skinLesionInputSize = 180;
  static const int defaultChannels = 3;

  static const int chestXRayBatchSize = 16;
  static const int mriBatchSize = 16;
  static const int chestCTScanBatchSize = 16;
  static const int skinLesionBatchSize = 16;
}
