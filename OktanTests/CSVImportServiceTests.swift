import XCTest
@testable import oktan

/// Tests for CSVImportService
final class CSVImportServiceTests: XCTestCase {
    
    // MARK: - CSV Parsing Tests
    
    func testParseSimpleCSV() {
        let csv = """
        Date,Liters,Price
        2024-01-15,45.5,1.50
        2024-01-20,50.0,1.55
        """
        
        let result = CSVImportService.parseCSV(content: csv)
        
        XCTAssertEqual(result.headers, ["Date", "Liters", "Price"])
        XCTAssertEqual(result.totalRows, 2)
        XCTAssertEqual(result.rows[0], ["2024-01-15", "45.5", "1.50"])
        XCTAssertEqual(result.rows[1], ["2024-01-20", "50.0", "1.55"])
    }
    
    func testParseCSVWithQuotedFields() {
        let csv = """
        Station,Notes
        "Shell, Main Street","Full tank, good price"
        BP,Standard
        """
        
        let result = CSVImportService.parseCSV(content: csv)
        
        XCTAssertEqual(result.headers, ["Station", "Notes"])
        XCTAssertEqual(result.rows[0][0], "Shell, Main Street")
        XCTAssertEqual(result.rows[0][1], "Full tank, good price")
    }
    
    func testParseEmptyCSV() {
        let csv = ""
        let result = CSVImportService.parseCSV(content: csv)
        
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(result.totalRows, 0)
    }
    
    func testParseCSVWithWhitespace() {
        let csv = """
        Date  ,  Liters  ,  Price
        2024-01-15  ,  45.5  ,  1.50
        """
        
        let result = CSVImportService.parseCSV(content: csv)
        
        XCTAssertEqual(result.headers, ["Date", "Liters", "Price"])
        XCTAssertEqual(result.rows[0], ["2024-01-15", "45.5", "1.50"])
    }
    
    // MARK: - Field Mapping Suggestion Tests
    
    func testSuggestMappingForCommonHeaders() {
        let headers = ["Date", "Odometer Start", "Odometer End", "Liters", "Price per Liter", "Station", "Notes"]
        let mapping = CSVImportService.suggestMapping(for: headers)
        
        XCTAssertEqual(mapping.dateColumn, 0)
        XCTAssertEqual(mapping.odometerStartColumn, 1)
        XCTAssertEqual(mapping.odometerEndColumn, 2)
        XCTAssertEqual(mapping.litersColumn, 3)
        XCTAssertNotNil(mapping.gasStationColumn)
        XCTAssertEqual(mapping.notesColumn, 6)
    }
    
    func testSuggestMappingForTurkishHeaders() {
        let headers = ["Tarih", "Yakıt", "Birim Fiyat", "İstasyon", "Not"]
        let mapping = CSVImportService.suggestMapping(for: headers)
        
        XCTAssertEqual(mapping.dateColumn, 0)
        XCTAssertEqual(mapping.litersColumn, 1)
        XCTAssertEqual(mapping.gasStationColumn, 3)
        XCTAssertEqual(mapping.notesColumn, 4)
    }
    
    func testSuggestMappingIsCaseInsensitive() {
        let headers = ["DATE", "liters", "PRICE PER LITER"]
        let mapping = CSVImportService.suggestMapping(for: headers)
        
        XCTAssertEqual(mapping.dateColumn, 0)
        XCTAssertEqual(mapping.litersColumn, 1)
    }
    
    func testMappingValidation() {
        var mapping = CSVImportService.FieldMapping()
        XCTAssertFalse(mapping.isValid, "Empty mapping should be invalid")
        
        mapping.dateColumn = 0
        XCTAssertFalse(mapping.isValid, "Missing liters and price should be invalid")
        
        mapping.litersColumn = 1
        XCTAssertFalse(mapping.isValid, "Missing price should be invalid")
        
        mapping.pricePerLiterColumn = 2
        XCTAssertTrue(mapping.isValid, "Complete required fields should be valid")
    }
    
    // MARK: - Preview Generation Tests
    
