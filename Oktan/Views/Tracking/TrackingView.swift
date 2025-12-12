import SwiftUI

struct TrackingView: View {
    @EnvironmentObject private var repository: FuelRepository
    @Environment(AppSettings.self) private var settings
    @State private var isPresentingForm = false
    @State private var entryToEdit: FuelEntry?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    header
                    entriesSection
                }
                .padding(DesignSystem.Spacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(DesignSystem.ColorPalette.background.ignoresSafeArea())
            .navigationTitle("Tracking")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isPresentingForm = true }) {
                        Label("Add Fill-up", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .tint(DesignSystem.ColorPalette.primaryBlue)
                    .accessibilityLabel("Add new fill-up")
                    .accessibilityHint("Opens a form to log a new refuel")
                    .accessibilityIdentifier(AccessibilityID.trackingAddButton)
                }
            }
            .sheet(isPresented: $isPresentingForm) {
                FuelEntryFormView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $entryToEdit) { entry in
                FuelEntryFormView(existingEntry: entry)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Log each refuel with a few taps. We calculate distance, efficiency, and cost automatically.")
                .font(.callout)
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Recent fill-ups")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DesignSystem.ColorPalette.label)

            if repository.entries.isEmpty {
                emptyState
            } else {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(repository.entries.sorted(by: { $0.date > $1.date })) { entry in
                        FuelEntryRow(
                            entry: entry,
                            settings: settings,
                            onEdit: { entryToEdit = entry },
                            onDelete: { repository.delete(entry) }
                        )
                    }
                }
                .accessibilityIdentifier(AccessibilityID.trackingEntryList)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "fuelpump")
                .font(.system(size: 48))
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
            Text("No entries yet")
                .font(.headline)
            Text("Tap Add Fill-up to start tracking your fuel efficiency.")
                .font(.footnote)
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

private struct FuelEntryRow: View {
    let entry: FuelEntry
    let settings: AppSettings
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false
    
    /// Accessibility summary for VoiceOver
    private var accessibilitySummary: String {
        var parts: [String] = []
        parts.append("\(AccessibilityHelper.speakableDate(entry.date)) at \(entry.gasStation)")
        parts.append("\(settings.formatVolume(entry.totalLiters)) of fuel")
        parts.append("cost \(settings.formatCost(entry.totalCost))")
        if let distance = entry.distance {
            parts.append("distance \(settings.formatDistance(distance))")
        }
        if let efficiency = entry.litersPer100KM {
            parts.append("efficiency \(settings.formatEfficiency(efficiency))")
        }
        parts.append("\(entry.driveMode.rawValue) mode")
        return parts.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                    Text(entry.gasStation)
                        .font(.subheadline)
                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                }
                Spacer()
                Text(entry.driveMode.rawValue)
                    .font(.caption)
                    .padding(.horizontal, DesignSystem.Spacing.small)
                    .padding(.vertical, 6)
                    .background(driveModeColor.opacity(0.2))
                    .foregroundStyle(driveModeColor)
                    .clipShape(Capsule())
            }

            HStack(spacing: DesignSystem.Spacing.medium) {
                if let distance = entry.distance {
                    valueChip(title: "Distance", value: settings.formatDistance(distance))
                }
                valueChip(title: "Fuel", value: settings.formatVolume(entry.totalLiters))
                Text(settings.formatCost(entry.totalCost))
                    .font(.headline)
                    .foregroundStyle(DesignSystem.ColorPalette.label)
            }

            if let lPer100 = entry.litersPer100KM {
                Text(settings.formatEfficiency(lPer100))
                    .font(.footnote)
                    .foregroundStyle(DesignSystem.ColorPalette.successGreen)
                    .padding(.horizontal, DesignSystem.Spacing.small)
                    .padding(.vertical, 4)
                    .background(DesignSystem.ColorPalette.successGreen.opacity(0.1))
                    .clipShape(Capsule())
            }

            // Action buttons with proper touch targets
            HStack(spacing: DesignSystem.Spacing.medium) {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                        .font(.subheadline)
                }
                .tint(DesignSystem.ColorPalette.primaryBlue)
                .accessibilityLabel("Edit this fill-up")
                .accessibilityHint("Opens editor for this entry")
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())

                Spacer()

                Button(action: { showDeleteConfirmation = true }) {
                    Label("Delete", systemImage: "trash")
                        .font(.subheadline)
                }
                .tint(DesignSystem.ColorPalette.errorRed)
                .accessibilityLabel("Delete this fill-up")
                .accessibilityHint("Removes this entry permanently")
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
            }
            .padding(.top, DesignSystem.Spacing.xsmall)
        }
        .glassCard()
        // Card-level accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Fill-up entry")
        .accessibilityValue(accessibilitySummary)
        .confirmationDialog("Delete this fill-up?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var driveModeColor: Color {
        switch entry.driveMode {
        case .eco: return DesignSystem.ColorPalette.successGreen
        case .normal: return DesignSystem.ColorPalette.primaryBlue
        case .sport: return DesignSystem.ColorPalette.warningOrange
        }
    }

    private func valueChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
            Text(value)
                .font(.headline)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    TrackingView()
        .environmentObject(FuelRepository())
        .environment(AppSettings())
}
