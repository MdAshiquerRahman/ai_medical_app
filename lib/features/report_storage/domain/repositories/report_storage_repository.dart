import 'package:ai_medical_app/features/report_storage/domain/entities/saved_report.dart';
import 'package:ai_medical_app/common/errors/result.dart';

abstract class ReportStorageRepository {
  /// Save a report to local storage
  Future<Result<String>> saveReport(SavedReport report);

  /// Get all saved reports
  Future<Result<List<SavedReport>>> getAllReports();

  /// Get a report by ID
  Future<Result<SavedReport>> getReportById(String id);

  /// Delete a report
  Future<Result<void>> deleteReport(String id);

  /// Watch all reports (stream for real-time updates)
  Stream<List<SavedReport>> watchReports();
}
