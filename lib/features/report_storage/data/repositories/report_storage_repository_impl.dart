import 'package:hive_flutter/hive_flutter.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/features/report_storage/domain/entities/saved_report.dart';
import 'package:ai_medical_app/features/report_storage/domain/repositories/report_storage_repository.dart';
import 'package:ai_medical_app/features/report_storage/data/models/saved_report_model.dart';

class ReportStorageRepositoryImpl implements ReportStorageRepository {
  static const String _boxName = 'medical_reports';
  late final Box<SavedReportModel> _box;

  ReportStorageRepositoryImpl() {
    _box = Hive.box<SavedReportModel>(_boxName);
  }

  @override
  Future<Result<String>> saveReport(SavedReport report) async {
    try {
      final model = SavedReportModel.fromEntity(report);
      await _box.put(report.id, model);
      return Success(report.id);
    } catch (e) {
      return Failure('Failed to save report: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<SavedReport>>> getAllReports() async {
    try {
      final models = _box.values.toList();
      // Sort by timestamp, newest first
      models.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final reports = models.map((model) => model.toEntity()).toList();
      return Success(reports);
    } catch (e) {
      return Failure('Failed to get reports: ${e.toString()}');
    }
  }

  @override
  Future<Result<SavedReport>> getReportById(String id) async {
    try {
      final model = _box.get(id);
      if (model == null) {
        return Failure('Report with ID $id not found');
      }
      return Success(model.toEntity());
    } catch (e) {
      return Failure('Failed to get report: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteReport(String id) async {
    try {
      await _box.delete(id);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete report: ${e.toString()}');
    }
  }

  @override
  Stream<List<SavedReport>> watchReports() {
    return _box.watch().map((_) {
      final models = _box.values.toList();
      // Sort by timestamp, newest first
      models.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return models.map((model) => model.toEntity()).toList();
    });
  }
}
