import 'package:ai_medical_app/features/scan_analysis/domain/services/ml_model_service.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/data/services/chest_ct_scan_model_service.dart';
import 'package:ai_medical_app/features/scan_analysis/data/services/chest_xray_model_service.dart';
import 'package:ai_medical_app/features/scan_analysis/data/services/mri_model_service.dart';
import 'package:ai_medical_app/features/scan_analysis/data/services/skin_lesion_model_service.dart';

class ModelServiceFactory {
  ModelServiceFactory._();

  static MLModelService create(ScanType scanType) {
    switch (scanType) {
      case ScanType.chestCTScan:
        return ChestCTScanModelService();
      case ScanType.chestXRay:
        return ChestXRayModelService();
      case ScanType.mri:
        return MRIModelService();
      case ScanType.skinLesion:
        return SkinLesionModelService();
    }
  }
}
