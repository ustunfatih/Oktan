# Screen Index

This document lists all screens in the Oktan app with their compliance status per the iOS 26 Design Bible.

---

## Screen Registry

### Tab Screens (Root Level)

| Screen | File | Shell | Entry Point | Navigation | State Restoration | Accessibility | Dynamic Type | Compliance |
|--------|------|-------|-------------|------------|-------------------|---------------|--------------|------------|
| HomeScreen | `Views/Home/HomeView.swift` | ListShell | Tab 0 | Tab | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| TrackingScreen | `Views/Tracking/TrackingView.swift` | ListShell | Tab 1 | Tab | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| ReportsScreen | `Views/Reports/ReportsView.swift` | ListShell | Tab 2 | Tab | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| ProfileScreen | `Views/Profile/ProfileView.swift` | ListShell | Tab 3 | Tab | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| SettingsScreen | `Views/Settings/SettingsView.swift` | ListShell | Tab 4 | Tab | ✅ IMPLEMENTED | Good | Untested | PARTIAL |

### Pushed Screens (Detail)

| Screen | File | Shell | Entry Point | Navigation | State Restoration | Accessibility | Dynamic Type | Compliance |
|--------|------|-------|-------------|------------|-------------------|---------------|--------------|------------|
| NotificationSettingsScreen | `Views/Settings/NotificationSettingsView.swift` | DetailShell | Settings > Reminders | Push | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| DataManagementScreen | `Views/Settings/SettingsView.swift` | DetailShell | Settings > Data | Push | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| AboutScreen | `Views/Settings/SettingsView.swift` | DetailShell | Settings > About | Sheet | N/A | Good | Untested | PARTIAL |

### Sheet Screens (Modal)

| Screen | File | Shell | Entry Point | Navigation | State Restoration | Accessibility | Dynamic Type | Compliance |
|--------|------|-------|-------------|------------|-------------------|---------------|--------------|------------|
| FuelEntryFormScreen | `Views/Tracking/FuelEntryFormView.swift` | FormShell | Home/Tracking + Button | Sheet | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| CarSelectionScreen | `Views/Home/CarSelectionView.swift` | SearchShell | Home > Change Car | Sheet | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| CarModelSelectionScreen | `Views/Home/CarSelectionView.swift` | ListShell | CarSelection > Make | Push | ✅ IMPLEMENTED | Good | Untested | COMPLIANT |
| CarYearSelectionScreen | `Views/Home/CarSelectionView.swift` | ListShell | CarModel > Model | Push | ✅ IMPLEMENTED | Good | Untested | COMPLIANT |
| CarConfirmationScreen | `Views/Home/CarSelectionView.swift` | FormShell | CarYear > Year | Push | ✅ IMPLEMENTED | Good | Untested | PARTIAL |
| CSVImportScreen | `Views/Settings/CSVImportView.swift` | FormShell | Settings > Import | Sheet | MISSING | Partial | Untested | PARTIAL |
| PaywallScreen | `Views/Premium/PaywallView.swift` | N/A (RevenueCat) | Various | Sheet | N/A | RevenueCat | RevenueCat | N/A |
| SplashScreen | `Views/Splash/SplashView.swift` | N/A (Special) | App Launch | Overlay | N/A | Missing | N/A | NON-COMPLIANT |

---

## Screen Details

### HomeScreen

**Purpose:** Dashboard showing car, fuel summary, efficiency metrics, and recent activity.

**Entry Point:** Tab 0 ("Home")

**Navigation Type:** Tab

**State Restoration:**
- [x] Tab selection persisted (via @SceneStorage in RootScaffold)
- [x] Car selection refreshes on appear
- [x] No draft state to persist

**Accessibility Notes:**
- Hero card has combined accessibility element with summary
- Recent entries have proper labels
- Add button has identifier

**Dynamic Type Status:** UNTESTED

**Reduce Motion/Transparency:** NOT IMPLEMENTED

**Violations:**
- None - All violations fixed

---

### TrackingScreen

**Purpose:** List of all fuel entries with add/edit/delete functionality.

**Entry Point:** Tab 1 ("Tracking")

**Navigation Type:** Tab

**State Restoration:**
- [x] Tab selection persisted (via @SceneStorage in RootScaffold)
- [x] Entry list loads from repository

**Accessibility Notes:**
- Good VoiceOver labels on entry rows
- Swipe actions have labels
- Add button has accessibility identifier

**Dynamic Type Status:** UNTESTED

**Violations:**
- None - Shell wrapper implemented

---

### ReportsScreen

**Purpose:** Analytics dashboard with charts and insights.

