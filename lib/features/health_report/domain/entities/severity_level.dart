import 'package:flutter/material.dart';

enum SeverityLevel {
  low,
  mild,
  moderate,
  severe,
  critical;

  String get label {
    switch (this) {
      case SeverityLevel.low:
        return 'Low';
      case SeverityLevel.mild:
        return 'Mild';
      case SeverityLevel.moderate:
        return 'Moderate';
      case SeverityLevel.severe:
        return 'Severe';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case SeverityLevel.low:
        return const Color(0xFF4CAF50); // Green
      case SeverityLevel.mild:
        return const Color(0xFF8BC34A); // Light Green
      case SeverityLevel.moderate:
        return const Color(0xFFFF9800); // Orange
      case SeverityLevel.severe:
        return const Color(0xFFFF5722); // Deep Orange
      case SeverityLevel.critical:
        return const Color(0xFFDC143C); // Red
    }
  }

  static SeverityLevel fromString(String value) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'low':
        return SeverityLevel.low;
      case 'mild':
        return SeverityLevel.mild;
      case 'moderate':
        return SeverityLevel.moderate;
      case 'severe':
        return SeverityLevel.severe;
      case 'critical':
        return SeverityLevel.critical;
      default:
        return SeverityLevel.moderate;
    }
  }
}
