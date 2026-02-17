import 'package:flutter/foundation.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/severity_level.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/medication.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/specialist_recommendation.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/healthcare_facility.dart';

@immutable
class HealthReport {
  final SeverityLevel severity;
  final String severityExplanation;
  final String conditionName;
  final String conditionDescription;
  final List<String> causes;
  final String progression;
  final List<Medication> medications;
  final List<String> treatmentSteps;
  final List<String> homeCare;
  final List<String> lifestyleModifications;
  final List<String> dietRecommendations;
  final List<String> exerciseGuidelines;
  final List<String> restAdvice;
  final SpecialistRecommendation specialist;
  final List<HealthcareFacility> nearbyFacilities;
  final List<String> redFlags;
  final List<String> emergencySymptoms;
  final String followUpTimeline;
  final List<String> followUpSchedule;
  final String disclaimer;
  final DateTime timestamp;

  const HealthReport({
    required this.severity,
    required this.severityExplanation,
    required this.conditionName,
    required this.conditionDescription,
    required this.causes,
    required this.progression,
    required this.medications,
    required this.treatmentSteps,
    required this.homeCare,
    required this.lifestyleModifications,
    required this.dietRecommendations,
    required this.exerciseGuidelines,
    required this.restAdvice,
    required this.specialist,
    required this.nearbyFacilities,
    required this.redFlags,
    required this.emergencySymptoms,
    required this.followUpTimeline,
    required this.followUpSchedule,
    required this.disclaimer,
    required this.timestamp,
  });

  factory HealthReport.fromJson(Map<String, dynamic> json) {
    final severityData = json['severity'] as Map<String, dynamic>? ?? {};
    final conditionData =
        json['conditionAnalysis'] as Map<String, dynamic>? ?? {};
    final treatmentData =
        json['treatmentGuidelines'] as Map<String, dynamic>? ?? {};
    final lifestyleData =
        json['lifestyleRecommendations'] as Map<String, dynamic>? ?? {};
    final specialistData = json['specialist'] as Map<String, dynamic>? ?? {};
    final warningsData = json['warningSigns'] as Map<String, dynamic>? ?? {};
    final followUpData = json['followUp'] as Map<String, dynamic>? ?? {};

    return HealthReport(
      severity: SeverityLevel.fromString(
        severityData['level'] as String? ?? 'moderate',
      ),
      severityExplanation:
          severityData['explanation'] as String? ?? 'No explanation provided',
      conditionName: conditionData['name'] as String? ?? 'Unknown Condition',
      conditionDescription: conditionData['description'] as String? ?? '',
      causes:
          (conditionData['causes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      progression: conditionData['progression'] as String? ?? '',
      medications:
          (json['medications'] as List<dynamic>?)
              ?.map((e) => Medication.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      treatmentSteps:
          (treatmentData['steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      homeCare:
          (treatmentData['homeCare'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lifestyleModifications:
          (treatmentData['lifestyle'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dietRecommendations:
          (lifestyleData['diet'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      exerciseGuidelines:
          (lifestyleData['exercise'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      restAdvice:
          (lifestyleData['rest'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      specialist: SpecialistRecommendation.fromJson(specialistData),
      nearbyFacilities:
          (json['nearbyFacilities'] as List<dynamic>?)
              ?.map(
                (e) => HealthcareFacility.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      redFlags:
          (warningsData['redFlags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      emergencySymptoms:
          (warningsData['emergencySymptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      followUpTimeline: followUpData['timeline'] as String? ?? '',
      followUpSchedule:
          (followUpData['schedule'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      disclaimer:
          json['disclaimer'] as String? ??
          'This is for informational purposes only. Consult a healthcare professional.',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'severity': {'level': severity.name, 'explanation': severityExplanation},
      'conditionAnalysis': {
        'name': conditionName,
        'description': conditionDescription,
        'causes': causes,
        'progression': progression,
      },
      'medications': medications.map((m) => m.toJson()).toList(),
      'treatmentGuidelines': {
        'steps': treatmentSteps,
        'homeCare': homeCare,
        'lifestyle': lifestyleModifications,
      },
      'lifestyleRecommendations': {
        'diet': dietRecommendations,
        'exercise': exerciseGuidelines,
        'rest': restAdvice,
      },
      'specialist': specialist.toJson(),
      'nearbyFacilities': nearbyFacilities.map((f) => f.toJson()).toList(),
      'warningSigns': {
        'redFlags': redFlags,
        'emergencySymptoms': emergencySymptoms,
      },
      'followUp': {'timeline': followUpTimeline, 'schedule': followUpSchedule},
      'disclaimer': disclaimer,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
