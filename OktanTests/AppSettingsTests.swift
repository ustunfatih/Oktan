import XCTest
@testable import oktan

/// Tests for AppSettings - unit conversions, formatting, and persistence
final class AppSettingsTests: XCTestCase {
    
    var settings: AppSettings!
    
    override func setUp() {
        settings = AppSettings()
    }
    
    override func tearDown() {
        settings = nil
    }
    
    // MARK: - Distance Formatting Tests
    
    func testFormatDistanceInKilometers() {
        settings.distanceUnit = .kilometers
        
        let result = settings.formatDistance(500)
        
        XCTAssertTrue(result.contains("500"), "Should contain the distance value")
        XCTAssertTrue(result.contains("km"), "Should contain km unit")
    }
    
    func testFormatDistanceInMiles() {
        settings.distanceUnit = .miles
        
        let result = settings.formatDistance(500) // 500 km = ~310.69 miles
        
        XCTAssertTrue(result.contains("mi"), "Should contain mi unit")
        // Check conversion: 500 * 0.621371 ≈ 311
        XCTAssertTrue(result.contains("311"), "Should contain converted value")
    }
    
    func testFormatDistanceZero() {
        settings.distanceUnit = .kilometers
        
        let result = settings.formatDistance(0)
        
        XCTAssertTrue(result.contains("0"), "Should handle zero correctly")
    }
    
    func testDistanceConversionAccuracy() {
        settings.distanceUnit = .miles
        
        // 100 km should be exactly 62.1371 miles
        let result = settings.formatDistance(100)
        
        // Rounded to 0 decimal places, should be 62
        XCTAssertTrue(result.contains("62"), "Conversion should be accurate")
    }
    
    // MARK: - Volume Formatting Tests
    
    func testFormatVolumeInLiters() {
        settings.volumeUnit = .liters
        
        let result = settings.formatVolume(45.5)
        
        XCTAssertTrue(result.contains("45.5") || result.contains("45,5"), "Should contain the volume value")
        XCTAssertTrue(result.contains("L"), "Should contain L unit")
    }
    
    func testFormatVolumeInGallons() {
        settings.volumeUnit = .gallons
        
        let result = settings.formatVolume(45.5) // 45.5 L = ~12.02 gallons
        
        XCTAssertTrue(result.contains("gal"), "Should contain gal unit")
    }
    
    func testVolumeConversionAccuracy() {
        settings.volumeUnit = .gallons
        
        // 1 liter = 0.264172 gallons
        // 10 liters = 2.64172 gallons
        let result = settings.formatVolume(10)
        
        XCTAssertTrue(result.contains("2.6") || result.contains("2,6"), "Conversion should be accurate")
    }
    
    // MARK: - Efficiency Formatting Tests
    
    func testFormatEfficiencyLitersPer100km() {
        settings.efficiencyUnit = .litersPer100km
        
        let result = settings.formatEfficiency(10.5)
        
        XCTAssertTrue(result.contains("10.5") || result.contains("10,5"), "Should contain the efficiency value")
        XCTAssertTrue(result.contains("L/100km"), "Should contain L/100km unit")
    }
    
    func testFormatEfficiencyKmPerLiter() {
        settings.efficiencyUnit = .kmPerLiter
        
        // 10 L/100km = 10 km/L
        let result = settings.formatEfficiency(10)
        
        XCTAssertTrue(result.contains("km/L"), "Should contain km/L unit")
        XCTAssertTrue(result.contains("10"), "Should show correct conversion")
    }
    
    func testFormatEfficiencyMPG() {
        settings.efficiencyUnit = .mpg
        
        // 10 L/100km ≈ 23.52 MPG
        let result = settings.formatEfficiency(10)
        
        XCTAssertTrue(result.contains("MPG"), "Should contain MPG unit")
        XCTAssertTrue(result.contains("23") || result.contains("24"), "Should show approximate MPG value")
    }
    
    func testConvertEfficiencyLitersPer100km() {
        settings.efficiencyUnit = .litersPer100km
        
        let result = settings.convertEfficiency(10.5)
        
        XCTAssertEqual(result, 10.5, accuracy: 0.001, "Should return same value for L/100km")
    }
    
    func testConvertEfficiencyKmPerLiter() {
        settings.efficiencyUnit = .kmPerLiter
        
        // 10 L/100km = 100/10 = 10 km/L
        let result = settings.convertEfficiency(10)
        
        XCTAssertEqual(result, 10, accuracy: 0.001, "Should convert correctly to km/L")
    }
    
    func testConvertEfficiencyMPG() {
        settings.efficiencyUnit = .mpg
        
        // 10 L/100km = 235.215/10 = 23.5215 MPG
        let result = settings.convertEfficiency(10)
        
        XCTAssertEqual(result, 23.5215, accuracy: 0.001, "Should convert correctly to MPG")
    }
    
    func testEfficiencyConversionAccuracy() {
        // Verify MPG conversion formula is correct
        // The formula 235.215 / L/100km is standard
        settings.efficiencyUnit = .mpg
        
        // 5 L/100km = 47.043 MPG (very efficient)
        XCTAssertEqual(settings.convertEfficiency(5), 47.043, accuracy: 0.001)
        
        // 15 L/100km = 15.681 MPG (less efficient)
        XCTAssertEqual(settings.convertEfficiency(15), 15.681, accuracy: 0.001)
    }
    
    // MARK: - Cost Formatting Tests
    
