import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/scan_type.dart';
import 'package:ai_medical_app/features/scan_analysis/domain/entities/diagnosis_result.dart';
import 'package:ai_medical_app/features/patient_info/domain/entities/patient_info.dart';
import 'package:ai_medical_app/features/patient_info/data/validators/patient_form_validator.dart';
import 'package:ai_medical_app/features/health_report/domain/entities/health_report.dart';
import 'package:ai_medical_app/features/health_report/domain/repositories/health_report_repository.dart';
import 'package:ai_medical_app/features/health_report/data/repositories/health_report_repository_impl.dart';
import 'package:ai_medical_app/features/health_report/data/services/gemini_ai_service.dart';
import 'package:ai_medical_app/common/errors/result.dart';
import 'package:ai_medical_app/presentation/widgets/patient_form/diagnosis_display_card.dart';
import 'package:ai_medical_app/presentation/widgets/patient_form/form_text_field.dart';
import 'package:ai_medical_app/presentation/widgets/patient_form/unit_toggle_button.dart';
import 'package:ai_medical_app/presentation/screens/result_screen.dart';

class PatientInfoFormScreen extends StatefulWidget {
  final File imageFile;
  final ScanType scanType;
  final DiagnosisResult diagnosisResult;

  const PatientInfoFormScreen({
    super.key,
    required this.imageFile,
    required this.scanType,
    required this.diagnosisResult,
  });

  @override
  State<PatientInfoFormScreen> createState() => _PatientInfoFormScreenState();
}

