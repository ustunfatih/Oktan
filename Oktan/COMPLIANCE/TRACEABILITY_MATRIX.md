# Traceability Matrix

This document maps each screen to its system components, shell type, and compliance status per the iOS 26 Design Bible.

---

## Component Allowlist

### Approved SwiftUI Primitives

```
NavigationStack, TabView, List, Form, Section, NavigationLink,
Text, Image, Button, Toggle, TextField, SecureField,
DatePicker, Picker, Menu, ProgressView, Label, Divider,
ContentUnavailableView, LabeledContent, Link
```

### Approved Modifiers

```
.navigationTitle(), .navigationBarTitleDisplayMode(),
.listStyle(), .toolbar(), .sheet(), .alert(),
.confirmationDialog(), .searchable(), .swipeActions(),
.accessibilityLabel(), .accessibilityValue(), .accessibilityHint(),
.accessibilityIdentifier(), .accessibilityElement(),
.accessibilityHidden(), .font(), .foregroundStyle(),
.buttonStyle(.borderedProminent), .buttonStyle(.bordered),
.disabled(), .keyboardType(), .textContentType(),
.textInputAutocapitalization(), .autocorrectionDisabled(),
.padding() (NO numeric argument), .background(.ultraThinMaterial)
```

### FORBIDDEN Components/Modifiers

```
.padding(N), .frame(width:), .frame(height:),
.cornerRadius(), .shadow(), RoundedRectangle(cornerRadius:),
LinearGradient, GeometryReader (for layout), ScrollView + VStack (for forms),
.tint(), .accentColor(), Color(hex:), Color(red:green:blue:),
UINavigationBarAppearance, UIAppearance, .toolbarBackground()
```

---

## Screen-to-Component Matrix

### Tab Screens

| Screen | Shell Type | Navigation | System Components | UIKit Bridge | Compliance |
|--------|------------|------------|-------------------|--------------|------------|
| HomeScreen | ListShell | Tab | List, Section, Button, Text, Image, Label, NavigationStack, NavigationLink | None | PARTIAL |
| TrackingScreen | ListShell | Tab | List, Section, ForEach, Button, Label, NavigationStack, .sheet, .swipeActions | None | PARTIAL |
| ReportsScreen | ListShell | Tab | List, Picker, Chart, ProgressView, NavigationStack, Menu, .sheet | None | PARTIAL |
| ProfileScreen | ListShell | Tab | List, Section, Button, Label, Text, Image, NavigationStack, .confirmationDialog | AuthenticationServices | PARTIAL |
| SettingsScreen | ListShell | Tab | List, Section, Picker, Toggle, Button, Link, NavigationStack, NavigationLink, .sheet, .alert | None | PARTIAL |

### Detail/Pushed Screens

| Screen | Shell Type | Navigation | System Components | UIKit Bridge | Compliance |
|--------|------------|------------|-------------------|--------------|------------|
| NotificationSettingsScreen | DetailShell | Push | List, Section, Picker, Toggle, Button, .alert | UserNotifications | PARTIAL |
| DataManagementScreen | DetailShell | Push | List, Section, Button, .sheet, .confirmationDialog | None | COMPLIANT |
| AboutScreen | DetailShell | Sheet | List, Section, Text, Image, Label, .toolbar | None | PARTIAL |

### Modal/Sheet Screens

| Screen | Shell Type | Navigation | System Components | UIKit Bridge | Compliance |
|--------|------------|------------|-------------------|--------------|------------|
| FuelEntryFormScreen | FormShell | Sheet | Form, Section, TextField, DatePicker, Picker, Toggle, Button, .toolbar | UINotificationFeedbackGenerator | PARTIAL |
| CarSelectionScreen | SearchShell | Sheet | List, NavigationStack, NavigationLink, .searchable, .toolbar | None | PARTIAL |
| CarModelSelectionScreen | ListShell | Push | List, NavigationLink | None | COMPLIANT |
| CarYearSelectionScreen | ListShell | Push | List, NavigationLink | None | COMPLIANT |
| CarConfirmationScreen | FormShell | Push | Form, Section, TextField, Button, ProgressView, LabeledContent | UINotificationFeedbackGenerator | PARTIAL |
| CSVImportScreen | FormShell | Sheet | Form, List, Section, Picker, Toggle, Button, ProgressView, .fileImporter, .toolbar | UniformTypeIdentifiers | PARTIAL |
| PaywallScreen | N/A | Sheet | RevenueCatUI.PaywallView | RevenueCat | EXEMPT |
| SplashScreen | N/A | Overlay | ZStack, GeometryReader, Text, Image | None | NON-COMPLIANT |

---

## Violation Details Per Screen

### HomeScreen

**Current Components:**
```swift
NavigationStack, List, Section, VStack, HStack, Spacer,
Image, Text, Button, Label, Divider,
ContentUnavailableView, ForEach
```

**VIOLATIONS:**
| Component/Modifier | Line | Issue |
|--------------------|------|-------|
| None | - | All violations fixed |

**Status:** ✅ ListShell implemented, all violations fixed

---

### TrackingScreen

