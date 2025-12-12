import SwiftUI

struct CarSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Support both legacy binding and environment injection
    @Bindable var legacyCarRepository: CarRepository
    @Environment(CarRepositorySD.self) private var envCarRepositorySD: CarRepositorySD?
    
    /// The active car repository
    private var carRepository: CarRepositoryProtocol {
        envCarRepositorySD ?? legacyCarRepository
    }
    
    init(carRepository: CarRepository) {
        self.legacyCarRepository = carRepository
    }
    
    @State private var selectedMake: CarDatabase.CarMake?
    @State private var selectedModel: CarDatabase.CarModel?
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var editableTankCapacity: String = ""
    @State private var step: SelectionStep = .selectMake
    @State private var carImage: UIImage?
    @State private var isGeneratingImage = false
    @State private var searchText: String = ""
    
    private let availableYears: [Int] = Array((2010...Calendar.current.component(.year, from: Date()) + 1).reversed())
    
    enum SelectionStep {
        case selectMake
        case selectModel
        case selectYear
        case confirm
    }
    
    private var filteredMakes: [CarDatabase.CarMake] {
        if searchText.isEmpty {
            return CarDatabase.makes
        }
        return CarDatabase.makes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.ColorPalette.background.ignoresSafeArea()
                
                switch step {
                case .selectMake:
                    makeSelectionView
                case .selectModel:
                    modelSelectionView
                case .selectYear:
                    yearSelectionView
                case .confirm:
                    confirmationView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                if step != .selectMake {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: goBack) {
                            Label("Back", systemImage: "chevron.left")
                        }
                    }
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch step {
        case .selectMake: return "Select Make"
        case .selectModel: return selectedMake?.name ?? "Select Model"
        case .selectYear: return "Select Year"
        case .confirm: return "Confirm"
        }
    }
    
    // MARK: - Make Selection
    
    private var makeSelectionView: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                TextField("Search makes...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                    }
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.ColorPalette.glassTint)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
            .padding(.horizontal, DesignSystem.Spacing.large)
            .padding(.top, DesignSystem.Spacing.medium)
            
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(filteredMakes) { make in
                        Button(action: { selectMake(make) }) {
                            HStack {
                                Text(make.name)
                                    .font(.headline)
                                    .foregroundStyle(DesignSystem.ColorPalette.label)
                                Spacer()
                                Text("\(make.models.count) models")
                                    .font(.subheadline)
                                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                            }
                            .padding(DesignSystem.Spacing.medium)
                            .background(DesignSystem.ColorPalette.glassTint.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                        }
                    }
                }
                .padding(DesignSystem.Spacing.large)
            }
        }
    }
    
    // MARK: - Model Selection
    
    private var modelSelectionView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.small) {
                if let make = selectedMake {
                    ForEach(make.models) { model in
                        Button(action: { selectModel(model) }) {
                            HStack {
                                Text(model.name)
                                    .font(.headline)
                                    .foregroundStyle(DesignSystem.ColorPalette.label)
                                Spacer()
                                if model.tankCapacity > 0 {
                                    Text("\(Int(model.tankCapacity))L")
                                        .font(.subheadline)
                                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                                } else {
                                    Text("Electric")
                                        .font(.subheadline)
                                        .foregroundStyle(DesignSystem.ColorPalette.successGreen)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                            }
                            .padding(DesignSystem.Spacing.medium)
                            .background(DesignSystem.ColorPalette.glassTint.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.large)
        }
    }
    
    // MARK: - Year Selection
    
    private var yearSelectionView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.medium) {
                Text("Select Model Year")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(DesignSystem.ColorPalette.label)
                    .padding(.top, DesignSystem.Spacing.large)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignSystem.Spacing.medium) {
                    ForEach(availableYears, id: \.self) { year in
                        Button(action: { selectYear(year) }) {
                            // Use verbatim to prevent number formatting
                            Text(verbatim: "\(year)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.medium)
                                .background(
                                    year == selectedYear
                                        ? DesignSystem.ColorPalette.primaryBlue
                                        : DesignSystem.ColorPalette.glassTint.opacity(0.5)
                                )
                                .foregroundStyle(
                                    year == selectedYear ? .white : DesignSystem.ColorPalette.label
                                )
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.large)
                
                Button(action: proceedToConfirm) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.ColorPalette.primaryBlue)
                .padding(.horizontal, DesignSystem.Spacing.large)
                .padding(.top, DesignSystem.Spacing.large)
            }
        }
    }
    
    // MARK: - Confirmation
    
    private var confirmationView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                // Car Image
                carImageSection
                
                // Car Details
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    // Use verbatim for year
                    Text(verbatim: "\(selectedYear) \(selectedMake?.name ?? "") \(selectedModel?.name ?? "")")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(DesignSystem.ColorPalette.label)
                    
                    // Tank Capacity
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Tank Capacity")
                            .font(.headline)
                            .foregroundStyle(DesignSystem.ColorPalette.label)
                        
                        HStack {
                            TextField("Liters", text: $editableTankCapacity)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                            
                            Text("liters")
                                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                            
                            Spacer()
                        }
                    }
                    .padding(DesignSystem.Spacing.medium)
                    .glassCard()
                }
                
                // Confirm Button
                Button(action: confirmSelection) {
                    HStack {
                        if isGeneratingImage {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 4)
                        }
                        Text(isGeneratingImage ? "Generating image..." : "Save Car")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.medium)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.ColorPalette.primaryBlue)
                .disabled(isGeneratingImage)
            }
            .padding(DesignSystem.Spacing.large)
        }
    }
    
    private var carImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.ColorPalette.primaryBlue.opacity(0.1),
                            DesignSystem.ColorPalette.deepPurple.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
            
            if let image = carImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
            } else if isGeneratingImage {
                VStack(spacing: DesignSystem.Spacing.small) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Generating car image...")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                }
            } else {
                VStack(spacing: DesignSystem.Spacing.small) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(DesignSystem.ColorPalette.primaryBlue.opacity(0.5))
                    Text("Image will be generated")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func selectMake(_ make: CarDatabase.CarMake) {
        selectedMake = make
        searchText = ""
        withAnimation(.easeInOut(duration: 0.3)) {
            step = .selectModel
        }
    }
    
    private func selectModel(_ model: CarDatabase.CarModel) {
        selectedModel = model
        editableTankCapacity = model.tankCapacity > 0 ? String(Int(model.tankCapacity)) : ""
        withAnimation(.easeInOut(duration: 0.3)) {
            step = .selectYear
        }
    }
    
    private func selectYear(_ year: Int) {
        selectedYear = year
    }
    
    private func proceedToConfirm() {
        withAnimation(.easeInOut(duration: 0.3)) {
            step = .confirm
        }
        
        // Always generate a new image based on the selected year
        generateCarImage()
    }
    
    private func generateCarImage() {
        guard let make = selectedMake, let model = selectedModel else { return }
        
        isGeneratingImage = true
        carImage = nil
        
        Task {
            let imageData = await CarImageService.generateImage(
                make: make.name,
                model: model.name,
                year: selectedYear
            )
            
            await MainActor.run {
                if let data = imageData, let image = UIImage(data: data) {
                    self.carImage = image
                }
                self.isGeneratingImage = false
            }
        }
    }
    
    private func goBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch step {
            case .selectMake:
                break
            case .selectModel:
                step = .selectMake
                selectedMake = nil
            case .selectYear:
                step = .selectModel
                selectedModel = nil
            case .confirm:
                step = .selectYear
                carImage = nil
            }
        }
    }
    
    private func confirmSelection() {
        guard let make = selectedMake, let model = selectedModel else { return }
        
        let tankCapacity = Double(editableTankCapacity) ?? model.tankCapacity
        
        let car = Car(
            make: make.name,
            model: model.name,
            year: selectedYear,
            tankCapacity: tankCapacity,
            imageData: carImage?.pngData()
        )
        
        carRepository.saveCar(car)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

#Preview {
    CarSelectionView(carRepository: CarRepository())
}