**Entry Point:** Tab 2 ("Reports")

**Navigation Type:** Tab

**State Restoration:**
- [x] Tab selection persisted (via @SceneStorage in RootScaffold)
- [ ] Selected report tab not persisted (low priority)

**Accessibility Notes:**
- Charts have accessibility labels
- Export button has identifier
- Locked content announces properly

**Dynamic Type Status:** UNTESTED

**Violations:**
- None - All violations fixed, now uses ListShell

---

### ProfileScreen

**Purpose:** User authentication and account management.

**Entry Point:** Tab 3 ("Profile")

**Navigation Type:** Tab

**State Restoration:**
- [x] Tab selection persisted (via @SceneStorage in RootScaffold)
- [x] Authentication state from AuthManager

**Accessibility Notes:**
- Sign in button accessible
- User info properly labeled
- Sign out confirmation uses system dialog

**Dynamic Type Status:** UNTESTED

**Violations:**
- None - All violations fixed

---

### SettingsScreen

**Purpose:** App preferences and configuration.

**Entry Point:** Tab 4 ("Settings")

**Navigation Type:** Tab

**State Restoration:**
- [x] Tab selection persisted (via @SceneStorage in RootScaffold)
- [x] Settings persisted in UserDefaults (OK)

**Accessibility Notes:**
- Standard Form/List structure
- Pickers accessible
- Links properly labeled

**Dynamic Type Status:** UNTESTED

**Violations:**
- None - All violations fixed

---

### FuelEntryFormScreen

**Purpose:** Add or edit fuel entry data.

**Entry Point:** Sheet from Home/Tracking

**Navigation Type:** Sheet (.medium, .large detents)

**State Restoration:**
- [x] Draft entry persisted via @SceneStorage (for new entries only)

**Accessibility Notes:**
- All fields have accessibility labels
- Accessibility identifiers for testing
- Error messages announced

**Dynamic Type Status:** UNTESTED

**Violations:**
- None - FormShell wrapper implemented, draft state persisted

---

### CarSelectionScreen

**Purpose:** Multi-step car selection flow.

**Entry Point:** Sheet from HomeView

**Navigation Type:** Sheet with internal NavigationStack

**State Restoration:**
- [x] Navigation path persisted (via @SceneStorage in RootScaffold)

**Accessibility Notes:**
- Search field accessible
- List items have labels
- Tank capacity announced

**Dynamic Type Status:** UNTESTED

**Violations:**
- None - All violations fixed, SearchShell implemented

---

## Required Actions Per Screen

### Immediate (Must Have Shell) - ✅ COMPLETED

1. ✅ **HomeScreen** -> Wrapped in `ListShell(title: "Home")`
2. ✅ **TrackingScreen** -> Wrapped in `ListShell(title: "Tracking")`
3. ✅ **ReportsScreen** -> Using `ListShell(title: "Reports")`
4. ✅ **ProfileScreen** -> Wrapped in `ListShell(title: "Profile")`
5. ✅ **SettingsScreen** -> Wrapped in `ListShell(title: "Settings")`
6. ✅ **FuelEntryFormScreen** -> Wrapped in `FormShell(title: "Add Fill-up")`
7. ✅ **CarSelectionScreen** -> Wrapped in `SearchShell(title: "Select Make")`
8. ✅ **NotificationSettingsScreen** -> Wrapped in `DetailShell(title: "Reminders")`
9. ✅ **DataManagementScreen** -> Wrapped in `DetailShell(title: "Data Management")`
10. ✅ **AboutScreen** -> Wrapped in `DetailShell(title: "About")`

### State Restoration Required - ✅ COMPLETED

1. ✅ **RootScaffold** -> `@SceneStorage("selectedTab")` implemented
2. ✅ **Navigation paths** -> Persisted via @SceneStorage in RootScaffold
3. ✅ **FuelEntryFormView** -> Draft data persisted via @SceneStorage
4. ⚠️ **ReportsView** -> Selected report tab not persisted (low priority, can be added later)

---

## Compliance Checklist

For each screen to be compliant:

- [ ] Uses approved Shell (ListShell, DetailShell, FormShell, SearchShell)
- [ ] No numeric padding/spacing values
- [ ] No fixed frame dimensions
- [ ] No custom corner radius
- [ ] No custom shadows
- [ ] No hex/RGB colors
- [ ] Uses system colors only
- [ ] State restoration implemented
- [ ] VoiceOver tested and working
- [ ] Largest Dynamic Type tested - no clipping
- [ ] Reduce Motion respected
- [ ] Reduce Transparency respected
- [ ] Swipe-to-go-back works (for pushed screens)
