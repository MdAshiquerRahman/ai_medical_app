import 'package:flutter/foundation.dart';

@immutable
class PatientInfo {
  // Required fields
  final int age;
  final String gender;
  final double weight;
  final String weightUnit; // 'kg' or 'lbs'
  final double height;
  final String heightUnit; // 'cm' or 'ft'
  final String symptoms;
  final String city;
  final String country;

  // Optional fields
  final int? systolicBP;
  final int? diastolicBP;
  final double? temperature;
  final String? temperatureUnit; // 'C' or 'F'
  final int? heartRate;
  final String? medicalHistory;
  final String? allergies;
  final String? currentMedications;

  const PatientInfo({
    required this.age,
    required this.gender,
    required this.weight,
    required this.weightUnit,
    required this.height,
    required this.heightUnit,
    required this.symptoms,
    required this.city,
    required this.country,
    this.systolicBP,
    this.diastolicBP,
    this.temperature,
    this.temperatureUnit,
    this.heartRate,
    this.medicalHistory,
    this.allergies,
    this.currentMedications,
  });

  // Convert height to display string
  String get heightDisplay {
    if (heightUnit == 'cm') {
      return '${height.toStringAsFixed(1)} cm';
    } else {
      final feet = height.floor();
      final inches = ((height - feet) * 12).round();
      return '$feet\'$inches"';
    }
  }

  // Convert weight to display string
  String get weightDisplay => '${weight.toStringAsFixed(1)} $weightUnit';

  // Convert temperature to display string
  String? get temperatureDisplay {
    if (temperature == null) return null;
    return '${temperature!.toStringAsFixed(1)}°${temperatureUnit ?? 'C'}';
  }

  // Get full location
  String get location => '$city, $country';

  // Check if optional fields are filled
  bool get hasOptionalInfo {
    return systolicBP != null ||
        diastolicBP != null ||
        temperature != null ||
        heartRate != null ||
        medicalHistory != null ||
        allergies != null ||
        currentMedications != null;
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'weight': weight,
      'weightUnit': weightUnit,
      'height': height,
      'heightUnit': heightUnit,
      'symptoms': symptoms,
      'city': city,
      'country': country,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'temperature': temperature,
      'temperatureUnit': temperatureUnit,
      'heartRate': heartRate,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'currentMedications': currentMedications,
    };
  }

  factory PatientInfo.fromMap(Map<String, dynamic> map) {
    return PatientInfo(
      age: map['age'] as int,
      gender: map['gender'] as String,
      weight: map['weight'] as double,
      weightUnit: map['weightUnit'] as String,
      height: map['height'] as double,
      heightUnit: map['heightUnit'] as String,
      symptoms: map['symptoms'] as String,
      city: map['city'] as String,
      country: map['country'] as String,
      systolicBP: map['systolicBP'] as int?,
      diastolicBP: map['diastolicBP'] as int?,
      temperature: map['temperature'] as double?,
      temperatureUnit: map['temperatureUnit'] as String?,
      heartRate: map['heartRate'] as int?,
      medicalHistory: map['medicalHistory'] as String?,
      allergies: map['allergies'] as String?,
      currentMedications: map['currentMedications'] as String?,
    );
  }

  PatientInfo copyWith({
    int? age,
    String? gender,
    double? weight,
    String? weightUnit,
    double? height,
    String? heightUnit,
    String? symptoms,
    String? city,
    String? country,
    int? systolicBP,
    int? diastolicBP,
    double? temperature,
    String? temperatureUnit,
    int? heartRate,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
  }) {
    return PatientInfo(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      height: height ?? this.height,
      heightUnit: heightUnit ?? this.heightUnit,
      symptoms: symptoms ?? this.symptoms,
      city: city ?? this.city,
      country: country ?? this.country,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      temperature: temperature ?? this.temperature,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      heartRate: heartRate ?? this.heartRate,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
    );
  }
}
