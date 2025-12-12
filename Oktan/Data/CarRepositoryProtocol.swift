import Foundation

/// Protocol defining the car repository interface
/// Both legacy (JSON) and SwiftData implementations conform to this
protocol CarRepositoryProtocol: AnyObject {
    /// The currently selected car
    var selectedCar: Car? { get }
    
    /// Whether a car is currently selected
    var hasCar: Bool { get }
    
    /// Saves a new car as the selected car
    func saveCar(_ car: Car)
    
    /// Updates the car image
    func updateCarImage(_ imageData: Data)
    
    /// Updates the tank capacity
    func updateTankCapacity(_ capacity: Double)
    
    /// Deletes the selected car
    func deleteCar()
}

// MARK: - Legacy CarRepository Conformance

extension CarRepository: CarRepositoryProtocol {}
