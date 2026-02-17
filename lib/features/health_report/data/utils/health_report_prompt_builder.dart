import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';

class HealthReportPromptBuilder {
  HealthReportPromptBuilder._();

  static String buildSystemInstruction() {
    return '''
You are a medical AI assistant providing comprehensive health analysis based on diagnostic imaging results.

Your role:
1. Analyze the provided diagnosis and patient information
2. Assess severity level objectively based on the diagnosis and confidence
3. Provide evidence-based medical recommendations
4. Suggest appropriate specialists and healthcare facilities
5. Identify warning signs requiring immediate attention
6. Always include medical disclaimers

CRITICAL RULES:
- Be medically accurate and conservative in recommendations
- Never diagnose definitively; always recommend professional consultation
- Use clear, patient-friendly language
- Provide structured, actionable guidance
- Include safety warnings and red flags
- Base severity on diagnosis confidence and condition seriousness
- Return response in VALID JSON format ONLY
- No markdown formatting, no code blocks, just pure JSON
- Ensure all arrays have at least one item
- Be specific and detailed in recommendations
''';
  }

  static String buildUserPrompt({
    required DiagnosisResult diagnosis,
    required PatientInfo patientInfo,
    required ScanType scanType,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Generate a comprehensive health report based on the following information:',
    );
    buffer.writeln();
    buffer.writeln('DIAGNOSTIC ANALYSIS:');
    buffer.writeln('- Scan Type: ${scanType.displayName}');
    buffer.writeln('- Diagnosis: ${diagnosis.predictedClass}');
    buffer.writeln(
      '- Confidence Score: ${diagnosis.confidencePercentage.toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '- Processing Time: ${diagnosis.processingTime.inMilliseconds}ms',
    );
    buffer.writeln();

    buffer.writeln('PATIENT INFORMATION:');
    buffer.writeln('- Age: ${patientInfo.age} years');
    buffer.writeln('- Gender: ${patientInfo.gender}');
    buffer.writeln('- Weight: ${patientInfo.weightDisplay}');
    buffer.writeln('- Height: ${patientInfo.heightDisplay}');
    buffer.writeln('- Location: ${patientInfo.city}, ${patientInfo.country}');
    buffer.writeln('- Current Symptoms: ${patientInfo.symptoms}');
    buffer.writeln();

    if (patientInfo.hasVitals) {
      buffer.writeln('VITAL SIGNS:');
      if (patientInfo.systolicBP != null && patientInfo.diastolicBP != null) {
        buffer.writeln(
          '- Blood Pressure: ${patientInfo.systolicBP}/${patientInfo.diastolicBP} mmHg',
        );
      }
      if (patientInfo.temperature != null) {
        buffer.writeln(
          '- Body Temperature: ${patientInfo.temperature}°${patientInfo.temperatureUnit}',
        );
      }
      if (patientInfo.heartRate != null) {
        buffer.writeln('- Heart Rate: ${patientInfo.heartRate} bpm');
      }
      buffer.writeln();
    }

    if (patientInfo.medicalHistory != null &&
        patientInfo.medicalHistory!.isNotEmpty) {
      buffer.writeln('MEDICAL HISTORY:');
      buffer.writeln(patientInfo.medicalHistory);
      buffer.writeln();
    }

    if (patientInfo.allergies != null && patientInfo.allergies!.isNotEmpty) {
      buffer.writeln('KNOWN ALLERGIES:');
      buffer.writeln(patientInfo.allergies);
      buffer.writeln();
    }

    if (patientInfo.currentMedications != null &&
        patientInfo.currentMedications!.isNotEmpty) {
      buffer.writeln('CURRENT MEDICATIONS:');
      buffer.writeln(patientInfo.currentMedications);
      buffer.writeln();
    }

    buffer.writeln(
      'Please provide a structured health report in the following JSON format:',
    );
    buffer.writeln(getJsonSchema());
    buffer.writeln();
    buffer.writeln(
      'IMPORTANT: Return ONLY the JSON object. No markdown, no code blocks, no additional text.',
    );

    return buffer.toString();
  }

  static String getJsonSchema() {
    return '''{
  "severity": {
    "level": "low|mild|moderate|severe|critical",
    "explanation": "Brief explanation of severity assessment"
  },
  "conditionAnalysis": {
    "name": "Specific condition name",
    "description": "Detailed explanation of the diagnosed condition (3-5 sentences)",
    "causes": ["Potential cause 1", "Potential cause 2", "Potential cause 3"],
    "progression": "Expected progression if untreated (2-3 sentences)"
  },
  "medications": [
    {
      "name": "Generic medication name",
      "dosage": "Recommended dosage (e.g., 500mg)",
      "frequency": "How often to take (e.g., 3 times daily)",
      "duration": "Treatment duration (e.g., 7-10 days)"
    }
  ],
  "treatmentGuidelines": {
    "steps": ["Treatment step 1", "Treatment step 2", "Treatment step 3"],
    "homeCare": ["Home care recommendation 1", "Home care recommendation 2"],
    "lifestyle": ["Lifestyle modification 1", "Lifestyle modification 2"]
  },
  "lifestyleRecommendations": {
    "diet": ["Dietary suggestion 1", "Dietary suggestion 2", "Dietary suggestion 3"],
    "exercise": ["Exercise guideline 1", "Exercise guideline 2"],
    "rest": ["Rest and recovery advice 1", "Rest and recovery advice 2"]
  },
  "specialist": {
    "type": "Type of specialist (e.g., Cardiologist, Pulmonologist, Dermatologist)",
    "expertise": "Specific expertise needed",
    "urgency": "immediate|within_week|routine"
  },
  "nearbyFacilities": [
    {
      "name": "Generic facility name (e.g., Local General Hospital)",
      "specialization": "Specialization area",
      "address": "Suggest checking local facilities in [patient location]",
      "phone": "Contact local directory",
      "type": "doctor|clinic|hospital"
    }
  ],
  "warningSigns": {
    "redFlags": ["Warning sign 1 requiring immediate attention", "Warning sign 2", "Warning sign 3"],
    "emergencySymptoms": ["Emergency symptom 1", "Emergency symptom 2", "Emergency symptom 3"]
  },
  "followUp": {
    "timeline": "When to seek professional consultation (e.g., within 24-48 hours)",
    "schedule": ["Follow-up recommendation 1", "Follow-up recommendation 2"]
  },
  "disclaimer": "This AI-generated report is for informational purposes only and should not replace professional medical advice. Please consult with a qualified healthcare provider for proper diagnosis and treatment. The recommendations provided are general guidelines and may not be suitable for all individuals."
}''';
  }
}
