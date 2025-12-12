import Foundation
import UniformTypeIdentifiers

/// Service for importing fuel data from CSV files
enum CSVImportService {
    
    // MARK: - Types
    
    /// Result of parsing a CSV file
    struct ParseResult {
        let headers: [String]
        let rows: [[String]]
        let totalRows: Int
        
        var isEmpty: Bool { rows.isEmpty }
    }
    
    /// Field mapping from CSV columns to FuelEntry properties
    struct FieldMapping {
        var dateColumn: Int?
        var odometerStartColumn: Int?
        var odometerEndColumn: Int?
        var litersColumn: Int?
        var pricePerLiterColumn: Int?
        var gasStationColumn: Int?
        var driveModeColumn: Int?
        var isFullRefillColumn: Int?
        var notesColumn: Int?
        
        /// Date format to use for parsing
        var dateFormat: String = "yyyy-MM-dd"
        
        /// Whether to use comma or period as decimal separator
        var useCommaDecimal: Bool = false
        
        var isValid: Bool {
            dateColumn != nil && litersColumn != nil && pricePerLiterColumn != nil
        }
    }
    
    /// Import preview entry
    struct PreviewEntry: Identifiable {
        let id = UUID()
        let rowNumber: Int
        let date: Date?
        let odometerStart: Double?
        let odometerEnd: Double?
        let liters: Double?
        let pricePerLiter: Double?
        let gasStation: String?
        let driveMode: FuelEntry.DriveMode?
        let isFullRefill: Bool
        let notes: String?
        let isValid: Bool
        let errors: [String]
        
        func toFuelEntry() -> FuelEntry? {
            guard isValid,
                  let date = date,
                  let liters = liters,
                  let price = pricePerLiter else { return nil }
            
            return FuelEntry(
                date: date,
                odometerStart: odometerStart,
                odometerEnd: odometerEnd,
                totalLiters: liters,
                pricePerLiter: price,
                gasStation: gasStation ?? "Unknown",
                driveMode: driveMode ?? .normal,
                isFullRefill: isFullRefill,
                notes: notes
            )
        }
    }
    
    /// Import result
    struct ImportResult {
        let successCount: Int
        let failedCount: Int
        let duplicateCount: Int
        let errors: [String]
        
        var isFullSuccess: Bool { failedCount == 0 && duplicateCount == 0 }
    }
    
    // MARK: - CSV Parsing
    
    /// Parses a CSV file from URL
    static func parseCSV(from url: URL) throws -> ParseResult {
        let content = try String(contentsOf: url, encoding: .utf8)
        return parseCSV(content: content)
    }
    
    /// Parses CSV content string
    static func parseCSV(content: String) -> ParseResult {
        var rows: [[String]] = []
        var headers: [String] = []
        
        let lines = content.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        for (index, line) in lines.enumerated() {
            let columns = parseCSVLine(line)
            
            if index == 0 {
                headers = columns
            } else {
                rows.append(columns)
            }
        }
        
        return ParseResult(headers: headers, rows: rows, totalRows: rows.count)
    }
    
