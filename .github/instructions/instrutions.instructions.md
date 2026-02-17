---
description: Flutter coding guidelines for AI Medical App
applyTo: '**/*.dart'
---

# AI Medical App - Flutter Coding Guidelines

## Project Context

This is a **mobile-only** Flutter application (iOS & Android) for medical imaging analysis using TensorFlow Lite models for:
- Chest CT Scans
- Chest X-Rays
- MRI Scans
- Skin lesion images

**📋 For complete application architecture, features, and data flow, refer to:**  
[Parent Prompt - Application Overview](.github/prompts/parent-prompt.md)

---

## Current Architecture Overview

### Implemented Structure

```
lib/
├── features/scan_analysis/          # Scan Analysis Feature
│   ├── domain/                      # ← Abstractions (interfaces, entities)
│   │   ├── entities/               # DiagnosisResult, ModelConfig, ScanType
│   │   ├── services/               # MLModelService (abstract)
│   │   ├── preprocessing/          # ImagePreprocessor (abstract)
│   │   └── repositories/           # MLModelRepository (abstract)
│   └── data/                        # ← Implementations (concrete classes)
│       ├── services/               # ChestCTScanModelService, MRIModelService, etc.
│       ├── preprocessing/          # ChestCTScanPreprocessor, MRIPreprocessor, etc.
│       └── repositories/           # MLModelRepositoryImpl
├── common/                          # Shared utilities (not business logic)
│   ├── constants/                  # MLModelConstants, AppConstants
│   ├── errors/                     # Result<T>, Success, Failure, Exceptions
│   └── utils/                      # ModelServiceFactory
├── screens/                         # UI screens (HomeScreen)
├── widgets/                         # Reusable widgets (ModelSelector, PredictionResult)
├── services/                        # Platform services (ImagePickerService)
└── main.dart
```

### Design Patterns Used

1. **Strategy Pattern**: Different ML models as interchangeable strategies
2. **Factory Pattern**: ModelServiceFactory creates strategies based on ScanType
3. **Repository Pattern**: MLModelRepository coordinates model services
4. **Result Pattern**: Type-safe error handling with sealed classes
5. **Dependency Injection**: Constructor injection throughout

### Key Principles

- **Domain-Driven**: Feature bounded by domain/data layers
- **Dependency Inversion**: All dependencies point toward abstractions
- **Single Responsibility**: Each service handles exactly one model type (~100 lines)
- **Strategy Over Conditionals**: No if/switch on model types; factory returns correct strategy

---

## 🔴 PARENT INSTRUCTIONS - CRITICAL REQUIREMENTS

These are **mandatory** guidelines that must be followed throughout the entire application:

### Architecture & Design Principles

#### SOLID Principles
- **S - Single Responsibility**: Each class/function should have one reason to change
  - Services handle only one domain (e.g., `ChestXrayService` only for chest X-rays)
  - Widgets have single, focused responsibilities
  
- **O - Open/Closed**: Open for extension, closed for modification
  - Use abstract classes and interfaces for extensibility
  - Extend behavior through composition, not modification
  
- **L - Liskov Substitution**: Subtypes must be substitutable for base types
  - Derived classes must honor base class contracts
  
- **I - Interface Segregation**: Many specific interfaces over one general interface
  - Create focused abstract classes for different ML model types
  
- **D - Dependency Inversion**: Depend on abstractions, not concretions
  - Inject dependencies through constructors
  - Use abstract classes/interfaces for services

#### Clean Code Principles

