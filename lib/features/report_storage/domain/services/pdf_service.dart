import 'dart:io';
import 'package:ai_medical_app/features/report_storage/domain/entities/saved_report.dart';
import 'package:ai_medical_app/common/errors/result.dart';

abstract class PdfService {
  /// Generate PDF from a saved report
  Future<Result<File>> generatePdf(SavedReport report);

  /// Share the generated PDF using device's native share dialog
  Future<Result<void>> sharePdf(File pdfFile, String reportTitle);
}
