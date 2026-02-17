import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/features/report_storage/domain/entities/saved_report.dart';
import 'package:ai_medical_app/features/report_storage/domain/services/pdf_service.dart';

class PdfServiceImpl implements PdfService {
  @override
  Future<Result<File>> generatePdf(SavedReport report) async {
    try {
      final pdf = pw.Document();

      // Add pages with report content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            _buildHeader(report),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // Patient Information
            _buildSection('Patient Information', [
              _buildInfoRow('Age', '${report.patientInfo.age} years'),
              _buildInfoRow('Gender', report.patientInfo.gender),
              _buildInfoRow('Weight', report.patientInfo.weightDisplay),
              _buildInfoRow('Height', report.patientInfo.heightDisplay),
              _buildInfoRow('Location', report.patientInfo.location),
              _buildInfoRow('Symptoms', report.patientInfo.symptoms),
              if (report.patientInfo.hasVitals) ...[
                pw.SizedBox(height: 10),
                pw.Text(
                  'Vital Signs:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (report.patientInfo.systolicBP != null)
                  _buildInfoRow(
                    'Blood Pressure',
                    '${report.patientInfo.systolicBP}/${report.patientInfo.diastolicBP} mmHg',
                  ),
                if (report.patientInfo.temperature != null)
                  _buildInfoRow(
                    'Temperature',
                    report.patientInfo.temperatureDisplay!,
                  ),
                if (report.patientInfo.heartRate != null)
                  _buildInfoRow(
                    'Heart Rate',
                    '${report.patientInfo.heartRate} bpm',
                  ),
              ],
            ]),
            pw.SizedBox(height: 20),

            // Diagnosis Results
            _buildSection('Diagnosis Results', [
              _buildInfoRow('Scan Type', report.scanType.displayName),
              _buildInfoRow('Diagnosis', report.diagnosisResult.predictedClass),
              _buildInfoRow(
                'Confidence',
                '${report.diagnosisResult.confidencePercentage.toStringAsFixed(1)}% (${report.diagnosisResult.confidenceLevel})',
              ),
              _buildInfoRow(
                'Analysis Date',
                DateFormat(
                  'MMM dd, yyyy - hh:mm a',
                ).format(report.diagnosisResult.timestamp),
              ),
            ]),
            pw.SizedBox(height: 20),

            // Health Report (if available)
            if (report.healthReport != null) ..._buildHealthReport(report),

            // Disclaimer
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.red, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Medical Disclaimer',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    report.healthReport?.disclaimer ??
                        'This report is generated based on AI analysis and is for informational purposes only. It is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified healthcare providers with any questions regarding medical conditions.',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),

            // Footer
            pw.SizedBox(height: 20),
            pw.Text(
              'Report generated on ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
      );

      // Save PDF to temporary directory
      final tempDir = await getTemporaryDirectory();
      final sanitizedId = report.id.replaceAll(RegExp(r'[^\w\-]'), '_');
      final file = File('${tempDir.path}/medical_report_$sanitizedId.pdf');

      // Write PDF bytes to file
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      // Verify file was written successfully
      if (!await file.exists()) {
        throw Exception('Failed to save PDF file');
      }

      debugPrint('✅ PDF generated successfully: ${file.path}');
      debugPrint('📄 PDF size: ${await file.length()} bytes');

      return Success(file);
    } catch (e, stackTrace) {
      debugPrint('❌ PDF generation error: $e');
      debugPrint('Stack trace: $stackTrace');
      return Failure('Failed to generate PDF: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> sharePdf(File pdfFile, String reportName) async {
    try {
      // Verify file exists and is readable
      if (!await pdfFile.exists()) {
        return Failure('PDF file not found');
      }

      // Verify file has content
      final fileSize = await pdfFile.length();
      if (fileSize == 0) {
        return Failure('PDF file is empty');
      }

      // Create XFile with explicit MIME type
      final xFile = XFile(
        pdfFile.path,
        name: 'medical_report_$reportName.pdf',
        mimeType: 'application/pdf',
      );

      // Get screen size for iOS share sheet positioning
      final size =
          PlatformDispatcher.instance.views.first.physicalSize /
          PlatformDispatcher.instance.views.first.devicePixelRatio;

      // Share the file with proper positioning for iOS
      // Note: We don't await the result as it can hang on some platforms
      Share.shareXFiles(
        [xFile],
        subject: 'Medical Report - $reportName',
        text: 'Medical Analysis Report',
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );

      // Return success immediately after launching share sheet
      debugPrint('✅ Share dialog opened successfully');
      return const Success(null);
    } catch (e, stackTrace) {
      debugPrint('Error sharing PDF: $e');
      debugPrint('Stack trace: $stackTrace');
      return Failure('Failed to share PDF: ${e.toString()}');
    }
  }

  pw.Widget _buildHeader(SavedReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Medical Analysis Report',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Report ID: ${report.id}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red800,
          ),
        ),
        pw.SizedBox(height: 10),
        ...children,
      ],
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildHealthReport(SavedReport report) {
    final healthReport = report.healthReport!;
    return [
      _buildSection('Health Analysis', [
        _buildInfoRow('Condition', healthReport.conditionName),
        _buildInfoRow(
          'Severity',
          '${healthReport.severity.label} - ${healthReport.severityExplanation}',
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Description:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
        pw.Text(
          healthReport.conditionDescription,
          style: const pw.TextStyle(fontSize: 11),
        ),
        if (healthReport.causes.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(
            'Possible Causes:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          ...healthReport.causes.map(
            (cause) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10, top: 2),
              child: pw.Text(
                '• $cause',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
        if (healthReport.progression.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(
            'Progression:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.Text(
            healthReport.progression,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ]),
      pw.SizedBox(height: 15),

      if (healthReport.medications.isNotEmpty) ...[
        _buildSection(
          'Prescribed Medications',
          healthReport.medications
              .map(
                (med) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        med.name,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      _buildInfoRow('Dosage', med.dosage),
                      _buildInfoRow('Frequency', med.frequency),
                      _buildInfoRow('Duration', med.duration),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.treatmentSteps.isNotEmpty) ...[
        _buildSection(
          'Treatment Steps',
          healthReport.treatmentSteps
              .asMap()
              .entries
              .map(
                (entry) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.homeCare.isNotEmpty) ...[
        _buildSection(
          'Home Care',
          healthReport.homeCare
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• $item',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.lifestyleModifications.isNotEmpty) ...[
        _buildSection(
          'Lifestyle Modifications',
          healthReport.lifestyleModifications
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '- $item',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.dietRecommendations.isNotEmpty) ...[
        _buildSection(
          'Diet Recommendations',
          healthReport.dietRecommendations
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• $item',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.exerciseGuidelines.isNotEmpty) ...[
        _buildSection(
          'Exercise Guidelines',
          healthReport.exerciseGuidelines
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• $item',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.restAdvice.isNotEmpty) ...[
        _buildSection(
          'Rest & Recovery',
          healthReport.restAdvice
              .map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• $item',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.specialist.type.isNotEmpty) ...[
        _buildSection('Specialist Recommendation', [
          _buildInfoRow('Specialist Type', healthReport.specialist.type),
          _buildInfoRow('Expertise', healthReport.specialist.expertise),
          _buildInfoRow('Urgency', healthReport.specialist.urgency),
          if (healthReport.nearbyFacilities.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              'Recommended Facilities:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
            pw.SizedBox(height: 6),
            ...healthReport.nearbyFacilities.map(
              (facility) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      facility.name,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (facility.address.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Address: ${facility.address}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    if (facility.phone.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Phone: ${facility.phone}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                    if (facility.specialization.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Specialization: ${facility.specialization}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ]),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.redFlags.isNotEmpty ||
          healthReport.emergencySymptoms.isNotEmpty) ...[
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.red50,
            border: pw.Border.all(color: PdfColors.red, width: 2),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'WARNING - Critical Signs',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 8),
              if (healthReport.redFlags.isNotEmpty) ...[
                pw.Text(
                  'Red Flags:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                ...healthReport.redFlags.map(
                  (flag) => pw.Text(
                    '- $flag',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 8),
              ],
              if (healthReport.emergencySymptoms.isNotEmpty) ...[
                pw.Text(
                  'Seek Immediate Medical Attention If:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                ...healthReport.emergencySymptoms.map(
                  (symptom) => pw.Text(
                    '- $symptom',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 15),
      ],

      if (healthReport.followUpTimeline.isNotEmpty) ...[
        _buildSection('Follow-up Care', [
          _buildInfoRow('Timeline', healthReport.followUpTimeline),
          if (healthReport.followUpSchedule.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Schedule:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            ),
            ...healthReport.followUpSchedule.map(
              (item) =>
                  pw.Text('- $item', style: const pw.TextStyle(fontSize: 11)),
            ),
          ],
        ]),
      ],
    ];
  }
}
