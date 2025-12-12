import Foundation
import SwiftData
import SwiftUI

/// SwiftData-based car repository
/// Replaces the JSON-based CarRepository while maintaining API compatibility
@MainActor
@Observable
final class CarRepositorySD: CarRepositoryProtocol {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    /// The currently selected car
    private(set) var selectedCar: Car?
    
    /// Whether a car is currently selected
    var hasCar: Bool {
        selectedCar != nil
    }
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSelectedCar()
    }
    
    // MARK: - CRUD Operations
    
    /// Saves a new car (replaces any existing selected car)
    func saveCar(_ car: Car) {
        // First, unselect any existing cars
        unselectAllCars()
        
        // Check if car already exists
        let descriptor = FetchDescriptor<CarSD>(
            predicate: #Predicate { $0.carId == car.id }
        )
        
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                existing.update(from: car)
                existing.isSelected = true
            } else {
                let sdCar = CarSD(from: car, isSelected: true)
                modelContext.insert(sdCar)
            }
            
            try modelContext.save()
            loadSelectedCar()
        } catch {
            print("Failed to save car: \(error)")
        }
    }
    
    /// Updates the car image
    func updateCarImage(_ imageData: Data) {
        guard let currentCar = selectedCar else { return }
        
        let descriptor = FetchDescriptor<CarSD>(
            predicate: #Predicate { $0.carId == currentCar.id }
        )
        
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                existing.imageData = imageData
                existing.lastModified = Date()
                try modelContext.save()
                loadSelectedCar()
            }
        } catch {
            print("Failed to update car image: \(error)")
        }
    }
    
    /// Updates the tank capacity
    func updateTankCapacity(_ capacity: Double) {
        guard let currentCar = selectedCar else { return }
        
        let descriptor = FetchDescriptor<CarSD>(
            predicate: #Predicate { $0.carId == currentCar.id }
        )
        
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                existing.tankCapacity = capacity
                existing.lastModified = Date()
                try modelContext.save()
                loadSelectedCar()
            }
        } catch {
            print("Failed to update tank capacity: \(error)")
        }
    }
    
    /// Deletes the selected car
    func deleteCar() {
        guard let currentCar = selectedCar else { return }
        
        let descriptor = FetchDescriptor<CarSD>(
            predicate: #Predicate { $0.carId == currentCar.id }
        )
        
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                modelContext.delete(existing)
                try modelContext.save()
            }
            selectedCar = nil
        } catch {
            print("Failed to delete car: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSelectedCar() {
        let descriptor = FetchDescriptor<CarSD>(
            predicate: #Predicate { $0.isSelected == true }
        )
        
        do {
            if let sdCar = try modelContext.fetch(descriptor).first {
                selectedCar = sdCar.toCar()
            } else {
                selectedCar = nil
            }
        } catch {
            print("Failed to load selected car: \(error)")
            selectedCar = nil
        }
    }
    
    private func unselectAllCars() {
        let descriptor = FetchDescriptor<CarSD>(
            predicate: #Predicate { $0.isSelected == true }
        )
        
        do {
            let selectedCars = try modelContext.fetch(descriptor)
            for car in selectedCars {
                car.isSelected = false
            }
        } catch {
            print("Failed to unselect cars: \(error)")
        }
    }
}
