import SwiftUI

// MARK: - Accessibility Extensions

extension View {
    /// Adds comprehensive accessibility modifiers for interactive elements
    func accessibleButton(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = .isButton
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
            .accessibilityRemoveTraits(.isImage)
    }
    
    /// Makes a card/container accessible as a group
    func accessibleCard(label: String, value: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityValue(value ?? "")
    }
    
    /// Adds accessibility for a statistic/metric display
    func accessibleStat(label: String, value: String, unit: String? = nil) -> some View {
        let fullValue = unit.map { "\(value) \($0)" } ?? value
        return self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(fullValue)
    }
    
    /// Ensures minimum touch target size (44x44pt per Apple HIG)
    func accessibleTouchTarget(minSize: CGFloat = 44) -> some View {
        self
            .frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }
    
    /// Hides decorative elements from VoiceOver
    func accessibilityDecorative() -> some View {
        self
            .accessibilityHidden(true)
    }
    
    /// Announces a value change for screen readers
    func accessibilityAnnounce(_ announcement: String, when condition: Bool) -> some View {
        self
            .onChange(of: condition) { _, newValue in
                if newValue {
                    UIAccessibility.post(notification: .announcement, argument: announcement)
                }
            }
    }
}

// MARK: - Accessibility Helpers

enum AccessibilityHelper {
    /// Announces a message to VoiceOver users
    static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    /// Announces a screen change (moves focus)
    static func announceScreenChange(_ message: String? = nil) {
        UIAccessibility.post(notification: .screenChanged, argument: message)
    }
    
    /// Announces a layout change
    static func announceLayoutChange(_ element: Any? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: element)
    }
    
    /// Whether VoiceOver is currently running
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    /// Whether the user prefers reduced motion
    static var prefersReducedMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    /// Whether the user prefers bold text
    static var prefersBoldText: Bool {
        UIAccessibility.isBoldTextEnabled
    }
    
    /// Formats a number for speech (e.g., "10.5" -> "10 point 5")
    static func speakableNumber(_ number: Double, decimalPlaces: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        return formatter.string(from: NSNumber(value: number)) ?? String(format: "%.1f", number)
    }
    
    /// Formats a currency value for speech
    static func speakableCurrency(_ amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    /// Formats a date for speech
    static func speakableDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Accessible Number Formatter

struct AccessibleNumberText: View {
    let value: Double
    let format: String
    let unit: String?
    let accessibilityLabel: String
    
    init(_ value: Double, format: String = "%.1f", unit: String? = nil, label: String? = nil) {
        self.value = value
        self.format = format
        self.unit = unit
        self.accessibilityLabel = label ?? String(format: format, value)
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Text(String(format: format, value))
            if let unit {
                Text(unit)
                    .font(.caption)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(unit.map { "\(String(format: format, value)) \($0)" } ?? String(format: format, value))
    }
}

// MARK: - Dynamic Type Scaling

extension View {
    /// Ensures text scales appropriately with Dynamic Type up to a limit
    func dynamicTypeSize(maximum: DynamicTypeSize = .accessibility3) -> some View {
        self.dynamicTypeSize(...maximum)
    }
}

// MARK: - Color Accessibility

extension Color {
    /// Returns a high-contrast version of the color for accessibility
    var highContrast: Color {
        // For now, return self - in a real app, would return adjusted colors
        self
    }
}

// MARK: - Accessibility Identifiers

/// Centralized accessibility identifiers for UI testing
enum AccessibilityID {
    // MARK: - Home
    static let homeCarCard = "home.car.card"
    static let homeAddCarButton = "home.addCar.button"
    static let homeQuickAddButton = "home.quickAdd.button"
    static let homeHeroCard = "home.hero.card"
    
    // MARK: - Tracking
    static let trackingAddButton = "tracking.add.button"
    static let trackingEntryList = "tracking.entry.list"
    static let trackingEntryRow = "tracking.entry.row"
    
    // MARK: - Form
    static let formDatePicker = "form.date.picker"
    static let formLitersField = "form.liters.field"
    static let formPriceField = "form.price.field"
    static let formStationField = "form.station.field"
    static let formSaveButton = "form.save.button"
    static let formCloseButton = "form.close.button"
    
    // MARK: - Reports
    static let reportsExportButton = "reports.export.button"
    static let reportsChart = "reports.chart"
    
    // MARK: - Profile
    static let profileSignInButton = "profile.signIn.button"
    static let profileSignOutButton = "profile.signOut.button"
    static let profileAvatar = "profile.avatar"
    
    // MARK: - Settings
    static let settingsLanguagePicker = "settings.language.picker"
    static let settingsCurrencyPicker = "settings.currency.picker"
    static let settingsDistanceUnitPicker = "settings.distanceUnit.picker"
}