class _PatientInfoFormScreenState extends State<PatientInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showOptionalFields = false;
  bool _isSubmitting = false;

  // Health report repository
  late final HealthReportRepository _healthReportRepository;

  @override
  void initState() {
    super.initState();
    // Initialize health report repository with Gemini service
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final geminiService = GeminiAIService(apiKey: apiKey);
    _healthReportRepository = HealthReportRepositoryImpl(
      aiService: geminiService,
    );
  }

  // Required field controllers
  final _ageController = TextEditingController();
  String _selectedGender = 'Male';
  final _weightController = TextEditingController();
  String _weightUnit = 'kg';
  final _heightController = TextEditingController();
  String _heightUnit = 'cm';
  final _symptomsController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  // Optional field controllers
  final _systolicBPController = TextEditingController();
  final _diastolicBPController = TextEditingController();
  final _temperatureController = TextEditingController();
  String _temperatureUnit = 'C';
  final _heartRateController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _symptomsController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _temperatureController.dispose();
    _heartRateController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final patientInfo = PatientInfo(
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        weight: double.parse(_weightController.text.trim()),
        weightUnit: _weightUnit,
        height: double.parse(_heightController.text.trim()),
        heightUnit: _heightUnit,
        symptoms: _symptomsController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        systolicBP: _systolicBPController.text.trim().isEmpty
            ? null
            : int.parse(_systolicBPController.text.trim()),
        diastolicBP: _diastolicBPController.text.trim().isEmpty
            ? null
            : int.parse(_diastolicBPController.text.trim()),
        temperature: _temperatureController.text.trim().isEmpty
            ? null
            : double.parse(_temperatureController.text.trim()),
        temperatureUnit: _temperatureController.text.trim().isEmpty
            ? null
            : _temperatureUnit,
        heartRate: _heartRateController.text.trim().isEmpty
            ? null
            : int.parse(_heartRateController.text.trim()),
        medicalHistory: _medicalHistoryController.text.trim().isEmpty
            ? null
            : _medicalHistoryController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        currentMedications: _medicationsController.text.trim().isEmpty
            ? null
            : _medicationsController.text.trim(),
      );

      // Generate health report using Gemini AI
      final reportResult = await _healthReportRepository.generateReport(
        diagnosis: widget.diagnosisResult,
        patientInfo: patientInfo,
      );

      if (!mounted) return;

      // Handle the result
      if (reportResult is Success<HealthReport>) {
        // Success: Navigate to result screen with health report
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: widget.imageFile,
              scanType: widget.scanType,
              diagnosisResult: widget.diagnosisResult,
              patientInfo: patientInfo,
              healthReport: reportResult.data,
            ),
          ),
        );
      } else if (reportResult is Failure<HealthReport>) {
        // Failure: Show error and optionally navigate without report
        setState(() => _isSubmitting = false);

        final shouldContinue = await _showErrorDialog(
          'Failed to Generate Report',
          reportResult.message,
        );

        if (shouldContinue && mounted) {
          // Continue to result screen without AI report
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                imageFile: widget.imageFile,
                scanType: widget.scanType,
                diagnosisResult: widget.diagnosisResult,
                patientInfo: patientInfo,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  Future<bool> _showErrorDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(
                '$message\n\nWould you like to continue without the AI health report?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _clearForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('Clear Form', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear all fields?',
          style: TextStyle(color: Color(0xFFB0B0B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _ageController.clear();
              _weightController.clear();
              _heightController.clear();
              _symptomsController.clear();
              _cityController.clear();
              _countryController.clear();
              _systolicBPController.clear();
              _diastolicBPController.clear();
              _temperatureController.clear();
              _heartRateController.clear();
              _medicalHistoryController.clear();
              _allergiesController.clear();
              _medicationsController.clear();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFDC143C)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Patient Information'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Diagnosis Display
                  DiagnosisDisplayCard(
                    diagnosisResult: widget.diagnosisResult,
                    scanType: widget.scanType,
                  ),

                  const SizedBox(height: 32),

                  // Required Information Section
                  _buildSectionHeader('Required Information', Icons.assignment),
                  const SizedBox(height: 16),

                  _buildRequiredFields(),

                  const SizedBox(height: 32),

                  // Optional Information Section
                  _buildOptionalSection(),

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _clearForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Clear Form'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC143C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Generate Report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFDC143C), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredFields() {
    return Column(
      children: [
        // Age
        FormTextField(
          label: 'Age',
          hint: 'Enter your age',
          controller: _ageController,
          isRequired: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: PatientFormValidator.validateAge,
        ),
        const SizedBox(height: 20),

        // Gender
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'Gender',
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(
                    color: Color(0xFFDC143C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3C3C3C)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                dropdownColor: const Color(0xFF2C2C2C),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: ['Male', 'Female', 'Other', 'Prefer not to say']
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedGender = value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Weight with unit toggle
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: FormTextField(
                label: 'Weight',
                hint: 'Enter weight',
                controller: _weightController,
                isRequired: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) =>
                    PatientFormValidator.validateWeight(value, _weightUnit),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: UnitToggleButton(
                unit1: 'kg',
                unit2: 'lbs',
                selectedUnit: _weightUnit,
                onUnitChanged: (unit) => setState(() => _weightUnit = unit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Height with unit toggle
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: FormTextField(
                label: 'Height',
                hint: _heightUnit == 'cm'
                    ? 'Enter height in cm'
                    : 'Enter feet (e.g., 5.5 for 5\'6")',
                controller: _heightController,
                isRequired: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) =>
                    PatientFormValidator.validateHeight(value, _heightUnit),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: UnitToggleButton(
                unit1: 'cm',
                unit2: 'ft',
                selectedUnit: _heightUnit,
                onUnitChanged: (unit) => setState(() => _heightUnit = unit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Symptoms
        FormTextField(
          label: 'Current Symptoms',
          hint: 'Describe your symptoms in detail...',
          controller: _symptomsController,
          isRequired: true,
          maxLines: 4,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
          validator: PatientFormValidator.validateSymptoms,
        ),
        const SizedBox(height: 20),

        // Location
        FormTextField(
          label: 'City',
          hint: 'Enter your city',
          controller: _cityController,
          isRequired: true,
          validator: PatientFormValidator.validateCity,
        ),
        const SizedBox(height: 20),

        FormTextField(
          label: 'Country',
          hint: 'Enter your country',
          controller: _countryController,
          isRequired: true,
          validator: PatientFormValidator.validateCountry,
        ),
      ],
    );
  }

  Widget _buildOptionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () =>
              setState(() => _showOptionalFields = !_showOptionalFields),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3C3C3C)),
            ),
            child: Row(
              children: [
                Icon(
                  _showOptionalFields
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFFDC143C),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Optional Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _showOptionalFields ? 'Hide' : 'Show',
                  style: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_showOptionalFields) ...[
          const SizedBox(height: 20),
          _buildOptionalFields(),
        ],
      ],
    );
  }

  Widget _buildOptionalFields() {
    return Column(
      children: [
        // Blood Pressure
        Row(
          children: [
            Expanded(
              child: FormTextField(
                label: 'Systolic BP',
                hint: 'e.g., 120',
                controller: _systolicBPController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: PatientFormValidator.validateSystolicBP,
                suffix: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'mmHg',
                    style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormTextField(
                label: 'Diastolic BP',
                hint: 'e.g., 80',
                controller: _diastolicBPController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: PatientFormValidator.validateDiastolicBP,
                suffix: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'mmHg',
                    style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Temperature
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: FormTextField(
                label: 'Body Temperature',
                hint: 'Enter temperature',
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                validator: (value) => PatientFormValidator.validateTemperature(
                  value,
                  _temperatureUnit,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 22),
              child: UnitToggleButton(
                unit1: '°C',
                unit2: '°F',
                selectedUnit: _temperatureUnit == 'C' ? '°C' : '°F',
                onUnitChanged: (unit) =>
                    setState(() => _temperatureUnit = unit == '°C' ? 'C' : 'F'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Heart Rate
        FormTextField(
          label: 'Heart Rate',
          hint: 'Enter heart rate',
          controller: _heartRateController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: PatientFormValidator.validateHeartRate,
          suffix: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'bpm',
              style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Medical History
        FormTextField(
          label: 'Medical History',
          hint: 'Any relevant medical history...',
          controller: _medicalHistoryController,
          maxLines: 4,
          maxLength: 1000,
          keyboardType: TextInputType.multiline,
          validator: PatientFormValidator.validateMedicalHistory,
        ),
        const SizedBox(height: 20),

        // Allergies
        FormTextField(
          label: 'Known Allergies',
          hint: 'List any allergies to medications or foods...',
          controller: _allergiesController,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 20),

        // Current Medications
        FormTextField(
          label: 'Current Medications',
          hint: 'List any medications you are currently taking...',
          controller: _medicationsController,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
