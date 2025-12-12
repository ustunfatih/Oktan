import SwiftUI
import UniformTypeIdentifiers

struct CSVImportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var repository: FuelRepository
    
    // Import State
    @State private var currentStep: ImportStep = .selectFile
    @State private var parseResult: CSVImportService.ParseResult?
    @State private var fieldMapping = CSVImportService.FieldMapping()
    @State private var previewEntries: [CSVImportService.PreviewEntry] = []
    @State private var importResult: CSVImportService.ImportResult?
    
    // UI State
    @State private var isLoading = false
    @State private var showingFilePicker = false
    @State private var errorMessage: String?
    @State private var skipDuplicates = true
    
    enum ImportStep: Int, CaseIterable {
        case selectFile
        case mapFields
        case preview
        case importing
        case complete
        
        var title: String {
            switch self {
            case .selectFile: return "Select File"
            case .mapFields: return "Map Fields"
            case .preview: return "Preview"
            case .importing: return "Importing"
            case .complete: return "Complete"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Content based on step
                Group {
                    switch currentStep {
                    case .selectFile:
                        selectFileContent
                    case .mapFields:
                        mapFieldsContent
                    case .preview:
                        previewContent
                    case .importing:
                        importingContent
                    case .complete:
                        completeContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(DesignSystem.ColorPalette.background)
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.commaSeparatedText, .csv],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            ForEach(ImportStep.allCases, id: \.self) { step in
                if step.rawValue > 0 {
                    Rectangle()
                        .fill(step.rawValue <= currentStep.rawValue ? DesignSystem.ColorPalette.primaryBlue : DesignSystem.ColorPalette.secondaryLabel.opacity(0.3))
                        .frame(height: 2)
                }
                
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? DesignSystem.ColorPalette.primaryBlue : DesignSystem.ColorPalette.secondaryLabel.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .overlay {
                        if step.rawValue < currentStep.rawValue {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xlarge)
        .padding(.vertical, DesignSystem.Spacing.medium)
    }
    
    // MARK: - Step 1: Select File
    
    private var selectFileContent: some View {
        VStack(spacing: DesignSystem.Spacing.xlarge) {
            Spacer()
            
            Image(systemName: "doc.text.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DesignSystem.ColorPalette.primaryBlue, DesignSystem.ColorPalette.deepPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: DesignSystem.Spacing.small) {
                Text("Import from CSV")
                    .font(.title.weight(.bold))
                    .foregroundStyle(DesignSystem.ColorPalette.label)
                
                Text("Select a CSV file containing your fuel records. We'll help you map the columns to the correct fields.")
                    .font(.body)
                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xlarge)
            }
            
            Button(action: { showingFilePicker = true }) {
                Label("Choose File", systemImage: "folder")
                    .font(.headline)
                    .frame(minWidth: 200)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignSystem.ColorPalette.primaryBlue)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(DesignSystem.ColorPalette.errorRed)
                    .padding()
            }
            
            // Sample format info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                Text("Supported columns:")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                
                Text("Date, Odometer Start, Odometer End, Liters, Price per Liter, Station, Drive Mode, Full Refill, Notes")
                    .font(.caption)
                    .foregroundStyle(DesignSystem.ColorPalette.tertiaryLabel)
            }
            .padding()
            .background(DesignSystem.ColorPalette.glassTint)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Step 2: Map Fields
    
    private var mapFieldsContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.large) {
                // File info
                if let result = parseResult {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(DesignSystem.ColorPalette.primaryBlue)
                        Text("\(result.totalRows) rows found")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .background(DesignSystem.ColorPalette.glassTint)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                }
                
                // Required fields
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("Required Fields")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.ColorPalette.label)
                    
                    FieldMappingRow(
                        label: "Date",
                        isRequired: true,
                        selectedColumn: $fieldMapping.dateColumn,
                        headers: parseResult?.headers ?? []
                    )
                    
                    FieldMappingRow(
                        label: "Liters",
                        isRequired: true,
                        selectedColumn: $fieldMapping.litersColumn,
                        headers: parseResult?.headers ?? []
                    )
                    
                    FieldMappingRow(
                        label: "Price per Liter",
                        isRequired: true,
                        selectedColumn: $fieldMapping.pricePerLiterColumn,
                        headers: parseResult?.headers ?? []
                    )
                }
                .glassCard()
                
                // Optional fields
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("Optional Fields")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.ColorPalette.label)
                    
                    FieldMappingRow(
                        label: "Odometer Start",
                        isRequired: false,
                        selectedColumn: $fieldMapping.odometerStartColumn,
                        headers: parseResult?.headers ?? []
                    )
                    
                    FieldMappingRow(
                        label: "Odometer End",
                        isRequired: false,
                        selectedColumn: $fieldMapping.odometerEndColumn,
                        headers: parseResult?.headers ?? []
                    )
                    
                    FieldMappingRow(
                        label: "Gas Station",
                        isRequired: false,
                        selectedColumn: $fieldMapping.gasStationColumn,
                        headers: parseResult?.headers ?? []
                    )
                    
                    FieldMappingRow(
                        label: "Drive Mode",
                        isRequired: false,
                        selectedColumn: $fieldMapping.driveModeColumn,
                        headers: parseResult?.headers ?? []
                    )
                    
                    FieldMappingRow(
                        label: "Notes",
                        isRequired: false,
                        selectedColumn: $fieldMapping.notesColumn,
                        headers: parseResult?.headers ?? []
                    )
                }
                .glassCard()
                
                // Import options
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("Options")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.ColorPalette.label)
                    
                    Picker("Date Format", selection: $fieldMapping.dateFormat) {
                        Text("YYYY-MM-DD").tag("yyyy-MM-dd")
                        Text("DD/MM/YYYY").tag("dd/MM/yyyy")
                        Text("MM/DD/YYYY").tag("MM/dd/yyyy")
                        Text("DD.MM.YYYY").tag("dd.MM.yyyy")
                    }
                    
                    Toggle("Comma as decimal separator (1,5 instead of 1.5)", isOn: $fieldMapping.useCommaDecimal)
                    
                    Toggle("Skip duplicate entries (same date)", isOn: $skipDuplicates)
                }
                .glassCard()
                
                // Continue button
                Button(action: generatePreview) {
                    Text("Preview Import")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.ColorPalette.primaryBlue)
                .disabled(!fieldMapping.isValid)
            }
            .padding(DesignSystem.Spacing.large)
        }
    }
    
    // MARK: - Step 3: Preview
    
    private var previewContent: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            // Summary
            HStack(spacing: DesignSystem.Spacing.large) {
                SummaryBadge(
                    count: previewEntries.filter { $0.isValid }.count,
                    label: "Valid",
                    color: DesignSystem.ColorPalette.successGreen
                )
                
                SummaryBadge(
                    count: previewEntries.filter { !$0.isValid }.count,
                    label: "Invalid",
                    color: DesignSystem.ColorPalette.errorRed
                )
            }
            .padding(.horizontal)
            
            // Preview list
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.small) {
                    ForEach(previewEntries) { entry in
                        PreviewEntryRow(entry: entry)
                    }
                    
                    if let result = parseResult, result.totalRows > previewEntries.count {
                        Text("... and \(result.totalRows - previewEntries.count) more rows")
                            .font(.caption)
                            .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                            .padding()
                    }
                }
                .padding(.horizontal)
            }
            
            // Action buttons
            HStack(spacing: DesignSystem.Spacing.medium) {
                Button("Back") {
                    currentStep = .mapFields
                }
                .buttonStyle(.bordered)
                
                Button(action: performImport) {
                    Text("Import \(previewEntries.filter { $0.isValid }.count) Entries")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignSystem.ColorPalette.primaryBlue)
                .disabled(previewEntries.filter { $0.isValid }.isEmpty)
            }
            .padding()
        }
    }
    
    // MARK: - Step 4: Importing
    
    private var importingContent: some View {
        VStack(spacing: DesignSystem.Spacing.xlarge) {
            Spacer()
            
            ProgressView()
                .scaleEffect(2)
            
            Text("Importing entries...")
                .font(.headline)
                .foregroundStyle(DesignSystem.ColorPalette.label)
            
            Spacer()
        }
    }
    
    // MARK: - Step 5: Complete
    
    private var completeContent: some View {
        VStack(spacing: DesignSystem.Spacing.xlarge) {
            Spacer()
            
            if let result = importResult {
                if result.isFullSuccess {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(DesignSystem.ColorPalette.successGreen)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(DesignSystem.ColorPalette.warningOrange)
                }
                
                VStack(spacing: DesignSystem.Spacing.small) {
                    Text(result.isFullSuccess ? "Import Complete!" : "Import Complete with Issues")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(DesignSystem.ColorPalette.label)
                    
                    HStack(spacing: DesignSystem.Spacing.large) {
                        if result.successCount > 0 {
                            Label("\(result.successCount) imported", systemImage: "checkmark.circle")
                                .foregroundStyle(DesignSystem.ColorPalette.successGreen)
                        }
                        
                        if result.duplicateCount > 0 {
                            Label("\(result.duplicateCount) skipped", systemImage: "arrow.triangle.2.circlepath")
                                .foregroundStyle(DesignSystem.ColorPalette.warningOrange)
                        }
                        
                        if result.failedCount > 0 {
                            Label("\(result.failedCount) failed", systemImage: "xmark.circle")
                                .foregroundStyle(DesignSystem.ColorPalette.errorRed)
                        }
                    }
                    .font(.subheadline)
                }
                
                if !result.errors.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(result.errors.prefix(5), id: \.self) { error in
                                Text("• \(error)")
                                    .font(.caption)
                                    .foregroundStyle(DesignSystem.ColorPalette.errorRed)
                            }
                        }
                    }
                    .frame(maxHeight: 100)
                    .padding()
                    .background(DesignSystem.ColorPalette.glassTint)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    .padding(.horizontal)
                }
            }
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignSystem.ColorPalette.primaryBlue)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Unable to access the file"
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                parseResult = try CSVImportService.parseCSV(from: url)
                
                if let result = parseResult, !result.isEmpty {
                    fieldMapping = CSVImportService.suggestMapping(for: result.headers)
                    currentStep = .mapFields
                    errorMessage = nil
                } else {
                    errorMessage = "The CSV file appears to be empty"
                }
            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
            }
            
        case .failure(let error):
            errorMessage = "Failed to select file: \(error.localizedDescription)"
        }
    }
    
    private func generatePreview() {
        guard let result = parseResult else { return }
        previewEntries = CSVImportService.generatePreview(from: result, mapping: fieldMapping)
        currentStep = .preview
    }
    
    private func performImport() {
        guard let result = parseResult else { return }
        
        currentStep = .importing
        
        // Slight delay for UI feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            importResult = CSVImportService.importEntries(
                from: result,
                mapping: fieldMapping,
                repository: repository,
                skipDuplicates: skipDuplicates
            )
            currentStep = .complete
        }
    }
}