1. **DRY (Don't Repeat Yourself)**
   - Extract duplicate code into reusable functions/widgets
   - Create utility functions for common operations
   - Use mixins or extensions for shared behavior
   - NO code duplication across screens or widgets

2. **Low Cyclomatic Complexity**
   - Maximum 5 decision points per function
   - Early returns to reduce nesting
   - Extract complex conditions into named functions
   - Break down complex logic into smaller functions

3. **Low Nested Conditions**
   - Maximum 2-3 levels of nesting
   - Use guard clauses (early returns)
   - Extract nested logic into separate functions
   - Prefer flat code structure

4. **Small Reusable Widgets**
   - Maximum 100-150 lines per widget class
   - Extract sub-widgets when widget tree exceeds 3-4 levels
   - Create widget library for common UI components
   - Single responsibility per widget

5. **Proper Design Patterns**
   - **Repository Pattern**: Data access abstraction
   - **Service Pattern**: Business logic encapsulation
   - **Factory Pattern**: Object creation
   - **Observer Pattern**: State management (Provider/Riverpod)
   - **Strategy Pattern**: ML model selection
   - **Singleton Pattern**: Shared services (use with caution)

### AI Assistant Behavioral Rules

#### ❌ NEVER Do These:

1. **NO Unnecessary Comments**
   - Code should be self-documenting through clear naming
   - Only add comments for:
     - Complex medical algorithms requiring explanation
     - Why decisions were made (not what the code does)
     - Public API documentation (/// doc comments)
   - Remove obvious comments like `// Initialize variable`

2. **NO Unnecessary Logs**
   - No debug prints in production code
   - Only log:
     - Critical errors
     - ML model predictions (for medical audit trail)
     - User authentication events
   - Remove all `print()` statements before committing

3. **NO Markdown Files Without Asking**
   - Do not create README, CHANGELOG, or documentation files unless explicitly requested
   - Focus on code implementation only

4. **NO Example Files**
   - Do not create example or demo files
   - Implement actual production code only
   - No placeholder or sample implementations

#### ✅ ALWAYS Do These:

1. **Plan Before Implementation**
   - Analyze requirements thoroughly
   - Identify reusable components
   - Design class structure before coding
   - Consider edge cases and error scenarios
   - Think about state management approach
   - Present plan to user if complex (>3 files affected)

2. **Mobile-Only Focus**
   - Target iOS and Android only
   - Optimize for mobile performance
   - Consider mobile-specific constraints (memory, processing)
   - Use mobile-appropriate UI patterns
   - No web-specific code or dependencies

---

## Flutter & Dart Best Practices

### 1. Code Structure & Organization

- **Follow feature-first organization**: Organize code by features/modules with clean architecture layers
- **Use modular directory structure**:
  ```
  lib/
  ├── features/                    # Feature modules (modular)
  │   └── scan_analysis/          # Image diagnosis module
  │       ├── domain/             # Business logic layer (abstractions)
  │       │   ├── entities/       # Business objects (ScanType, DiagnosisResult, ModelConfig)
  │       │   ├── services/       # Abstract service interfaces (MLModelService)
  │       │   ├── preprocessing/  # Abstract preprocessor interface (ImagePreprocessor)
  │       │   └── repositories/   # Abstract repository interfaces (MLModelRepository)
  │       └── data/               # Implementation layer (concrete classes)
  │           ├── services/       # Concrete model services (ChestCTScanModelService, etc.)
  │           ├── preprocessing/  # Concrete preprocessors (ChestCTScanPreprocessor, etc.)
  │           └── repositories/   # Concrete repositories (MLModelRepositoryImpl)
  ├── common/                      # Shared utilities (not business logic)
  │   ├── constants/              # App-wide constants (AppConstants, MLModelConstants)
  │   ├── errors/                 # Error handling (Result, Exceptions)
  │   └── utils/                  # Utility classes (ModelServiceFactory)
  ├── screens/                    # UI screens
  ├── widgets/                    # Reusable UI widgets
  ├── services/                   # Platform services (ImagePickerService)
  └── main.dart
  ```
- **Each feature module follows strategy pattern**: 
  - `domain/` contains all abstractions (interfaces, entities)
  - `data/` contains all implementations (concrete classes)
  - Abstractions depend on nothing, implementations depend on abstractions
- **Feature independence**: Features are self-contained with clear boundaries
- **Shared utilities in common**: Only cross-cutting concerns (constants, errors, factories)

### 2. Widget Design Principles

- **Prefer const constructors**: Use const wherever possible for better performance on all static widgets, text, icons, and spacing widgets

- **Small, focused widgets** (CRITICAL):
  - Maximum 100-150 lines per widget class
  - Single responsibility per widget
  - Extract when widget tree exceeds 3-4 levels
  - Create reusable widget library in lib/widgets/
  - Large monolithic widgets with 200+ lines must be split into smaller focused components

- **Widget extraction rules**:
  - If a widget subtree can be named meaningfully, extract it
  - If used in multiple places, it MUST be extracted (DRY)
  - Extract to same file for private widgets (<100 lines)
  - Extract to separate file for reusable/public widgets
  - Use private widgets (_WidgetName) for single-use extractions

- **Use composition over inheritance**: Build complex widgets by combining simpler ones

- **Proper widget naming**:
  - Suffix with widget type: UserProfileCard, ScanResultButton, ImageUploadDialog
  - Use descriptive, self-documenting names: PrimaryActionButton not Button1
  - Boolean-returning widgets: IsLoadingIndicator, HasErrorBanner

### 3. State Management

- **Choose appropriate state management**:
  - Use setState() for simple, local state
  - Use Provider/Riverpod for app-wide state
  - Use StatefulWidget only when necessary

- **Immutable state**: Prefer immutable data structures and models with @immutable annotation, final fields, and const constructors

### 4. Async Operations & Error Handling

- **Use async/await**: Prefer async/await over then/catchError for all asynchronous operations
- **Specific exception handling**: Catch specific exception types first, then generic exceptions
- **Rethrow when appropriate**: Use rethrow to preserve stack traces
- **Handle errors gracefully**: Always provide user-friendly error messages for medical context
- **Use FutureBuilder/StreamBuilder**: For async UI updates
- **Loading states**: Always show loading indicators during async operations
- **Error logging**: Log errors appropriately but never log sensitive patient data

### 5. Clean Code: Reduce Complexity & Nesting

#### Cyclomatic Complexity (Max: 5)

- Maximum 5 decision points per function (if, for, while, case, &&, ||, ?:)
- Use guard clauses (early returns) to flatten conditional logic
- Extract complex conditions into separate named functions or computed properties
- Break down functions with high complexity into smaller focused functions
- Avoid deeply nested if-else chains

#### Reduce Nesting (Max: 2-3 levels)

- Maximum 2-3 levels of nesting in any function or widget build method
- Use early returns to avoid nested conditions
- Extract nested logic into separate functions or widgets
- Prefer flat code structure over pyramid of doom
- Replace nested conditionals with guard clauses that return early

#### Extract Complex Conditions

- Complex multi-part boolean conditions must be extracted into named getters or functions
- Use descriptive names that explain the intent: canAccessMedicalRecords, isValidForProcessing
- Break compound conditions (multiple && or ||) into separate checks
- Use computed properties for reusable conditions
- Make conditionals self-documenting through naming

#### Keep Functions Small (<50 lines)

- Maximum 50 lines per function including whitespace
- Each function should do one thing only (Single Responsibility)
- If a function does multiple steps, break into smaller functions
- Use descriptive function names that explain what they do
- Extract validation, processing, storage, and notification into separate functions

### 6. DRY Principle (Don't Repeat Yourself)

**Every piece of knowledge must have a single, unambiguous representation in the system.**

#### Identify Duplication

- Same validation logic across multiple screens must be extracted to utility classes
- Duplicate file size and format checks must be centralized
- Extract common validation into static utility methods
- Use constants for repeated values (file size limits, allowed formats)
- Create custom exception classes for domain-specific errors

#### Reusable Widgets

- Duplicated UI patterns (cards, buttons, dialogs) must be extracted into reusable widget components
- Create widget library in lib/widgets/ for common UI elements
- Use composition to build variants from base widgets
- Parameterize widgets with required and optional properties
- Apply const constructors to reusable widgets

#### Extension Methods for Common Operations

- Add extension methods on File for common image validation (format, size checks)
- Add extension methods on String for validation (email, phone, etc.)
- Create extension methods for image compression and preprocessing
- Use extensions for type-specific utility operations
- Keep extensions focused and single-purpose

#### Mixins for Shared Behavior

- Use mixins for shared functionality across service classes
- Create ImageProcessingMixin for common image preprocessing logic
- Use mixins for logging, analytics, or validation behaviors
- Share preprocessing, compression, and normalization logic via mixins
- Keep mixins focused on single cross-cutting concerns

#### Configuration Constants

- Centralize all configuration values in constant classes
- Create AppConstants for app-wide settings (limits, thresholds, timeouts)
- Create MLModelConfig for model-specific configurations (input sizes, formats)
- Use const for compile-time constants
- Group related constants into themed classes

### 7. Dependency Injection & SOLID Architecture

**Implement dependency injection for testability and loose coupling.**

#### Constructor Injection (Preferred)

- Inject all dependencies through constructor parameters
- Use required named parameters for mandatory dependencies
- Store dependencies in private final fields
- Never instantiate dependencies directly inside classes (avoid new keyword for services)
- Hard-coded dependencies create tight coupling and prevent testing

#### Abstract Classes for Contracts

- Define abstract classes or interfaces for all service contracts
- Program to interfaces, not concrete implementations
- Create separate abstract classes for MLModelService, ScanRepository, etc.
- Concrete implementations should implement these abstractions
- Use abstract classes to define method contracts without implementation

#### Service Locator (Optional)

- Use Provider or GetIt for dependency management and injection
- Configure dependencies at app startup in main.dart
- Use ProxyProvider for dependencies that depend on other providers
- Use ChangeNotifierProxyProvider for view models that need repository injection
- Centralize dependency configuration for maintainability

#### Separation of Concerns

- Follow layered architecture with clear boundaries:
  - **Presentation Layer** (lib/screens/, lib/widgets/): UI components, no business logic
  - **Domain Layer** (feature/domain/): Business entities, abstract interfaces, use cases
  - **Data Layer** (feature/data/): Concrete implementations, repositories
  - **Infrastructure** (lib/common/): Cross-cutting utilities, constants, error handling
- Dependencies flow inward: UI → Domain ← Data
- Domain layer has no dependencies (pure business logic)
- Data layer implements domain interfaces
- Presentation layer depends only on domain abstractions via repositories

### 8. ML Model Integration

- **Lazy load models**: Load TensorFlow Lite models only when needed, not at app startup
- **Dispose properly**: Always dispose of interpreters and resources in dispose() method
- **Input validation**: Validate image format, size, and quality before ML processing
- **Batch processing**: Handle multiple predictions efficiently if needed
- **Model versioning**: Keep track of model versions in constants for reproducibility
- **Singleton pattern**: Use singleton or factory pattern for model service instances
- **Error handling**: Wrap model loading and prediction in try-catch blocks

### 9. Image Handling

- **Memory management**: 
  - Compress images before processing
  - Dispose of image resources properly
  - Use image caching for repeated access

- **Image preprocessing**:
  - Resize images to model input size
  - Normalize pixel values as required by ML models
  - Handle different image formats consistently

- **Performance**:
  - Use `Image.memory()` for faster rendering when working with bytes
  - Implement image caching strategies
  - Consider using compute() for heavy image processing

### 10. Medical App Specific Guidelines

- **Patient data privacy**:
  - Never log sensitive patient information (NO print statements with patient data)
  - Implement proper data encryption for stored data
  - Follow HIPAA/GDPR guidelines
  - Only log anonymized, aggregated data for debugging

- **Accuracy & Safety**:
  - Always display confidence scores with predictions
  - Include disclaimers that results should be verified by healthcare professionals
  - Implement proper error boundaries for critical medical operations

- **User experience**:
  - Provide clear instructions for image capture/upload
  - Show processing progress for ML inference
  - Enable users to review and confirm inputs before processing

### 11. Performance Optimization

- **Build methods**: Keep build methods pure and fast
  - No complex calculations in build()
  - No async calls in build()
  - Cache expensive computations

- **ListView optimization**: Use ListView.builder for long lists

- **Lazy loading**: Load resources (images, models) on demand

- **Avoid unnecessary rebuilds**:
  - Use const constructors
  - Implement proper shouldRebuild logic in providers
  - Use `RepaintBoundary` for complex widgets

### 12. Code Quality & Complexity Metrics

- **Type safety**: Always specify types, avoid dynamic where possible. Use explicit type declarations for variables and return types.

- **Null safety**: Properly handle null values
  - Use ? for nullable types
  - Use ! only when absolutely certain value is non-null
  - Prefer null-aware operators: ??, ?., ??=

- **Function complexity**:
  - Max cyclomatic complexity: 5
  - Max function length: 50 lines
  - Max parameters: 4 (use parameter objects for more)
  - Early returns to reduce complexity

- **Reduce nesting**: Use guard clauses and early returns. Check for error conditions first and return immediately. Only continue with happy path after all checks.

- **Self-documenting code**:
  - Use descriptive names: calculateConfidenceScore() not calc()
  - Only add doc comments for public APIs
  - No inline comments explaining obvious code
  - Extract complex logic into well-named functions

- **Naming conventions**:
  - Classes: PascalCase (MedicalImageService)
  - Variables/methods: camelCase (scanResult, analyzeScan())
  - Constants: lowerCamelCase with const (const defaultTimeout = 30)
  - Private members: prefix with underscore (_interpreter)
  - Booleans: isLoading, hasError, canPredict

### 13. Testing

- **Unit tests**: Test business logic, services, and utilities
- **Widget tests**: Test individual widgets and their interactions
- **Integration tests**: Test complete user flows including ML model integration
- **Mock dependencies**: Use mockito or mocktail for testing
- **Test ML services**: Mock ML model responses for consistent testing

### 14. Dependencies & Packages

- **Keep dependencies updated**: Regularly check for updates
- **Minimize dependencies**: Only add necessary packages
- **Common packages for this app**:
  - `tflite_flutter` - TensorFlow Lite integration
  - `image_picker` - Image selection
  - `image` - Image manipulation
  - `provider` or `riverpod` - State management
  - `http` or `dio` - HTTP requests (if needed)
  - `shared_preferences` - Local storage

### 15. Mobile Platform Considerations

- **iOS & Android only**: No web, desktop, or other platform code
- **Platform checks**: Use `Platform.isIOS`, `Platform.isAndroid` when needed
- **Responsive design**: Support phones and tablets (various screen sizes)
- **Platform UI**: Material Design for Android, Cupertino for iOS when appropriate
- **Native integration**: Use platform channels efficiently for ML operations
- **Memory constraints**: Optimize for mobile device limitations

### 16. Build & Release

- **Version management**: Update version in pubspec.yaml properly
- **Build configurations**: Separate dev, staging, and production configs
- **Asset optimization**: Compress ML models and images appropriately
- **Flutter clean**: Run `flutter clean` before major builds

## Design Patterns & Code Structure

### Strategy Pattern (ML Model Selection)
- Define abstract strategy interface (MLModelService) in domain layer
- Implement concrete strategies for each model type (ChestCTScanModelService, MRIModelService, etc.)
- Each strategy encapsulates one algorithm (model loading, preprocessing, inference)
- Strategies are interchangeable and follow same contract
- Client code (Repository) works with abstraction, not concrete strategies
- Use Factory to create appropriate strategy based on ScanType

### Factory Pattern (Object Creation)
- Centralize object creation logic in ModelServiceFactory
- Factory creates concrete strategies based on ScanType enum
- Use static factory methods for simplicity
- Factory encapsulates instantiation logic
- Enables adding new strategies without modifying client code
- Located in common/utils/ as it's shared infrastructure

### Repository Pattern (Data Layer)
- Create abstract repository interfaces defining data operations
- Implement concrete repositories that coordinate multiple services
- Repository manages current model service lifecycle (load, analyze, dispose)
- Methods should return domain models wrapped in Result type
- Handle caching and data persistence within repository
- Repository provides clean API to presentation layer

### Service Pattern (Business Logic)
- Define abstract service interfaces for business operations (MLModelService)
- Implement concrete services for specific domains (ChestCTScanModelService, MRIModelService)
- Services handle model initialization, preprocessing, inference, and disposal
- Use lazy initialization pattern for expensive resources (TFLite interpreters)
- Implement proper resource cleanup in dispose methods
- Services should be stateless where possible
- Each service is ~100-120 lines, focused on single model type

### Result Pattern (Error Handling)
- Use sealed classes to represent operation results (Result<T>, Success<T>, Failure<T>)
- Define Success and Failure states explicitly with pattern matching
- Include error messages and optional exceptions in Failure states
- Avoid throwing exceptions for expected error cases
- Use Result type for all operations that can fail predictably
- Pattern matching on sealed classes ensures all cases handled
- Located in common/errors/ for reuse across features

### State Management Pattern
- Use StatefulWidget for screens with local state
- Inject repository dependencies via constructor or instantiate in State
- Store loading, error, and data states in State class
- Use setState() to trigger UI updates after async operations
- Handle Result types with switch/pattern matching
- Keep state management simple for small-to-medium complexity features
- For complex state, consider Provider/Riverpod with ChangeNotifier

## AI Assistant Workflow

### Before Writing Any Code:

1. **Analyze & Plan**
   - Understand the complete requirement
   - Identify affected files and components
   - Check for existing similar implementations (DRY)
   - Plan the class/widget structure
   - Consider state management approach
   - Identify reusable components
   
2. **Present Plan (if complex)**
   - If changes affect >3 files, outline approach first
   - Explain design pattern choice
   - Identify dependencies and impacts

### When Implementing:

#### ✅ MUST DO:
- Follow SOLID principles in all code
- Keep cyclomatic complexity ≤5 per function
- Keep nesting ≤2-3 levels
- Extract widgets when >100 lines or >3 levels deep
- Use dependency injection
- Apply appropriate design patterns
- Write self-documenting code
- Handle all error cases
- Dispose resources properly
- Use const constructors everywhere possible
- Keep functions small and focused (<50 lines)
- Extract duplicate code into reusable utilities

#### ❌ MUST NOT DO:
- Create markdown documentation files
- Create example or demo files
- Add unnecessary inline comments
- Add debug print statements
- Log sensitive patient data
- Repeat code (DRY violation)
- Create deeply nested conditions
- Write complex functions (high cyclomatic complexity)
- Use dynamic types without justification
- Create large monolithic widgets

### Code Generation Guidelines:

1. **Quality over speed**: Take time to write clean, maintainable code
2. **Mobile-first**: All code must target iOS/Android only
3. **Production-ready**: No placeholder or TODO implementations
4. **Complete implementations**: Finish what you start
5. **Error handling**: Always handle edge cases
6. **Performance**: Consider mobile device constraints
7. **Security**: Protect patient data at all times
8. **Testing**: Write testable code with dependency injection

### When Answering Questions:

- Provide direct, actionable answers
- Reference actual code in the project
- Suggest refactoring for code quality improvements
- Point out SOLID/DRY violations if found
- Recommend design patterns when appropriate
- Consider medical app safety and privacy
- Provide complete, production-ready code only

---

**Remember: These instructions are mandatory for all code in this project. Quality, maintainability, and adherence to principles are paramount.**