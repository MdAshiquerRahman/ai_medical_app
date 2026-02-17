class PatientFormValidator {
  PatientFormValidator._();

  // Age validation (1-120 years)
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Please enter a valid number';
    }

    if (age < 1 || age > 120) {
      return 'Age must be between 1 and 120 years';
    }

    return null;
  }

  // Gender validation
  static String? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Gender is required';
    }
    return null;
  }

  // Weight validation (1-500 kg or 2-1100 lbs)
  static String? validateWeight(String? value, String unit) {
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }

    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return 'Please enter a valid number';
    }

    if (unit == 'kg') {
      if (weight < 1 || weight > 500) {
        return 'Weight must be between 1-500 kg';
      }
    } else {
      // lbs
      if (weight < 2 || weight > 1100) {
        return 'Weight must be between 2-1100 lbs';
      }
    }

    return null;
  }

  // Height validation (30-250 cm or 1'0"-8'2")
  static String? validateHeight(String? value, String unit) {
    if (value == null || value.trim().isEmpty) {
      return 'Height is required';
    }

    final height = double.tryParse(value.trim());
    if (height == null) {
      return 'Please enter a valid number';
    }

    if (unit == 'cm') {
      if (height < 30 || height > 250) {
        return 'Height must be between 30-250 cm';
      }
    } else {
      // feet (stored as decimal, e.g., 5.5 = 5'6")
      if (height < 1.0 || height > 8.2) {
        return 'Height must be between 1\'0" and 8\'2"';
      }
    }

    return null;
  }

  // Symptoms validation (required, max 500 chars, min 10 chars)
  static String? validateSymptoms(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Symptoms are required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Please provide at least 10 characters';
    }

    if (trimmed.length > 500) {
      return 'Symptoms must not exceed 500 characters';
    }

    return null;
  }

  // City validation
  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }

    if (value.trim().length < 2) {
      return 'Please enter a valid city name';
    }

    return null;
  }

  // Country validation
  static String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Country is required';
    }

    if (value.trim().length < 2) {
      return 'Please enter a valid country name';
    }

    return null;
  }

  // Blood Pressure validation (optional)
  static String? validateSystolicBP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final bp = int.tryParse(value.trim());
    if (bp == null) {
      return 'Please enter a valid number';
    }

    if (bp < 70 || bp > 200) {
      return 'Systolic BP must be between 70-200 mmHg';
    }

    return null;
  }

  static String? validateDiastolicBP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final bp = int.tryParse(value.trim());
    if (bp == null) {
      return 'Please enter a valid number';
    }

    if (bp < 40 || bp > 130) {
      return 'Diastolic BP must be between 40-130 mmHg';
    }

    return null;
  }

  // Temperature validation (optional, 30-45°C or 86-113°F)
  static String? validateTemperature(String? value, String unit) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final temp = double.tryParse(value.trim());
    if (temp == null) {
      return 'Please enter a valid number';
    }

    if (unit == 'C') {
      if (temp < 30 || temp > 45) {
        return 'Temperature must be between 30-45°C';
      }
    } else {
      // Fahrenheit
      if (temp < 86 || temp > 113) {
        return 'Temperature must be between 86-113°F';
      }
    }

    return null;
  }

  // Heart Rate validation (optional, 30-250 bpm)
  static String? validateHeartRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final hr = int.tryParse(value.trim());
    if (hr == null) {
      return 'Please enter a valid number';
    }

    if (hr < 30 || hr > 250) {
      return 'Heart rate must be between 30-250 bpm';
    }

    return null;
  }

  // Medical History validation (optional, max 1000 chars)
  static String? validateMedicalHistory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (value.trim().length > 1000) {
      return 'Medical history must not exceed 1000 characters';
    }

    return null;
  }

  // Allergies validation (optional)
  static String? validateAllergies(String? value) {
    // No specific validation, just optional text
    return null;
  }

  // Current Medications validation (optional)
  static String? validateCurrentMedications(String? value) {
    // No specific validation, just optional text
    return null;
  }
}