    func testFormatCostWithDifferentCurrencies() {
        settings.currencyCode = "QAR"
        let qarResult = settings.formatCost(100)
        XCTAssertTrue(qarResult.contains("100") || qarResult.contains("QAR"), "Should format QAR correctly")
        
        settings.currencyCode = "USD"
        let usdResult = settings.formatCost(100)
        XCTAssertTrue(usdResult.contains("$") || usdResult.contains("USD") || usdResult.contains("100"), "Should format USD correctly")
        
        settings.currencyCode = "TRY"
        let tryResult = settings.formatCost(100)
        XCTAssertTrue(tryResult.contains("100") || tryResult.contains("₺") || tryResult.contains("TRY"), "Should format TRY correctly")
    }
    
    func testFormatCostZero() {
        settings.currencyCode = "QAR"
        let result = settings.formatCost(0)
        
        XCTAssertTrue(result.contains("0"), "Should handle zero correctly")
    }
    
    // MARK: - Cost Per Distance Tests
    
    func testConvertCostPerDistanceKilometers() {
        settings.distanceUnit = .kilometers
        
        let result = settings.convertCostPerDistance(0.2) // 0.2 QAR/km
        
        XCTAssertEqual(result, 0.2, accuracy: 0.001, "Should return same value for km")
    }
    
    func testConvertCostPerDistanceMiles() {
        settings.distanceUnit = .miles
        
        // 0.2 QAR/km = 0.2 / 0.621371 ≈ 0.322 QAR/mile
        let result = settings.convertCostPerDistance(0.2)
        
        XCTAssertEqual(result, 0.2 / 0.621371, accuracy: 0.001, "Should convert correctly to per mile")
    }
    
    func testFormatCostPerDistance() {
        settings.currencyCode = "QAR"
        settings.distanceUnit = .kilometers
        
        let result = settings.formatCostPerDistance(0.205)
        
        XCTAssertTrue(result.contains("0.205") || result.contains("0,205"), "Should format with precision")
        XCTAssertTrue(result.contains("QAR"), "Should include currency")
        XCTAssertTrue(result.contains("km"), "Should include distance unit")
    }
    
    // MARK: - Language Tests
    
    func testLanguageDisplayNames() {
        XCTAssertEqual(AppSettings.AppLanguage.english.displayName, "English")
        XCTAssertEqual(AppSettings.AppLanguage.turkish.displayName, "Türkçe")
    }
    
    func testAllLanguageCases() {
        XCTAssertEqual(AppSettings.AppLanguage.allCases.count, 3)
        XCTAssertTrue(AppSettings.AppLanguage.allCases.contains(.system))
        XCTAssertTrue(AppSettings.AppLanguage.allCases.contains(.english))
        XCTAssertTrue(AppSettings.AppLanguage.allCases.contains(.turkish))
    }
    
    // MARK: - Supported Currencies Tests
    
    func testSupportedCurrenciesContainsRequired() {
        let codes = AppSettings.supportedCurrencies.map { $0.code }
        
        XCTAssertTrue(codes.contains("QAR"), "Should support QAR")
        XCTAssertTrue(codes.contains("TRY"), "Should support TRY")
        XCTAssertTrue(codes.contains("USD"), "Should support USD")
        XCTAssertTrue(codes.contains("EUR"), "Should support EUR")
    }
    
    func testSupportedCurrenciesHaveSymbols() {
        for currency in AppSettings.supportedCurrencies {
            XCTAssertFalse(currency.symbol.isEmpty, "\(currency.code) should have a symbol")
            XCTAssertFalse(currency.name.isEmpty, "\(currency.code) should have a name")
        }
    }
    
    // MARK: - Edge Cases
    
    func testVeryLargeDistance() {
        settings.distanceUnit = .kilometers
        
        let result = settings.formatDistance(999999)
        
        // Should handle large numbers without crashing
        XCTAssertFalse(result.isEmpty)
    }
    
    func testVerySmallEfficiency() {
        settings.efficiencyUnit = .litersPer100km
        
        let result = settings.formatEfficiency(0.5) // Extremely efficient (EV-like)
        
        XCTAssertTrue(result.contains("0.5") || result.contains("0,5"), "Should handle very small values")
    }
    
    func testVeryHighEfficiency() {
        settings.efficiencyUnit = .litersPer100km
        
        let result = settings.formatEfficiency(50) // Very inefficient
        
        XCTAssertTrue(result.contains("50"), "Should handle high values")
    }
    
    // MARK: - Unit Enum Tests
    
    func testDistanceUnitRawValues() {
        XCTAssertEqual(AppSettings.DistanceUnit.kilometers.rawValue, "km")
        XCTAssertEqual(AppSettings.DistanceUnit.miles.rawValue, "mi")
    }
    
    func testVolumeUnitRawValues() {
        XCTAssertEqual(AppSettings.VolumeUnit.liters.rawValue, "L")
        XCTAssertEqual(AppSettings.VolumeUnit.gallons.rawValue, "gal")
    }
    
    func testEfficiencyUnitRawValues() {
        XCTAssertEqual(AppSettings.EfficiencyUnit.litersPer100km.rawValue, "L/100km")
        XCTAssertEqual(AppSettings.EfficiencyUnit.kmPerLiter.rawValue, "km/L")
        XCTAssertEqual(AppSettings.EfficiencyUnit.mpg.rawValue, "MPG")
    }
}
