import Foundation
import SwiftUI

@Observable
class CarRepository {
    private(set) var selectedCar: Car?
    private let storageURL: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        storageURL = directory.appendingPathComponent("selected_car.json")
        loadFromDisk()
    }
    
    var hasCar: Bool {
        selectedCar != nil
    }
    
    func saveCar(_ car: Car) {
        selectedCar = car
        persistToDisk()
    }
    
    func updateCarImage(_ imageData: Data) {
        guard var car = selectedCar else { return }
        car.imageData = imageData
        selectedCar = car
        persistToDisk()
    }
    
    func updateTankCapacity(_ capacity: Double) {
        guard var car = selectedCar else { return }
        car.tankCapacity = capacity
        selectedCar = car
        persistToDisk()
    }
    
    func deleteCar() {
        selectedCar = nil
        try? FileManager.default.removeItem(at: storageURL)
    }
    
    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: storageURL) else { return }
        selectedCar = try? decoder.decode(Car.self, from: data)
    }
    
    private func persistToDisk() {
        guard let car = selectedCar, let data = try? encoder.encode(car) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }
}
