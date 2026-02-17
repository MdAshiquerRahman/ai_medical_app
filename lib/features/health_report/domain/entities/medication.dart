import 'package:flutter/foundation.dart';

@immutable
class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  const Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}
