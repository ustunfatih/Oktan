import XCTest
@testable import oktan

/// Tests for OktanError and ErrorHandler
final class ErrorHandlingTests: XCTestCase {
    
    // MARK: - OktanError Tests
    
    func testErrorDescriptions() {
        // Data errors
        XCTAssertNotNil(OktanError.saveFailed(reason: "test").errorDescription)
        XCTAssertNotNil(OktanError.loadFailed(reason: "test").errorDescription)
        XCTAssertNotNil(OktanError.deleteFailed(reason: "test").errorDescription)
        XCTAssertNotNil(OktanError.validationFailed(field: "test", reason: "test").errorDescription)
        
        // Network errors
        XCTAssertNotNil(OktanError.noConnection.errorDescription)
        XCTAssertNotNil(OktanError.timeout.errorDescription)
        XCTAssertNotNil(OktanError.serverError(statusCode: 500).errorDescription)
        
        // Auth errors
        XCTAssertNotNil(OktanError.signInFailed(reason: "test").errorDescription)
        XCTAssertNotNil(OktanError.sessionExpired.errorDescription)
    }
    
    func testRecoverySuggestions() {
        XCTAssertNotNil(OktanError.noConnection.recoverySuggestion)
        XCTAssertNotNil(OktanError.timeout.recoverySuggestion)
        XCTAssertNotNil(OktanError.saveFailed(reason: "test").recoverySuggestion)
        XCTAssertNil(OktanError.cancelled.recoverySuggestion)
    }
    
    func testIsRecoverable() {
        // Recoverable
        XCTAssertTrue(OktanError.noConnection.isRecoverable)
        XCTAssertTrue(OktanError.timeout.isRecoverable)
        XCTAssertTrue(OktanError.serverError(statusCode: 500).isRecoverable)
        XCTAssertTrue(OktanError.saveFailed(reason: "test").isRecoverable)
        
        // Not recoverable
        XCTAssertFalse(OktanError.validationFailed(field: "test", reason: "test").isRecoverable)
        XCTAssertFalse(OktanError.cancelled.isRecoverable)
        XCTAssertFalse(OktanError.migrationFailed(reason: "test").isRecoverable)
    }
    
    func testSystemIcons() {
        XCTAssertEqual(OktanError.noConnection.systemIcon, "wifi.exclamationmark")
        XCTAssertEqual(OktanError.sessionExpired.systemIcon, "person.crop.circle.badge.exclamationmark")
        XCTAssertEqual(OktanError.exportFailed(reason: "test").systemIcon, "doc.badge.ellipsis")
        XCTAssertEqual(OktanError.imageGenerationFailed(reason: "test").systemIcon, "photo.badge.exclamationmark")
    }
    
    func testErrorEquatable() {
        XCTAssertEqual(OktanError.noConnection, OktanError.noConnection)
        XCTAssertEqual(OktanError.timeout, OktanError.timeout)
        XCTAssertNotEqual(OktanError.noConnection, OktanError.timeout)
        
        XCTAssertEqual(
            OktanError.saveFailed(reason: "test"),
            OktanError.saveFailed(reason: "test")
        )
        XCTAssertNotEqual(
            OktanError.saveFailed(reason: "test1"),
            OktanError.saveFailed(reason: "test2")
        )
    }
    
    // MARK: - Error Conversion Tests
    
    func testConvertFromURLError() {
        let notConnectedError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet
        )
        let result = OktanError.from(notConnectedError)
        XCTAssertEqual(result, .noConnection)
        
        let timeoutError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorTimedOut
        )
        XCTAssertEqual(OktanError.from(timeoutError), .timeout)
        
        let cancelledError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorCancelled
        )
        XCTAssertEqual(OktanError.from(cancelledError), .cancelled)
    }
    
    func testConvertFromFileError() {
        let fileNotFoundError = NSError(
            domain: NSCocoaErrorDomain,
            code: NSFileNoSuchFileError,
            userInfo: [NSFilePathErrorKey: "/test/path"]
        )
        if case .fileNotFound(let path) = OktanError.from(fileNotFoundError) {
            XCTAssertEqual(path, "/test/path")
        } else {
            XCTFail("Expected fileNotFound error")
        }
    }
    
    func testConvertFromUnknownError() {
        let unknownError = NSError(
            domain: "CustomDomain",
            code: 999,
            userInfo: [NSLocalizedDescriptionKey: "Custom error"]
        )
        if case .unknown(let underlying) = OktanError.from(unknownError) {
            XCTAssertTrue(underlying.contains("Custom error"))
        } else {
            XCTFail("Expected unknown error")
        }
    }
    
    func testConvertFromOktanError() {
        let original = OktanError.noConnection
        let converted = OktanError.from(original)
        XCTAssertEqual(original, converted)
    }
    
    // MARK: - Validation Error Tests
    
    func testValidationErrorMessages() {
        let litersError = OktanError.validationFailed(field: "Total Liters", reason: "Must be greater than zero")
        XCTAssertTrue(litersError.errorDescription?.contains("Total Liters") ?? false)
        XCTAssertTrue(litersError.errorDescription?.contains("Must be greater than zero") ?? false)
        
        let odometerError = OktanError.validationFailed(field: "Odometer", reason: "End reading must be greater than start")
        XCTAssertTrue(odometerError.errorDescription?.contains("Odometer") ?? false)
    }
    
    // MARK: - Server Error Tests
    
    func testServerErrorStatusCode() {
        let error400 = OktanError.serverError(statusCode: 400)
        XCTAssertTrue(error400.errorDescription?.contains("400") ?? false)
        
        let error500 = OktanError.serverError(statusCode: 500)
        XCTAssertTrue(error500.errorDescription?.contains("500") ?? false)
    }
}