    func testGeneratePreviewWithValidData() {
        let result = CSVImportService.ParseResult(
            headers: ["Date", "Liters", "Price"],
            rows: [
                ["2024-01-15", "45.5", "1.50"],
                ["2024-01-20", "50.0", "1.55"]
            ],
            totalRows: 2
        )
        
        var mapping = CSVImportService.FieldMapping()
        mapping.dateColumn = 0
        mapping.litersColumn = 1
        mapping.pricePerLiterColumn = 2
        mapping.dateFormat = "yyyy-MM-dd"
        
        let preview = CSVImportService.generatePreview(from: result, mapping: mapping)
        
        XCTAssertEqual(preview.count, 2)
        XCTAssertTrue(preview[0].isValid)
        XCTAssertTrue(preview[1].isValid)
        XCTAssertEqual(preview[0].liters, 45.5)
        XCTAssertEqual(preview[0].pricePerLiter, 1.50)
    }
    
    func testGeneratePreviewWithInvalidData() {
        let result = CSVImportService.ParseResult(
            headers: ["Date", "Liters", "Price"],
            rows: [
                ["invalid-date", "45.5", "1.50"],
                ["2024-01-20", "not-a-number", "1.55"],
                ["2024-01-25", "50.0", "-1.0"]
            ],
            totalRows: 3
        )
        
        var mapping = CSVImportService.FieldMapping()
        mapping.dateColumn = 0
        mapping.litersColumn = 1
        mapping.pricePerLiterColumn = 2
        mapping.dateFormat = "yyyy-MM-dd"
        
        let preview = CSVImportService.generatePreview(from: result, mapping: mapping)
        
        XCTAssertFalse(preview[0].isValid, "Invalid date should fail")
        XCTAssertTrue(preview[0].errors.contains { $0.contains("date") })
        
        XCTAssertFalse(preview[1].isValid, "Invalid liters should fail")
        XCTAssertTrue(preview[1].errors.contains { $0.contains("liters") })
        
        XCTAssertFalse(preview[2].isValid, "Negative price should fail")
    }
    
    func testPreviewLimitRespected() {
        let rows = (0..<20).map { i in
            ["2024-01-\(String(format: "%02d", i + 1))", "45.0", "1.50"]
        }
        
        let result = CSVImportService.ParseResult(
            headers: ["Date", "Liters", "Price"],
            rows: rows,
            totalRows: 20
        )
        
        var mapping = CSVImportService.FieldMapping()
        mapping.dateColumn = 0
        mapping.litersColumn = 1
        mapping.pricePerLiterColumn = 2
        
        let preview = CSVImportService.generatePreview(from: result, mapping: mapping, limit: 5)
        
        XCTAssertEqual(preview.count, 5)
    }
    
    // MARK: - Conversion to FuelEntry Tests
    
    func testPreviewEntryConversion() {
        let previewEntry = CSVImportService.PreviewEntry(
            rowNumber: 2,
            date: Date(),
            odometerStart: 1000,
            odometerEnd: 1500,
            liters: 45.5,
            pricePerLiter: 1.50,
            gasStation: "Shell",
            driveMode: .eco,
            isFullRefill: true,
            notes: "Test note",
            isValid: true,
            errors: []
        )
        
        let fuelEntry = previewEntry.toFuelEntry()
        
        XCTAssertNotNil(fuelEntry)
        XCTAssertEqual(fuelEntry?.odometerStart, 1000)
        XCTAssertEqual(fuelEntry?.odometerEnd, 1500)
        XCTAssertEqual(fuelEntry?.totalLiters, 45.5)
        XCTAssertEqual(fuelEntry?.pricePerLiter, 1.50)
        XCTAssertEqual(fuelEntry?.gasStation, "Shell")
        XCTAssertEqual(fuelEntry?.driveMode, .eco)
        XCTAssertEqual(fuelEntry?.notes, "Test note")
    }
    
    func testInvalidPreviewEntryConversion() {
        let previewEntry = CSVImportService.PreviewEntry(
            rowNumber: 2,
            date: nil,
            odometerStart: nil,
            odometerEnd: nil,
            liters: nil,
            pricePerLiter: nil,
            gasStation: nil,
            driveMode: nil,
            isFullRefill: true,
            notes: nil,
            isValid: false,
            errors: ["Missing date"]
        )
        
        let fuelEntry = previewEntry.toFuelEntry()
        
        XCTAssertNil(fuelEntry)
    }
    
