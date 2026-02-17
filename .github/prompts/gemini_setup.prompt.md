---
name: gemini_setup
description: Gemini AI integration architecture for health report generation
---

# AI Medical App - Gemini Setup

## Purpose

Integrate Google Gemini AI to generate comprehensive health reports by combining:
- ML diagnosis results (from TensorFlow Lite models)
- Patient information (demographics, symptoms, vitals)
- Return structured JSON response for health recommendations

---

## References

**Read Before Implementation:**
- [parent-prompt.prompt.md](.github/prompts/parent-prompt.prompt.md) - Feature 3: AI Health Report Generation
- [instrutions.instructions.md](.github/instructions/instrutions.instructions.md) - SOLID principles, Clean Architecture
- [ui_design.prompt.md](.github/prompts/ui_design.prompt.md) - TASK 5: Result Screen requirements

---

## Architecture

### Feature Module Structure

Following the existing pattern (`scan_analysis`, `patient_info`), create:

```
lib/
├── features/
│   └── health_report/                    # NEW: Health Report Feature
│       ├── domain/                       # Abstractions
│       │   ├── services/
│       │   │   └── ai_report_service.dart       # Abstract interface
│       │   └── repositories/
│       │       └── health_report_repository.dart # Abstract interface
│       └── data/                         # Implementations
│           ├── services/
│           │   └── gemini_ai_service.dart        # Concrete Gemini API implementation
│           └── repositories/
│               └── health_report_repository_impl.dart
├── common/
│   ├── constants/
│   │   └── gemini_constants.dart         # API config, prompts, timeouts
│   └── errors/
│       └── result.dart                   # Existing: Result<T> pattern
└── presentation/
    └── screens/
        └── result_screen.dart            # Update to display generated report
```

**Note:** Models/entities for `HealthReport`, `SeverityLevel`, etc. will be created later when needed.

---

## Dependency Flow

```
PatientInfoFormScreen (User submits form)
    ↓ calls
HealthReportRepository (abstract interface)
    ↓ implemented by
HealthReportRepositoryImpl (coordinates service)
    ↓ uses
AIReportService (abstract interface)
    ↓ implemented by
GeminiAIService (makes API call)
    ↓ calls
Gemini API (returns JSON response)
    ↓ parses and returns
Result<HealthReport> back to UI
```

---

## Domain Layer (Abstractions)

### AIReportService Interface

**File:** `lib/features/health_report/domain/services/ai_report_service.dart`

**Purpose:** Define contract for AI report generation

**Method:**
- `generateHealthReport()` - Takes diagnosis + patient info, returns Result<HealthReport>
- `isConfigured` - Check if API key is set

**Returns:** `Result<HealthReport>` (Success or Failure)

---

### HealthReportRepository Interface

**File:** `lib/features/health_report/domain/repositories/health_report_repository.dart`

**Purpose:** Define contract for report generation workflow

**Method:**
- `generateReport()` - Orchestrate report generation
- Input: DiagnosisResult, PatientInfo, ScanType
- Output: Result<HealthReport>

---

## Data Layer (Implementations)

### GeminiAIService Implementation

**File:** `lib/features/health_report/data/services/gemini_ai_service.dart`

**Purpose:** Execute Gemini API calls and parse responses

**Package Required:** `google_generative_ai`

**Responsibilities:**
1. Initialize Gemini model with API key
2. Build prompt from diagnosis + patient data
3. Call Gemini API with timeout (30 seconds)
4. Parse JSON response
5. Validate response structure
6. Return Result<HealthReport> (Success/Failure)

**Configuration:**
- Model: `gemini-1.5-pro`
- Temperature: `0.3` (deterministic medical responses)
- Timeout: `30 seconds`
- Response format: JSON

**Error Handling:**
- Network timeout → Return Failure
- Invalid API key → Return Failure
- Malformed JSON → Return Failure
- All errors wrapped in Result<T> pattern

---

### HealthReportRepositoryImpl

**File:** `lib/features/health_report/data/repositories/health_report_repository_impl.dart`

**Purpose:** Coordinate service calls and provide clean API to UI

**Responsibilities:**
1. Validate input data (diagnosis, patient info)
2. Call AIReportService.generateHealthReport()
3. Return result to presentation layer
4. (Optional) Cache/persist reports locally

**Dependencies:**
- Inject `AIReportService` via constructor (Dependency Injection)

