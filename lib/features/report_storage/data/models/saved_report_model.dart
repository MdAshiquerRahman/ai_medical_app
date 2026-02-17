import 'package:hive/hive.dart';
import 'package:ai_medical_app/features/report_storage/domain/entities/saved_report.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/health_report.dart';

part 'saved_report_model.g.dart';

@HiveType(typeId: 0)
class SavedReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String scanTypeString; // Store as string for simplicity

  @HiveField(3)
  final Map<dynamic, dynamic> diagnosisJson;

  @HiveField(4)
  final Map<dynamic, dynamic> patientInfoJson;

  @HiveField(5)
  final Map<dynamic, dynamic>? healthReportJson;

  @HiveField(6)
  final DateTime timestamp;

  SavedReportModel({
    required this.id,
    required this.imagePath,
    required this.scanTypeString,
    required this.diagnosisJson,
    required this.patientInfoJson,
    this.healthReportJson,
    required this.timestamp,
  });

  /// Convert from domain entity to Hive model
  factory SavedReportModel.fromEntity(SavedReport entity) {
    // Store diagnosis result as raw values for proper reconstruction
    final diagnosisJson = {
      'predictedClass': entity.diagnosisResult.predictedClass,
      'confidence': entity.diagnosisResult.confidence,
      'allProbabilities': entity.diagnosisResult.allProbabilities,
      'processingTimeMs': entity.diagnosisResult.processingTime.inMilliseconds,
      'timestamp': entity.diagnosisResult.timestamp.toIso8601String(),
    };

    return SavedReportModel(
      id: entity.id,
      imagePath: entity.imagePath,
      scanTypeString: entity.scanType.name,
      diagnosisJson: diagnosisJson,
      patientInfoJson: entity.patientInfo.toMap(),
      healthReportJson: entity.healthReport?.toJson(),
      timestamp: entity.timestamp,
    );
  }

  /// Convert from Hive model to domain entity
  SavedReport toEntity() {
    // Cast Maps from dynamic to String keys for proper type safety
    final diagnosisMap = _convertMap(diagnosisJson);
    final patientMap = _convertMap(patientInfoJson);
    final healthReportMap = healthReportJson != null
        ? _convertMap(healthReportJson!)
        : null;

    return SavedReport(
      id: id,
      imagePath: imagePath,
      scanType: _scanTypeFromString(scanTypeString),
      diagnosisResult: DiagnosisResult(
        scanType: _scanTypeFromString(scanTypeString),
        predictedClass: diagnosisMap['predictedClass'] as String,
        confidence: (diagnosisMap['confidence'] as num).toDouble(),
        allProbabilities: Map<String, double>.from(
          (diagnosisMap['allProbabilities'] as Map).map(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
          ),
        ),
        processingTime: Duration(
          milliseconds: diagnosisMap['processingTimeMs'] as int,
        ),
        timestamp: DateTime.parse(diagnosisMap['timestamp'] as String),
      ),
      patientInfo: PatientInfo.fromMap(patientMap),
      healthReport: healthReportMap != null
          ? HealthReport.fromJson(healthReportMap)
          : null,
      timestamp: timestamp,
    );
  }

  /// Recursively convert Map<dynamic, dynamic> to Map<String, dynamic>
  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      final stringKey = key.toString();
      if (value is Map) {
        result[stringKey] = _convertMap(value);
      } else if (value is List) {
        result[stringKey] = _convertList(value);
      } else {
        result[stringKey] = value;
      }
    });
    return result;
  }

  /// Recursively convert List with nested maps
  List<dynamic> _convertList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) {
        return _convertMap(item);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
  }

  ScanType _scanTypeFromString(String value) {
    switch (value) {
      case 'chestXRay':
        return ScanType.chestXRay;
      case 'chestCTScan':
        return ScanType.chestCTScan;
      case 'mri':
        return ScanType.mri;
      case 'skinLesion':
        return ScanType.skinLesion;
      default:
        return ScanType.chestXRay;
    }
  }
}
