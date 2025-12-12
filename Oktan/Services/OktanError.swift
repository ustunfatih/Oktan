import Foundation

/// Centralized error types for the Oktan app
/// All errors should conform to this for consistent handling
enum OktanError: LocalizedError, Equatable {
    
    // MARK: - Data Errors
    
    /// Failed to save data
    case saveFailed(reason: String)
    
    /// Failed to load data
    case loadFailed(reason: String)
    
    /// Failed to delete data
    case deleteFailed(reason: String)
    
    /// Data validation failed
    case validationFailed(field: String, reason: String)
    
    /// Data migration failed
    case migrationFailed(reason: String)
    
    // MARK: - Network Errors
    
    /// No internet connection
    case noConnection
    
    /// Request timed out
    case timeout
    
    /// Server error
    case serverError(statusCode: Int)
    
    /// API rate limit exceeded
    case rateLimitExceeded
    
    /// Invalid response from server
    case invalidResponse
    
    // MARK: - Authentication Errors
    
    /// Sign in failed
    case signInFailed(reason: String)
    
    /// Sign out failed
    case signOutFailed(reason: String)
    
    /// Session expired
    case sessionExpired
    
    /// Not authenticated
    case notAuthenticated
    
    // MARK: - File Errors
    
    /// File not found
    case fileNotFound(path: String)
    
    /// File read error
    case fileReadError(path: String)
    
    /// File write error
    case fileWriteError(path: String)
    
    /// Export failed
    case exportFailed(reason: String)
    
    /// Import failed
    case importFailed(reason: String)
    
    // MARK: - Image Errors
    
    /// Image generation failed
    case imageGenerationFailed(reason: String)
    
    /// Invalid image data
    case invalidImageData
    
    // MARK: - General Errors
    
    /// Unknown error
    case unknown(underlying: String)
    
    /// Feature not available
    case featureNotAvailable(feature: String)
    
    /// Operation cancelled by user
    case cancelled
    