---

## Constants & Configuration

### GeminiConstants

**File:** `lib/common/constants/gemini_constants.dart`

**Contents:**
- Model name: `'gemini-1.5-pro'`
- Temperature: `0.3`
- Timeout: `Duration(seconds: 30)`
- System instruction (medical AI prompt)
- JSON schema template for response
- Prompt template builder

---

## Prompt Engineering

### Input Structure (Sent to Gemini)

Build prompt containing:
- **Scan Type:** (Chest X-Ray, CT Scan, MRI, Skin Lesion)
- **Diagnosis:** Predicted class from ML model
- **Confidence Score:** Percentage
- **Patient Demographics:** Age, gender, weight, height, location
- **Symptoms:** User-reported symptoms
- **Optional Vitals:** BP, temperature, heart rate, medical history

### Output Structure (Returned from Gemini)

Request JSON response with:
- Severity assessment (level + explanation)
- Condition analysis
- Medication recommendations
- Treatment guidelines
- Lifestyle recommendations
- Specialist recommendation
- Warning signs
- Follow-up timeline
- Medical disclaimer

---

## API Key Management

**Security:** Never hardcode API keys in source code

**Option 1: Environment Variables**
- Use `flutter_dotenv` package
- Store in `.env` file (add to .gitignore)
- Load at runtime

**Option 2: Backend Proxy (Production)**
- App calls your backend
- Backend calls Gemini API
- API key never exposed to client

---

## Data Flow

### Complete Flow

1. **User Action:** Submits patient information form
2. **UI Layer:** PatientInfoFormScreen calls repository
3. **Repository:** Validates input, calls service
4. **Service:** Builds prompt, calls Gemini API
5. **Gemini API:** Processes request, returns JSON
6. **Service:** Parses JSON, creates HealthReport entity
7. **Repository:** Returns Result<HealthReport>
8. **UI Layer:** Displays report or shows error

### Success Path
```
User submits → Repository.generateReport()
              → Service.generateHealthReport()
              → Gemini API call
              → Parse JSON response
              → Return Success(HealthReport)
              → Navigate to ResultScreen
              → Display report
```

### Error Path
```
User submits → Repository.generateReport()
              → Service.generateHealthReport()
              → API call fails
              → Return Failure("error message")
              → Show error dialog
              → Offer retry option
```

---

## Implementation Steps

### Phase 1: Setup
1. Add `google_generative_ai` package to pubspec.yaml
2. Setup API key storage (.env file)
3. Create folder structure

### Phase 2: Domain Layer
1. Create `AIReportService` interface (abstract class)
2. Create `HealthReportRepository` interface (abstract class)

### Phase 3: Data Layer
1. Implement `GeminiAIService` (concrete class)
   - Initialize Gemini model
   - Implement `generateHealthReport()` method
   - Build prompt from input data
   - Execute API call with timeout
   - Parse JSON response
   - Handle errors
2. Implement `HealthReportRepositoryImpl`
   - Inject AIReportService dependency
   - Implement `generateReport()` method
   - Call service and return result

### Phase 4: Constants
1. Create `GeminiConstants` class
   - API configuration values
   - Prompt templates
   - JSON schema

### Phase 5: UI Integration
1. Update `PatientInfoFormScreen`
   - Instantiate repository
   - Call `generateReport()` on form submit
   - Show loading dialog during generation
2. Handle result
   - Success → Navigate to ResultScreen
   - Failure → Show error with retry

---

## Design Principles

**From instructions.md:**

✅ **Dependency Inversion:** UI depends on repository interface, not concrete implementation

✅ **Single Responsibility:** Each class has one job
- Service: API communication
- Repository: Workflow coordination
- Constants: Configuration

✅ **Strategy Pattern:** Can swap GeminiAIService with other AI services (OpenAI, Claude, etc.)

✅ **Repository Pattern:** Clean separation between data source and business logic

✅ **Result Pattern:** Type-safe error handling (Success/Failure)

✅ **Constructor Injection:** Dependencies injected via constructor

---

## Summary

**What:** Gemini AI generates comprehensive health reports

**How:**
1. Service executes API call to Gemini
2. Repository coordinates the workflow
3. UI receives Result<HealthReport>

**Pattern:** Domain abstractions → Data implementations → UI consumes

**Models/Entities:** Will be created later when implementing report display