    // MARK: - Date Parsing Tests
    
    func testMultipleDateFormats() {
        let testCases: [(String, String)] = [
            ("2024-01-15", "yyyy-MM-dd"),
            ("15/01/2024", "dd/MM/yyyy"),
            ("01/15/2024", "MM/dd/yyyy"),
            ("15.01.2024", "dd.MM.yyyy")
        ]
        
        for (dateString, format) in testCases {
            let result = CSVImportService.ParseResult(
                headers: ["Date", "Liters", "Price"],
                rows: [[dateString, "45.0", "1.50"]],
                totalRows: 1
            )
            
            var mapping = CSVImportService.FieldMapping()
            mapping.dateColumn = 0
            mapping.litersColumn = 1
            mapping.pricePerLiterColumn = 2
            mapping.dateFormat = format
            
            let preview = CSVImportService.generatePreview(from: result, mapping: mapping)
            
            XCTAssertNotNil(preview[0].date, "Should parse date with format \(format)")
        }
    }
    
    // MARK: - Number Parsing Tests
    
    func testCommaDecimalParsing() {
        let result = CSVImportService.ParseResult(
            headers: ["Date", "Liters", "Price"],
            rows: [["2024-01-15", "45,5", "1,50"]],
            totalRows: 1
        )
        
        var mapping = CSVImportService.FieldMapping()
        mapping.dateColumn = 0
        mapping.litersColumn = 1
        mapping.pricePerLiterColumn = 2
        mapping.useCommaDecimal = true
        
        let preview = CSVImportService.generatePreview(from: result, mapping: mapping)
        
        XCTAssertEqual(preview[0].liters, 45.5)
        XCTAssertEqual(preview[0].pricePerLiter, 1.50)
    }
    
    func testCurrencySymbolRemoval() {
        let result = CSVImportService.ParseResult(
            headers: ["Date", "Liters", "Price"],
            rows: [
                ["2024-01-15", "45.0", "$1.50"],
                ["2024-01-16", "50.0", "€1.60"],
                ["2024-01-17", "55.0", "₺25.00"]
            ],
            totalRows: 3
        )
        
        var mapping = CSVImportService.FieldMapping()
        mapping.dateColumn = 0
        mapping.litersColumn = 1
        mapping.pricePerLiterColumn = 2
        
        let preview = CSVImportService.generatePreview(from: result, mapping: mapping)
        
        XCTAssertEqual(preview[0].pricePerLiter, 1.50)
        XCTAssertEqual(preview[1].pricePerLiter, 1.60)
        XCTAssertEqual(preview[2].pricePerLiter, 25.00)
    }
    
    // MARK: - Edge Cases
    
    func testMissingOptionalFields() {
        let result = CSVImportService.ParseResult(
            headers: ["Date", "Liters", "Price"],
            rows: [["2024-01-15", "45.5", "1.50"]],
            totalRows: 1
        )
        
        var mapping = CSVImportService.FieldMapping()
        mapping.dateColumn = 0
        mapping.litersColumn = 1
        mapping.pricePerLiterColumn = 2
        // Not mapping optional fields
        
        let preview = CSVImportService.generatePreview(from: result, mapping: mapping)
        
        XCTAssertTrue(preview[0].isValid)
        XCTAssertNil(preview[0].odometerStart)
        XCTAssertNil(preview[0].odometerEnd)
        XCTAssertNil(preview[0].gasStation)
    }
    
    func testOdometerValidation() {
        let result = CSVImportService.ParseResult(
            headers: ["Date", "Liters", "Price", "Start", "End"],
            rows: [["2024-01-15", "45.5", "1.50", "2000", "1500"]], // End < Start
            totalRows: 1
        )
        
        var mapping = CSVImportService.FieldMapping()
        mapping.dateColumn = 0
        mapping.litersColumn = 1
        mapping.pricePerLiterColumn = 2
        mapping.odometerStartColumn = 3
        mapping.odometerEndColumn = 4
        
        let preview = CSVImportService.generatePreview(from: result, mapping: mapping)
        
        XCTAssertFalse(preview[0].isValid)
        XCTAssertTrue(preview[0].errors.contains { $0.contains("odometer") || $0.contains("End") })
    }
}
