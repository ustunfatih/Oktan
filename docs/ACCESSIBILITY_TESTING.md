# Accessibility Testing Guide

This guide helps verify that the Oktan app is accessible to all users.

## Quick Testing Checklist

### VoiceOver Testing (iPhone/iPad)

1. **Enable VoiceOver**: Settings → Accessibility → VoiceOver → On
2. Navigate through each screen using swipe gestures
3. Verify:
   - [ ] Every interactive element is announced
   - [ ] Labels are descriptive and helpful
   - [ ] Hints provide context for actions
   - [ ] Decorative images are skipped
   - [ ] Groups of related information are combined logically

### Screen-by-Screen Checklist

#### Home Tab
- [ ] Hero card announces: "Fuel summary" with total distance, spent, and fill-ups
- [ ] Stat cards announce efficiency values with "all time" or "last 5 fill-ups"
- [ ] Recent entries announce date, station, cost, and efficiency
- [ ] Add car button is clearly labeled
- [ ] Quick add button has proper hint

#### Tracking Tab
- [ ] Add fill-up button announces with hint
- [ ] Entry list is navigable
- [ ] Each entry announces full summary
- [ ] Edit button has proper label and hint
- [ ] Delete button warns about permanent action
- [ ] Empty state is described

#### Form
- [ ] All text fields have labels
- [ ] Hints explain what to enter
- [ ] Picker has clear options
- [ ] Save button indicates if disabled
- [ ] Error messages are announced

#### Reports Tab
- [ ] Charts have accessibility summaries
- [ ] Export button is accessible

#### Settings Tab
- [ ] All toggles have labels
- [ ] Pickers are navigable
- [ ] Language/currency changes are announced

### Dynamic Type Testing

1. **Change text size**: Settings → Display & Brightness → Text Size
2. Test at these sizes:
   - [ ] Default
   - [ ] Maximum (Larger Accessibility Sizes → ON → Maximum)
3. Verify:
   - [ ] Text doesn't truncate unexpectedly
   - [ ] Layout adjusts gracefully
   - [ ] Buttons remain tappable

### Touch Target Testing

All interactive elements must have a minimum touch target of 44×44 points.

Quick verification:
1. Try tapping near the edges of buttons
2. Small icons should have expanded hit areas
3. Edit/Delete buttons should be easy to tap

### Color Contrast

- [ ] Text is readable on all backgrounds
- [ ] Status colors (green/orange/red) have sufficient contrast
- [ ] Dark mode maintains readability

### Reduce Motion

1. Enable: Settings → Accessibility → Motion → Reduce Motion
2. Verify:
   - [ ] Animations are simplified or removed
   - [ ] Transitions are instant or fade-based

## Accessibility Identifiers

For UI testing, these identifiers are available:

```swift
// Home
AccessibilityID.homeCarCard
AccessibilityID.homeAddCarButton
AccessibilityID.homeQuickAddButton
AccessibilityID.homeHeroCard

// Tracking
AccessibilityID.trackingAddButton
AccessibilityID.trackingEntryList
AccessibilityID.trackingEntryRow

// Form
AccessibilityID.formDatePicker
AccessibilityID.formLitersField
AccessibilityID.formPriceField
AccessibilityID.formStationField
AccessibilityID.formSaveButton
AccessibilityID.formCloseButton

// Reports
AccessibilityID.reportsExportButton
AccessibilityID.reportsChart

// Profile
AccessibilityID.profileSignInButton
AccessibilityID.profileSignOutButton

// Settings
AccessibilityID.settingsLanguagePicker
AccessibilityID.settingsCurrencyPicker
AccessibilityID.settingsDistanceUnitPicker
```

## Automated Accessibility Testing

Run accessibility audits using XCTest:

```swift
import XCTest

class AccessibilityTests: XCTestCase {
    func testHomeViewAccessibility() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Verify elements are accessible
        XCTAssertTrue(app.otherElements[AccessibilityID.homeHeroCard].exists)
        
        // Perform accessibility audit (iOS 17+)
        try app.performAccessibilityAudit()
    }
}
```

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| Element not announced | Add `.accessibilityLabel()` |
| Missing context | Add `.accessibilityHint()` |
| Too verbose | Use `.accessibilityElement(children: .combine)` |
| Decorative image read | Add `.accessibilityHidden(true)` |
| Small touch target | Add `.frame(minWidth: 44, minHeight: 44)` |
| Text truncates | Use `.dynamicTypeSize(maximum:)` |

## Resources

- [Apple Accessibility Guidelines](https://developer.apple.com/accessibility/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [SwiftUI Accessibility Documentation](https://developer.apple.com/documentation/swiftui/accessibility)