// MARK: - Supporting Views

private struct FieldMappingRow: View {
    let label: String
    let isRequired: Bool
    @Binding var selectedColumn: Int?
    let headers: [String]
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                if isRequired {
                    Text("*")
                        .foregroundStyle(DesignSystem.ColorPalette.errorRed)
                }
            }
            
            Spacer()
            
            Picker("", selection: Binding(
                get: { selectedColumn ?? -1 },
                set: { selectedColumn = $0 == -1 ? nil : $0 }
            )) {
                Text("Not mapped").tag(-1)
                ForEach(Array(headers.enumerated()), id: \.offset) { index, header in
                    Text(header).tag(index)
                }
            }
            .pickerStyle(.menu)
            .tint(selectedColumn != nil ? DesignSystem.ColorPalette.primaryBlue : DesignSystem.ColorPalette.secondaryLabel)
        }
    }
}

private struct SummaryBadge: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

private struct PreviewEntryRow: View {
    let entry: CSVImportService.PreviewEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Row \(entry.rowNumber)")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                    
                    if entry.isValid {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(DesignSystem.ColorPalette.successGreen)
                            .font(.caption)
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(DesignSystem.ColorPalette.errorRed)
                            .font(.caption)
                    }
                }
                
                if let date = entry.date {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline.weight(.medium))
                }
                
                if !entry.errors.isEmpty {
                    Text(entry.errors.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(DesignSystem.ColorPalette.errorRed)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let liters = entry.liters {
                    Text(String(format: "%.2f L", liters))
                        .font(.subheadline)
                }
                
                if let price = entry.pricePerLiter, let liters = entry.liters {
                    Text(String(format: "%.2f", price * liters))
                        .font(.caption)
                        .foregroundStyle(DesignSystem.ColorPalette.secondaryLabel)
                }
            }
        }
        .padding()
        .background(
            entry.isValid
                ? DesignSystem.ColorPalette.glassTint
                : DesignSystem.ColorPalette.errorRed.opacity(0.1)
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Preview

#Preview {
    CSVImportView()
        .environmentObject(FuelRepository())
}
