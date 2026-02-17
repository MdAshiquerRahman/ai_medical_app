import 'package:flutter/foundation.dart';

@immutable
class SpecialistRecommendation {
  final String type;
  final String expertise;
  final String urgency;

  const SpecialistRecommendation({
    required this.type,
    required this.expertise,
    required this.urgency,
  });

  factory SpecialistRecommendation.fromJson(Map<String, dynamic> json) {
    return SpecialistRecommendation(
      type: json['type'] as String? ?? '',
      expertise: json['expertise'] as String? ?? '',
      urgency: json['urgency'] as String? ?? 'routine',
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'expertise': expertise, 'urgency': urgency};
  }
}
