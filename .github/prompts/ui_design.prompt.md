---
name: ui_design
description: UI redesign tasks for AI Medical App with tabbed navigation and improved user flow
---

# AI Medical App - UI Design Tasks

## Overview
Complete UI redesign with bottom tab navigation, improved scan workflow, comprehensive patient information form, and results display.

---

## TASK 1: TabBar Navigation Implementation

**Objective:** Create floating rounded bottom tab bar with Home and History tabs

**Requirements:**
- Bottom navigation bar with 2 tabs:
  - **Home Tab**: Scan analysis workflow
  - **History Tab**: Past reports list
- Design style: Floating, rounded corners
- Visual design:
  - Dark background (#121212)
  - Active tab: Medical red (#DC143C)
  - Inactive tab: Grey
  - Icon + label for each tab
  - Smooth tab switching animation
- TabBar should be persistent across Home and History screens
- Use BottomNavigationBar or custom floating widget

**Implementation Notes:**
- Main widget will use Scaffold with bottomNavigationBar
- currentIndex state to track active tab
- Show HomeScreen or HistoryScreen based on selected tab
- Floating effect: Use Container with margin and BorderRadius
- Keep tab bar visible at all times

---

## TASK 2: Home Screen - Diagnosis Type Selector

**Objective:** Create home screen with dropdown to select diagnosis type and initiate scan

**Requirements:**
- Dropdown/selector for 4 scan types:
  1. Chest X-Ray
  2. Chest CT Scan
  3. MRI Scan
  4. Skin Lesion
- Display selected scan type prominently
- Brief description of selected scan type
- "Select Image" button to proceed
- Medical disclaimer card at bottom

**UI Components:**
- DropdownButton or custom dropdown widget
- Each option shows icon + name
- Description text updates based on selection
- Large, clear "Select Image" CTA button
- Disabled state until scan type selected

**Design:**
- Clean, minimal layout
- Large touch targets (min 44x44pt)
- Clear visual hierarchy
- Medical professional aesthetic

---

## TASK 3: Camera Preview Screen

**Objective:** Custom camera preview screen with capture and gallery selection

**Requirements:**
- Full-screen camera preview
- Controls:
  - **Center bottom**: Circular capture button (large, 70x70pt)
  - **Left of capture button**: Gallery selection icon button
  - **Top**: Back button and scan type label
- Camera functionality:
  - Access device camera
  - Live preview
  - Focus tap gesture
  - Flash toggle (optional)
- Gallery selection:
  - Opens image picker
  - Supports JPG/PNG only
  - Max file size: 10MB
  - Returns to preview with selected image

**Implementation:**
- Use `camera` package for camera access
- Use `image_picker` package for gallery
- Validate image format and size
- Show error messages for invalid images
- Handle camera permissions gracefully

**Navigation:**
- From Home screen → Camera preview
- After capture/selection → Patient info form (with image)

**UI Design:**
- Dark overlay on camera preview
- White capture button with red accent
- Clear, minimal controls
- Loading indicator during image processing

---

## TASK 4: Patient Information Form Screen

**Objective:** Comprehensive form to collect patient data for AI health report

**Requirements:**
## Diagnosis Type Display:
- Show predicted diagnosis from ML model at top
- Include confidence score (e.g., "Pneumonia - 85% confidence")
- and close predicted diesese name along with the actual desease name in the report. 
### Required Fields (Must be completed):
1. **Age** (TextField, number input, 1-120 years)
2. **Gender** (Dropdown: Male/Female/Other/Prefer not to say)
3. **Weight** (TextField with unit toggle: kg or lbs)
4. **Height** (TextField with unit toggle: cm or feet/inches)
5. **Current Symptoms** (TextArea, max 500 characters, character counter)
6. **Location** (TextField with auto-detect button: City, Country)

### Optional Fields (Can be skipped):
1. **Blood Pressure** (Two TextFields: Systolic/Diastolic mmHg)
2. **Body Temperature** (TextField with unit toggle: °C or °F)
3. **Heart Rate** (TextField, beats per minute)
4. **Medical History** (TextArea, max 1000 characters, character counter)
5. **Known Allergies** (TextArea: medications or food allergies)
6. **Current Medications** (TextArea: list of current medications)


### Form Features:
- Clearly marked required fields (with asterisk *)
- Inline validation with error messages
- "Skip Optional Fields" toggle/section
- Weight/Height unit conversion hints
- Location auto-detect using device location
- Scroll view for long form
- Sticky "Generate Report" button at bottom

### Validation Rules:
- Age: 1-120 years
- Weight: 1-500 kg or 2-1100 lbs
- Height: 30-250 cm or 1'0"-8'2"
- Symptoms: Max 500 chars
- Medical History: Max 1000 chars
- Location: City and country required if filled
- BP: Systolic 70-200, Diastolic 40-130
- Temperature: 30-45°C or 86-113°F
- Heart Rate: 30-250 bpm

### Form Behavior:
- Save draft automatically (optional)
- Clear form button
- Back button shows "discard changes?" dialog
- Submit disabled until all required fields valid
- Loading indicator during report generation

**Navigation:**
- From Camera preview → Patient form (with captured image)
- After submit → Results/Report screen

**UI Design:**
- Grouped sections: Required, Optional, Actions
- Text fields with labels and hints
- Error messages in red below fields
- Unit toggles as small chips
- Auto-detect button for location with icon
- Character counters for text areas
- Collapsible optional section to reduce visual clutter

---

## TASK 5: Results/Report Screen

**Objective:** Display comprehensive AI-generated health report

**Requirements:**
Create a prompt to generate comprehensive health report based on diagnosis and patient info. 
- Take all the infromation from the Patent information form and the create a prompt which will give the below(Report sections) output in json format.

### Report Sections (from parent-prompt.md):
1. **Severity Assessment Badge** (color-coded: Mild/Moderate/Severe/Critical)
2. **Diagnosed Condition** 
   - Condition name
   - Confidence score (from ML model)
   - Detailed explanation
3. **Condition Analysis**
   - Comprehensive description
   - Potential causes
   - Expected progression if untreated
4. **Medication Recommendations**
   - Suggested medications (generic names)
   - Dosage and frequency
   - Treatment duration
5. **Treatment Guidelines**
   - Step-by-step care instructions
   - Home care recommendations
   - Lifestyle modifications
6. **Lifestyle Recommendations**
   - Dietary suggestions
   - Exercise guidelines
   - Rest and recovery advice
7. **Specialist Recommendation**
   - Type of medical specialist to consult
   - Specific expertise needed
8. **Nearby Healthcare Facilities**
   - Doctors and specialists near patient location
   - Hospitals and clinics
   - Contact information
9. **Warning Signs**
   - Red flags requiring immediate attention
   - Emergency symptoms
10. **Follow-up Timeline**
    - When to seek professional consultation
    - Recommended follow-up schedule
11. **Medical Disclaimer** (prominent, top and bottom)
    - App is for informational purposes only
    - Consult qualified healthcare professional
    - Liability limitations

### Report Features:
- Scrollable view with all sections
- Collapsible/expandable sections
- Print-friendly layout
- Action buttons at bottom:
  - Save to History
  - Export as PDF
  - Share Report
  - Start New Analysis

### Report Display:
- Clean card-based layout
- Section headers with icons
- Color-coded severity badge (top of report)
- Medical disclaimer prominently displayed
- Scanned image thumbnail
- Timestamp and scan type label

**Navigation:**
- From Patient form → Report screen (after AI generation)
- "Start New Analysis" → Returns to Home tab
- "Save" → Adds to History, returns to Home
- Back button → Returns to Home (with save prompt)

**UI Design:**
- Professional medical aesthetic
- Easy-to-read typography (accessibility)
- Color coding: Green (mild), Yellow (moderate), Orange (severe), Red (critical)
- Prominent disclaimer box
- Clear visual hierarchy
- Icons for each section

---

## TASK 6: History Screen Enhancement

**Objective:** Display list of past diagnostic reports with management options

**Requirements:**

### History List:
- Show all saved reports in reverse chronological order (newest first)
- Each list item shows:
  - Scan type icon
  - Date and time
  - Severity badge
  - Diagnosed condition name
  - Thumbnail of scanned image
- Tap to view full report
- Swipe actions: Delete, Share, Export

### Filters:
- Filter by scan type (All/Chest X-Ray/Chest CT/MRI/Skin Lesion)
- Sort by date or severity

### Empty State:
- When no reports exist, show:
  - Icon illustration
  - "No Reports Yet" message
  - "Start your first scan" button → Navigate to Home tab

### Report Management:
- View full report (navigate to read-only report screen)
- Delete report (with confirmation dialog)
- Export as PDF
- Share via email/messaging

**Data Storage:**
- Store reports locally with encryption
- Include: Image, diagnosis, patient info, AI report, timestamp
- No cloud sync (local only)

**Navigation:**
- From any screen → History tab via bottom nav
- Tap report → View report detail screen
- Back → Returns to History list

**UI Design:**
- List view with cards
- Visual distinction between severity levels
- Swipe gestures for quick actions
- Pull to refresh (if needed)
- Search bar (optional, future enhancement)

---

## Implementation Order

1. **TASK 1**: TabBar Navigation (foundation)
2. **TASK 2**: Home Screen with dropdown
3. **TASK 3**: Camera Preview Screen
4. **TASK 4**: Patient Information Form
5. **TASK 5**: Results/Report Screen
6. **TASK 6**: History Screen Enhancement

---

## Design Consistency

### Color Palette:
- Background: #121212 (dark)
- Surface: #1E1E1E
- Card: #2C2C2C
- Primary: #DC143C (medical red)
- Primary Dark: #8B0000
- Success: #4CAF50
- Warning: #FF9800
- Error: #F44336
- Text Primary: #FFFFFF
- Text Secondary: #B0B0B0

### Typography:
- Headings: Bold, 20-24pt
- Body: Regular, 16pt
- Captions: Regular, 14pt
- Use system fonts for readability

### Spacing:
- Standard padding: 16pt
- Card padding: 20pt
- Section spacing: 24pt
- Button height: 56pt minimum

### Border Radius:
- Cards: 16pt
- Buttons: 12pt
- Tab bar: 24pt
- Input fields: 8pt

---

## Accessibility Requirements

- Minimum touch target: 44x44pt
- Support screen readers
- High contrast mode support
- Adjustable text size
- Clear focus indicators
- Descriptive labels for all inputs
- Error messages clearly associated with fields
- Voice input for text fields (optional)

---

## Technical Notes

### Packages Needed:
- `camera`: Camera access and preview
- `image_picker`: Gallery selection
- `path_provider`: Local storage paths
- `pdf`: PDF generation for reports
- `share_plus`: Share functionality
- `geolocator`: Location auto-detect
- `permission_handler`: Camera/location permissions

### State Management:
- Use StatefulWidget for screens with forms
- Consider Provider/Riverpod for global state (scan results, history)
- Form state with validation logic

### Navigation:
- Use Navigator.push/pop for screen transitions
- Pass data between screens via constructor parameters
- Handle back button with confirmation dialogs where needed

### Data Models:
- `DiagnosisResult`: ML model output
- `PatientInfo`: Form data
- `HealthReport`: AI-generated report
- `ScanHistory`: Saved report with metadata

---

## References

- **Parent Prompt**: #file:parent-prompt.prompt.md
- **Instructions**: #file:instrutions.instructions.md
- **Current Theme**: /lib/common/theme/app_theme.dart

Guidelines: 
- Follow the design principles and requirements outlined in the parent prompt and instructions.
- Break the widgets into smaller components where appropriate (e.g., separate widget for patient form, report sections).
- Ensure all UI elements are accessible and meet the specified design criteria.