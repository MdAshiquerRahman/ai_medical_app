import 'package:flutter/foundation.dart';

enum FacilityType {
  doctor,
  clinic,
  hospital;

  static FacilityType fromString(String value) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'doctor':
        return FacilityType.doctor;
      case 'clinic':
        return FacilityType.clinic;
      case 'hospital':
        return FacilityType.hospital;
      default:
        return FacilityType.clinic;
    }
  }
}

@immutable
class HealthcareFacility {
  final String name;
  final String specialization;
  final String address;
  final String phone;
  final FacilityType type;

  const HealthcareFacility({
    required this.name,
    required this.specialization,
    required this.address,
    required this.phone,
    required this.type,
  });

  factory HealthcareFacility.fromJson(Map<String, dynamic> json) {
    return HealthcareFacility(
      name: json['name'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      type: FacilityType.fromString(json['type'] as String? ?? 'clinic'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialization': specialization,
      'address': address,
      'phone': phone,
      'type': type.name,
    };
  }
}
