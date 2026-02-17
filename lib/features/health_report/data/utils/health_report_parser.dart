import 'dart:convert';
import 'package:ai_medical_app/features/health_report/domain/entities/health_report.dart';

/// Custom exceptions for health report parsing
class HealthReportParseException implements Exception {
  final String message;
  final String? details;

  HealthReportParseException(this.message, [this.details]);

  @override
  String toString() =>
      'HealthReportParseException: $message${details != null ? '\nDetails: $details' : ''}';
}

class HealthReportValidationException implements Exception {
  final String message;
  final List<String> errors;

  HealthReportValidationException(this.message, this.errors);

  @override
  String toString() =>
      'HealthReportValidationException: $message\nErrors: ${errors.join(', ')}';
}

/// Parses Gemini AI responses into structured HealthReport entities
class HealthReportParser {
  /// Parses the raw Gemini response into a HealthReport object
  ///
  /// Handles JSON extraction from markdown code blocks if present
  /// Returns HealthReportParseException if parsing fails
  static HealthReport parse(String rawResponse) {
    try {
      // Extract JSON from markdown code blocks if present
      final jsonString = _extractJson(rawResponse);

      // Parse JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Create HealthReport from JSON
      return HealthReport.fromJson(jsonData);
    } on FormatException catch (e) {
      throw HealthReportParseException(
        'Invalid JSON format in AI response',
        e.toString(),
      );
    } on TypeError catch (e) {
      throw HealthReportParseException(
        'Unexpected data structure in AI response',
        e.toString(),
      );
    } catch (e) {
      throw HealthReportParseException(
        'Failed to parse AI response',
        e.toString(),
      );
    }
  }

  /// Extracts JSON from various response formats
  ///
  /// Handles:
  /// - Pure JSON responses
  /// - Markdown code blocks (```json...```)
  /// - Mixed text with JSON embedded
  static String _extractJson(String response) {
    // Remove leading/trailing whitespace
    String cleaned = response.trim();

    // Case 1: Response is already valid JSON
    if (_isValidJson(cleaned)) {
      return cleaned;
    }

    // Case 2: JSON wrapped in markdown code blocks
    final codeBlockPattern = RegExp(
      r'```(?:json)?\s*\n?([\s\S]*?)\n?```',
      multiLine: true,
    );
    final codeBlockMatch = codeBlockPattern.firstMatch(cleaned);
    if (codeBlockMatch != null) {
      final extracted = codeBlockMatch.group(1)?.trim() ?? '';
      if (_isValidJson(extracted)) {
        return extracted;
      }
    }

    // Case 3: Look for JSON object in the text
    final jsonObjectPattern = RegExp(r'\{[\s\S]*\}', multiLine: true);
    final jsonMatch = jsonObjectPattern.firstMatch(cleaned);
    if (jsonMatch != null) {
      final extracted = jsonMatch.group(0)?.trim() ?? '';
      if (_isValidJson(extracted)) {
        return extracted;
      }
    }

    // If no valid JSON found, return original and let parser handle the error
    return cleaned;
  }

  /// Checks if a string is valid JSON
  static bool _isValidJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates that the parsed report has required fields
  ///
  /// Throws HealthReportValidationException if critical fields are missing
  static void validateReport(HealthReport report) {
    final errors = <String>[];

    if (report.conditionName.isEmpty) {
      errors.add('Condition name is required');
    }

    if (report.conditionDescription.isEmpty) {
      errors.add('Condition description is required');
    }

    if (report.severityExplanation.isEmpty) {
      errors.add('Severity explanation is required');
    }

    if (report.causes.isEmpty) {
      errors.add('Causes are required');
    }

    if (report.treatmentSteps.isEmpty) {
      errors.add('Treatment steps are required');
    }

    if (report.redFlags.isEmpty) {
      errors.add('Red flags are required');
    }

    if (errors.isNotEmpty) {
      throw HealthReportValidationException(
        'Incomplete health report from AI',
        errors,
      );
    }
  }

  /// Safely parses with validation
  ///
  /// Combines parsing and validation in one step
  static HealthReport parseAndValidate(String rawResponse) {
    final report = parse(rawResponse);
    validateReport(report);
    return report;
  }
}