    /// Parses a single CSV line handling quoted fields
    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        result.append(currentField.trimmingCharacters(in: .whitespaces))
        return result
    }
    
    // MARK: - Field Mapping Suggestions
    
    /// Suggests field mappings based on header names
    static func suggestMapping(for headers: [String]) -> FieldMapping {
        var mapping = FieldMapping()
        
        let normalizedHeaders = headers.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        
        for (index, header) in normalizedHeaders.enumerated() {
            // Date column
            if header.contains("date") || header.contains("tarih") {
                mapping.dateColumn = index
            }
            
            // Odometer columns
            if header.contains("odometer") || header.contains("km") || header.contains("mileage") {
                if header.contains("start") || header.contains("başlangıç") {
                    mapping.odometerStartColumn = index
                } else if header.contains("end") || header.contains("bitiş") {
                    mapping.odometerEndColumn = index
                } else if mapping.odometerStartColumn == nil {
                    mapping.odometerStartColumn = index
                } else if mapping.odometerEndColumn == nil {
                    mapping.odometerEndColumn = index
                }
            }
            
            // Liters column
            if header.contains("liter") || header.contains("litre") || header.contains("fuel") || 
               header.contains("gallon") || header.contains("yakıt") {
                mapping.litersColumn = index
            }
            
            // Price column
            if header.contains("price") || header.contains("cost") || header.contains("per") ||
               header.contains("fiyat") || header.contains("birim") {
                if header.contains("per") || header.contains("birim") {
                    mapping.pricePerLiterColumn = index
                }
            }
            
            // Gas station
            if header.contains("station") || header.contains("location") || header.contains("istasyon") ||
               header.contains("brand") || header.contains("name") {
                mapping.gasStationColumn = index
            }
            
            // Drive mode
            if header.contains("mode") || header.contains("type") || header.contains("sürüş") {
                mapping.driveModeColumn = index
            }
            
            // Full refill
            if header.contains("full") || header.contains("complete") || header.contains("tam") {
                mapping.isFullRefillColumn = index
            }
            
            // Notes
            if header.contains("note") || header.contains("comment") || header.contains("not") {
                mapping.notesColumn = index
            }
        }
        
        return mapping
    }
    
    // MARK: - Preview Generation
    
    /// Generates preview entries using the field mapping
    static func generatePreview(from parseResult: ParseResult, mapping: FieldMapping, limit: Int = 10) -> [PreviewEntry] {
        let rowsToPreview = Array(parseResult.rows.prefix(limit))
        
        return rowsToPreview.enumerated().map { index, row in
            createPreviewEntry(from: row, rowNumber: index + 2, mapping: mapping)
        }
    }
    
    private static func createPreviewEntry(from row: [String], rowNumber: Int, mapping: FieldMapping) -> PreviewEntry {
        var errors: [String] = []
        
        // Parse date
        var date: Date?
        if let col = mapping.dateColumn, col < row.count {
            date = parseDate(row[col], format: mapping.dateFormat)
            if date == nil {
                errors.append("Invalid date format")
            }
        } else {
            errors.append("Missing date")
        }
        
        // Parse odometer
        let odometerStart = mapping.odometerStartColumn.flatMap { $0 < row.count ? parseNumber(row[$0], useCommaDecimal: mapping.useCommaDecimal) : nil }
        let odometerEnd = mapping.odometerEndColumn.flatMap { $0 < row.count ? parseNumber(row[$0], useCommaDecimal: mapping.useCommaDecimal) : nil }
        
        // Parse liters
        var liters: Double?
        if let col = mapping.litersColumn, col < row.count {
            liters = parseNumber(row[col], useCommaDecimal: mapping.useCommaDecimal)
            if liters == nil || liters! <= 0 {
                errors.append("Invalid liters value")
            }
        } else {
            errors.append("Missing liters")
        }
        
        // Parse price
        var pricePerLiter: Double?
        if let col = mapping.pricePerLiterColumn, col < row.count {
            pricePerLiter = parseNumber(row[col], useCommaDecimal: mapping.useCommaDecimal)
            if pricePerLiter == nil || pricePerLiter! <= 0 {
                errors.append("Invalid price value")
            }
        } else {
            errors.append("Missing price")
        }
        
        // Parse optional fields
        let gasStation = mapping.gasStationColumn.flatMap { $0 < row.count ? row[$0] : nil }
        let driveMode = mapping.driveModeColumn.flatMap { $0 < row.count ? parseDriveMode(row[$0]) : nil }
        let isFullRefill = mapping.isFullRefillColumn.flatMap { $0 < row.count ? parseBool(row[$0]) : nil } ?? true
        let notes = mapping.notesColumn.flatMap { $0 < row.count && !row[$0].isEmpty ? row[$0] : nil }
        
        // Validate odometer values
        if let start = odometerStart, let end = odometerEnd, end < start {
            errors.append("End odometer less than start")
        }
        
        return PreviewEntry(
            rowNumber: rowNumber,
            date: date,
            odometerStart: odometerStart,
            odometerEnd: odometerEnd,
            liters: liters,
            pricePerLiter: pricePerLiter,
            gasStation: gasStation,
            driveMode: driveMode,
            isFullRefill: isFullRefill,
            notes: notes,
            isValid: errors.isEmpty,
            errors: errors
        )
    }
    
    // MARK: - Import Execution
    
    /// Imports entries from CSV into the repository
    @MainActor
    static func importEntries(
        from parseResult: ParseResult,
        mapping: FieldMapping,
        repository: FuelRepository,
        skipDuplicates: Bool = true
    ) -> ImportResult {
        var successCount = 0
        var failedCount = 0
        var duplicateCount = 0
        var errors: [String] = []
        
        let existingDates = Set(repository.entries.map { $0.date.timeIntervalSince1970 })
        
        for (index, row) in parseResult.rows.enumerated() {
            let preview = createPreviewEntry(from: row, rowNumber: index + 2, mapping: mapping)
            
            guard preview.isValid, let entry = preview.toFuelEntry() else {
                failedCount += 1
                errors.append("Row \(index + 2): \(preview.errors.joined(separator: ", "))")
                continue
            }
            
            // Check for duplicates
            if skipDuplicates && existingDates.contains(entry.date.timeIntervalSince1970) {
                duplicateCount += 1
                continue
            }
            
            if repository.add(entry) {
                successCount += 1
            } else {
                failedCount += 1
                errors.append("Row \(index + 2): Failed to save entry")
            }
        }
        
        return ImportResult(
            successCount: successCount,
            failedCount: failedCount,
            duplicateCount: duplicateCount,
            errors: errors
        )
    }
    
    // MARK: - Parsing Helpers
    
    private static func parseDate(_ string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: string) {
            return date
        }
        
        // Try common alternative formats
        let alternativeFormats = [
            "yyyy-MM-dd",
            "dd/MM/yyyy",
            "MM/dd/yyyy",
            "dd.MM.yyyy",
            "yyyy/MM/dd",
            "d/M/yyyy",
            "d.M.yyyy"
        ]
        
        for altFormat in alternativeFormats {
            formatter.dateFormat = altFormat
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
    
    private static func parseNumber(_ string: String, useCommaDecimal: Bool) -> Double? {
        var cleanedString = string.trimmingCharacters(in: .whitespaces)
        
        // Remove currency symbols
        cleanedString = cleanedString.replacingOccurrences(of: "$", with: "")
        cleanedString = cleanedString.replacingOccurrences(of: "€", with: "")
        cleanedString = cleanedString.replacingOccurrences(of: "₺", with: "")
        cleanedString = cleanedString.replacingOccurrences(of: "£", with: "")
        cleanedString = cleanedString.trimmingCharacters(in: .whitespaces)
        
        if useCommaDecimal {
            cleanedString = cleanedString.replacingOccurrences(of: ",", with: ".")
        } else {
            // Remove thousand separators
            cleanedString = cleanedString.replacingOccurrences(of: ",", with: "")
        }
        
        return Double(cleanedString)
    }
    
    private static func parseDriveMode(_ string: String) -> FuelEntry.DriveMode? {
        let lowercased = string.lowercased().trimmingCharacters(in: .whitespaces)
        
        switch lowercased {
        case "eco", "ekonomik", "economy":
            return .eco
        case "normal", "standart", "standard":
            return .normal
        case "sport", "sportif", "performance":
            return .sport
        default:
            return nil
        }
    }
    
    private static func parseBool(_ string: String) -> Bool? {
        let lowercased = string.lowercased().trimmingCharacters(in: .whitespaces)
        
        switch lowercased {
        case "true", "yes", "1", "evet", "tam", "full":
            return true
        case "false", "no", "0", "hayır", "kısmi", "partial":
            return false
        default:
            return nil
        }
    }
}

// MARK: - Supported File Types

extension UTType {
    static let csv = UTType(filenameExtension: "csv") ?? .commaSeparatedText
}