**Current Components:**
```swift
NavigationStack, List, Section, Text, ForEach,
VStack, HStack, Spacer, Label, Button,
ContentUnavailableView, .swipeActions, .sheet,
.confirmationDialog, .toolbar
```

**VIOLATIONS:**
| Component/Modifier | Line | Issue |
|--------------------|------|-------|
| None | - | All violations fixed |

**Status:** ✅ ListShell implemented, state restoration via RootScaffold

---

### ReportsScreen

**Current Components:**
```swift
NavigationStack, List, Picker, Chart (BarMark, LineMark, AreaMark, PointMark, RuleMark),
Text, Image, Button, Menu, ProgressView, HStack, Spacer, ForEach
```

**VIOLATIONS:**
| Component/Modifier | Line | Issue |
|--------------------|------|-------|
| None | - | All violations fixed |

**Status:** ✅ ListShell implemented, all DesignSystem references removed, system colors used

---

### ProfileScreen

**Current Components:**
```swift
NavigationStack, List, Section, VStack, HStack,
Text, Image, Label, Button, ProgressView,
.confirmationDialog
```

**VIOLATIONS:**
| Component/Modifier | Line | Issue |
|--------------------|------|-------|
| None | - | All violations fixed |

**Status:** ✅ ListShell implemented, all violations fixed

---

### SettingsScreen

**Current Components:**
```swift
NavigationStack, List, Section, Picker, Toggle,
Button, Link, Label, Text, HStack,
NavigationLink, .sheet, .alert
```

**VIOLATIONS:**
| Component/Modifier | Line | Issue |
|--------------------|------|-------|
| None | - | All violations fixed |

**Status:** ✅ ListShell implemented, AboutView uses DetailShell, all violations fixed

---

### ChartComponents.swift

**VIOLATIONS (CRITICAL - 60+ issues):**

| Pattern | Count | Issue |
|---------|-------|-------|
| DesignSystem.Spacing.* | 25+ | Numeric spacing |
| DesignSystem.ColorPalette.* | 35+ | Hex colors |
| .frame(height: N) | 8 | Fixed heights |
| .cornerRadius(N) | 3 | Numeric radius |
| LinearGradient | 1 | Custom gradient |
| GeometryReader | 2 | Layout |
| .glassCard() | 6 | Custom modifier |

**Required Changes:**
1. Complete rewrite removing all numeric values
2. Use List with Section for organization
3. Use system colors only
4. Remove .glassCard() custom modifier

---

### MetricCard.swift

**Current Components:**
```swift
VStack, Label, Text, .background(), .clipShape()
```

**VIOLATIONS:**
| Component/Modifier | Line | Issue |
|--------------------|------|-------|
| VStack(..., spacing: 8) | 11 | Numeric spacing |
| .padding() | 26 | OK |
| Color(uiColor: .secondarySystemGroupedBackground) | 27 | OK |
| RoundedRectangle(cornerRadius: 12) | 28 | Numeric radius |

**Required Changes:**
1. Remove VStack spacing -> Use default
2. Remove RoundedRectangle -> Use .background(.fill)

---

## Shell Assignment Summary

| Shell Type | Screens |
|------------|---------|
| **ListShell** | HomeScreen, TrackingScreen, ReportsScreen, ProfileScreen, SettingsScreen, CarModelSelectionScreen, CarYearSelectionScreen |
| **FormShell** | FuelEntryFormScreen, CarConfirmationScreen, CSVImportScreen |
| **SearchShell** | CarSelectionScreen |
| **DetailShell** | NotificationSettingsScreen, DataManagementScreen, AboutScreen |
| **N/A** | PaywallScreen (RevenueCat), SplashScreen (special) |

---

## UIKit Bridging Justification

| Screen | UIKit Component | Justification |
|--------|-----------------|---------------|
| ProfileScreen | AuthenticationServices | Sign in with Apple requires ASAuthorizationController |
| FuelEntryFormScreen | UINotificationFeedbackGenerator | Haptic feedback on save |
| CarConfirmationScreen | UINotificationFeedbackGenerator | Haptic feedback on save |
| NotificationSettingsScreen | UserNotifications | Local notification scheduling |
| CSVImportScreen | UniformTypeIdentifiers | File type identification |

All UIKit bridging is for system APIs that have no SwiftUI equivalent. No custom UIKit views are implemented.

---

## Compliance Summary

| Status | Count | Screens |
|--------|-------|---------|
| COMPLIANT | 2 | CarModelSelectionScreen, CarYearSelectionScreen, DataManagementScreen |
| PARTIAL | 11 | HomeScreen, TrackingScreen, ReportsScreen, ProfileScreen, SettingsScreen, NotificationSettingsScreen, FuelEntryFormScreen, CarSelectionScreen, CarConfirmationScreen, CSVImportScreen, AboutScreen |
| NON-COMPLIANT | 1 | SplashScreen (special case - overlay screen) |
| EXEMPT | 1 | PaywallScreen (third-party) |

**Total: 16 screens audited**

**Progress:** All major screens now use Shell wrappers and have state restoration implemented. Remaining work: accessibility testing and dynamic type verification.