    // MARK: - LocalizedError Implementation
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let reason):
            return String(localized: "Failed to save: \(reason)")
        case .loadFailed(let reason):
            return String(localized: "Failed to load data: \(reason)")
        case .deleteFailed(let reason):
            return String(localized: "Failed to delete: \(reason)")
        case .validationFailed(let field, let reason):
            return String(localized: "Invalid \(field): \(reason)")
        case .migrationFailed(let reason):
            return String(localized: "Data migration failed: \(reason)")
            
        case .noConnection:
            return String(localized: "No internet connection. Please check your network settings.")
        case .timeout:
            return String(localized: "The request timed out. Please try again.")
        case .serverError(let code):
            return String(localized: "Server error (\(code)). Please try again later.")
        case .rateLimitExceeded:
            return String(localized: "Too many requests. Please wait a moment and try again.")
        case .invalidResponse:
            return String(localized: "Received invalid response from server.")
            
        case .signInFailed(let reason):
            return String(localized: "Sign in failed: \(reason)")
        case .signOutFailed(let reason):
            return String(localized: "Sign out failed: \(reason)")
        case .sessionExpired:
            return String(localized: "Your session has expired. Please sign in again.")
        case .notAuthenticated:
            return String(localized: "You need to sign in to access this feature.")
            
        case .fileNotFound(let path):
            return String(localized: "File not found: \(path)")
        case .fileReadError(let path):
            return String(localized: "Could not read file: \(path)")
        case .fileWriteError(let path):
            return String(localized: "Could not write file: \(path)")
        case .exportFailed(let reason):
            return String(localized: "Export failed: \(reason)")
        case .importFailed(let reason):
            return String(localized: "Import failed: \(reason)")
            
        case .imageGenerationFailed(let reason):
            return String(localized: "Could not generate image: \(reason)")
        case .invalidImageData:
            return String(localized: "The image data is invalid or corrupted.")
            
        case .unknown(let underlying):
            return String(localized: "An unexpected error occurred: \(underlying)")
        case .featureNotAvailable(let feature):
            return String(localized: "\(feature) is not available on this device.")
        case .cancelled:
            return String(localized: "Operation was cancelled.")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .deleteFailed:
            return String(localized: "Please try again. If the problem persists, restart the app.")
        case .loadFailed, .migrationFailed:
            return String(localized: "Your data may be corrupted. Try reinstalling the app.")
        case .validationFailed:
            return String(localized: "Please correct the field and try again.")
            
        case .noConnection:
            return String(localized: "Check your Wi-Fi or cellular connection.")
        case .timeout, .serverError, .rateLimitExceeded:
            return String(localized: "Wait a few moments and try again.")
        case .invalidResponse:
            return String(localized: "Try again. If this persists, contact support.")
            
        case .signInFailed, .signOutFailed:
            return String(localized: "Check your Apple ID settings and try again.")
        case .sessionExpired, .notAuthenticated:
            return String(localized: "Go to Profile to sign in.")
            
        case .fileNotFound, .fileReadError, .fileWriteError:
            return String(localized: "Make sure you have enough storage space.")
        case .exportFailed:
            return String(localized: "Check that you have permission to save files.")
        case .importFailed:
            return String(localized: "Make sure the file format is correct.")
            
        case .imageGenerationFailed:
            return String(localized: "Try again or skip the image.")
        case .invalidImageData:
            return String(localized: "Try selecting a different image.")
            
        case .unknown:
            return String(localized: "Please restart the app and try again.")
        case .featureNotAvailable:
            return String(localized: "Update to the latest iOS version if available.")
        case .cancelled:
            return nil
        }
    }
    
    /// Whether this error is recoverable (user can retry)
    var isRecoverable: Bool {
        switch self {
        case .noConnection, .timeout, .serverError, .rateLimitExceeded,
             .saveFailed, .deleteFailed, .imageGenerationFailed:
            return true
        case .sessionExpired, .notAuthenticated:
            return true // Can sign in again
        default:
            return false
        }
    }
    
    /// Icon for displaying in UI
    var systemIcon: String {
        switch self {
        case .noConnection, .timeout, .serverError, .rateLimitExceeded, .invalidResponse:
            return "wifi.exclamationmark"
        case .signInFailed, .signOutFailed, .sessionExpired, .notAuthenticated:
            return "person.crop.circle.badge.exclamationmark"
        case .fileNotFound, .fileReadError, .fileWriteError, .exportFailed, .importFailed:
            return "doc.badge.ellipsis"
        case .imageGenerationFailed, .invalidImageData:
            return "photo.badge.exclamationmark"
        case .validationFailed:
            return "exclamationmark.triangle"
        default:
            return "exclamationmark.circle"
        }
    }
}

// MARK: - Error Conversion

extension OktanError {
    /// Creates an OktanError from a standard Error
    static func from(_ error: Error) -> OktanError {
        if let oktanError = error as? OktanError {
            return oktanError
        }
        
        let nsError = error as NSError
        
        // Handle URL errors
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return .noConnection
            case NSURLErrorTimedOut:
                return .timeout
            case NSURLErrorCancelled:
                return .cancelled
            default:
                return .serverError(statusCode: nsError.code)
            }
        }
        
        // Handle file errors
        if nsError.domain == NSCocoaErrorDomain {
            switch nsError.code {
            case NSFileNoSuchFileError, NSFileReadNoSuchFileError:
                return .fileNotFound(path: nsError.userInfo[NSFilePathErrorKey] as? String ?? "unknown")
            case NSFileReadUnknownError, NSFileReadNoPermissionError:
                return .fileReadError(path: nsError.userInfo[NSFilePathErrorKey] as? String ?? "unknown")
            case NSFileWriteUnknownError, NSFileWriteNoPermissionError, NSFileWriteOutOfSpaceError:
                return .fileWriteError(path: nsError.userInfo[NSFilePathErrorKey] as? String ?? "unknown")
            default:
                break
            }
        }
        
        return .unknown(underlying: error.localizedDescription)
    }
}
