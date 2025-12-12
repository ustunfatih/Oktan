import Foundation
import SwiftData

/// SwiftData model for cars
/// This replaces the Codable struct-based Car for persistence
@Model
final class CarSD {
    
    // MARK: - Stored Properties
    
    /// Unique identifier matching the original Car.id
    @Attribute(.unique) var carId: UUID
    
    /// Car manufacturer (e.g., "Toyota")
    var make: String
    
    /// Car model (e.g., "Camry")
    var model: String
    
    /// Model year (optional)
    var year: Int?
    
    /// Fuel tank capacity in liters
    var tankCapacity: Double
    
    /// Car image data (binary)
    @Attribute(.externalStorage) var imageData: Data?
    
    /// Timestamp for sync conflict resolution
    var lastModified: Date
    
    /// Whether this is the currently selected car
    var isSelected: Bool
    
    // MARK: - Computed Properties
    
    /// Formatted display name including year if available
    var displayName: String {
        if let year {
            return "\(year) \(make) \(model)"
        }
        return "\(make) \(model)"
    }
    
    // MARK: - Initialization
    
    init(
        carId: UUID = UUID(),
        make: String,
        model: String,
        year: Int? = nil,
        tankCapacity: Double,
        imageData: Data? = nil,
        isSelected: Bool = false
    ) {
        self.carId = carId
        self.make = make
        self.model = model
        self.year = year
        self.tankCapacity = tankCapacity
        self.imageData = imageData
        self.lastModified = Date()
        self.isSelected = isSelected
    }
    
    // MARK: - Conversion Methods
    
    /// Creates a SwiftData car from a legacy Car struct
    convenience init(from legacy: Car, isSelected: Bool = false) {
        self.init(
            carId: legacy.id,
            make: legacy.make,
            model: legacy.model,
            year: legacy.year,
            tankCapacity: legacy.tankCapacity,
            imageData: legacy.imageData,
            isSelected: isSelected
        )
    }
    
    /// Converts back to a Car struct (for compatibility with existing views)
    func toCar() -> Car {
        Car(
            id: carId,
            make: make,
            model: model,
            year: year,
            tankCapacity: tankCapacity,
            imageData: imageData
        )
    }
    
    /// Updates all properties from a Car struct
    func update(from car: Car) {
        self.make = car.make
        self.model = car.model
        self.year = car.year
        self.tankCapacity = car.tankCapacity
        self.imageData = car.imageData
        self.lastModified = Date()
    }
}
