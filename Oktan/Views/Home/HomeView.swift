import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var repository: FuelRepository
    @Environment(AppSettings.self) private var settings
    
    // CarRepository: try environment first, fallback to creating new instance
    @Environment(CarRepository.self) private var envCarRepository: CarRepository?
    @Environment(CarRepositorySD.self) private var envCarRepositorySD: CarRepositorySD?
    @State private var localCarRepository: CarRepository?
    
    @State private var isPresentingForm = false
    @State private var isPresentingCarSelection = false
    @State private var refreshID = UUID()
    
    /// The active car repository (from environment or local)
    private var carRepository: CarRepositoryProtocol {
        if let sd = envCarRepositorySD {
            return sd
        }
        if let env = envCarRepository {
            return env
        }
        // Fallback: create local instance
        if localCarRepository == nil {
            localCarRepository = CarRepository()
        }
        return localCarRepository!
    }
    
    private var summary: FuelSummary {
        repository.summary()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    carSection
                        .id(refreshID)
                    heroCard
                    quickStats
                    recentActivity
                    quickAddButton
                }
                .padding(DesignSystem.Spacing.large)
            }
            .background(DesignSystem.ColorPalette.background.ignoresSafeArea())
            .navigationTitle("Home")
            .sheet(isPresented: $isPresentingForm) {
                FuelEntryFormView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isPresentingCarSelection, onDismiss: {
                // Reload the local repository if we're using it
                if localCarRepository != nil {
                    localCarRepository = CarRepository()
                }
                refreshID = UUID()
            }) {
                // Pass a local CarRepository for the legacy case
                CarSelectionView(carRepository: localCarRepository ?? CarRepository())
            }
        }
    }
    
    // MARK: - Car Section
    
    @ViewBuilder
    private var carSection: some View {
        if let car = carRepository.selectedCar {
            carDetailsCard(car)
        } else {
            addCarButton
        }
    }
    
    private func carDetailsCard(_ car: Car) -> some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Car image - displayed as fit, not cropped
            if let imageData = car.imageData, let uiImage = UIImage(data: imageData) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.ColorPalette.glassTint.opacity(0.8),
                                    DesignSystem.ColorPalette.primaryBlue.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(car.year) \(car.make)")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.ColorPalette.label)
                    Text(car.model)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(DesignSystem.ColorPalette.label)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Tank")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                    Text(settings.formatVolume(car.tankCapacity))
                        .font(.headline)
                        .foregroundStyle(DesignSystem.ColorPalette.primaryBlue)
                }
            }
            
            Button(action: { isPresentingCarSelection = true }) {
                Label("Change Car", systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline)
            }
            .tint(DesignSystem.ColorPalette.secondaryLabel)
        }
        .padding(DesignSystem.Spacing.medium)
        .glassCard()
    }
    
    private var addCarButton: some View {
        Button(action: { isPresentingCarSelection = true }) {
            VStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "car.badge.gearshape")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DesignSystem.ColorPalette.primaryBlue, DesignSystem.ColorPalette.deepPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Add Your Car")
                    .font(.headline)
                    .foregroundStyle(DesignSystem.ColorPalette.label)
                
                Text("Set up your car to track fuel efficiency")
                    .font(.subheadline)
                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.large)
            .glassCard()
        }
        .accessibilityIdentifier("add-car-button")
    }
    
    // MARK: - Hero Card
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xsmall) {
                    Text("Total Distance")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text(settings.formatDistance(summary.totalDistance))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.3))
                    .accessibilityHidden(true)
            }
            
            Divider()
                .background(.white.opacity(0.3))
                .accessibilityHidden(true)
            
            HStack(spacing: DesignSystem.Spacing.xlarge) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(settings.formatCost(summary.totalCost))
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fill-ups")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(repository.entries.count)")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(DesignSystem.Spacing.large)
        .background(
            LinearGradient(
                colors: [
                    DesignSystem.ColorPalette.primaryBlue,
                    DesignSystem.ColorPalette.deepPurple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        .shadow(color: DesignSystem.ColorPalette.primaryBlue.opacity(0.3), radius: 12, x: 0, y: 6)
        // Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Fuel summary")
        .accessibilityValue("Total distance \(settings.formatDistance(summary.totalDistance)), total spent \(settings.formatCost(summary.totalCost)), \(repository.entries.count) fill-ups")
        .accessibilityIdentifier(AccessibilityID.homeHeroCard)
    }
    
    // MARK: - Quick Stats
    
    private var quickStats: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Efficiency")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DesignSystem.ColorPalette.label)
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                StatCard(
                    title: "Average",
                    value: summary.averageLitersPer100KM.map { settings.formatEfficiency($0) } ?? "—",
                    subtitle: "all time",
                    icon: "gauge.with.needle",
                    color: DesignSystem.ColorPalette.successGreen
                )
                
                StatCard(
                    title: "Recent",
                    value: summary.recentAverageLitersPer100KM.map { settings.formatEfficiency($0) } ?? "—",
                    subtitle: "last 5 fill-ups",
                    icon: "clock.arrow.circlepath",
                    color: DesignSystem.ColorPalette.warningOrange
                )
            }
        }
    }
    
    // MARK: - Recent Activity
    
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Recent Activity")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DesignSystem.ColorPalette.label)
            
            if repository.entries.isEmpty {
                emptyState
            } else {
                VStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(repository.entries.sorted(by: { $0.date > $1.date }).prefix(3)) { entry in
                        RecentEntryRow(entry: entry, settings: settings)
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "fuelpump")
                .font(.system(size: 36))
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
            Text("No entries yet")
                .font(.headline)
            Text("Start tracking your fuel consumption")
                .font(.footnote)
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.large)
        .glassCard()
    }
    
    private var quickAddButton: some View {
        Button(action: { isPresentingForm = true }) {
            Label("Add Fill-up", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.medium)
        }
        .buttonStyle(.borderedProminent)
        .tint(DesignSystem.ColorPalette.primaryBlue)
        .accessibilityIdentifier("home-add-fillup-button")
    }
}

// MARK: - Supporting Views

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
            }
            
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(DesignSystem.ColorPalette.label)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        // Accessibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) efficiency")
        .accessibilityValue("\(value), \(subtitle)")
    }
}

private struct RecentEntryRow: View {
    let entry: FuelEntry
    let settings: AppSettings
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Text(entry.gasStation)
                    .font(.subheadline)
                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(settings.formatCost(entry.totalCost))
                    .font(.headline)
                if let lPer100 = entry.litersPer100KM {
                    Text(settings.formatEfficiency(lPer100))
                        .font(.caption)
                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                }
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.ColorPalette.glassTint.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
        // Accessibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Fill-up on \(AccessibilityHelper.speakableDate(entry.date)) at \(entry.gasStation)")
        .accessibilityValue("\(settings.formatCost(entry.totalCost))" + (entry.litersPer100KM.map { ", efficiency \(settings.formatEfficiency($0))" } ?? ""))
        .accessibilityIdentifier(AccessibilityID.trackingEntryRow)
    }
}

#Preview {
    HomeView()
        .environmentObject(FuelRepository())
        .environment(AppSettings())
}
