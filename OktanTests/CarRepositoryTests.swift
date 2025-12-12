import XCTest
@testable import oktan

/// Tests for CarRepository and Car model
final class CarRepositoryTests: XCTestCase {
    
    var repository: CarRepository!
    
    override func setUp() {
        repository = CarRepository()
        // Clean up any existing car
        repository.deleteCar()
    }
    
    override func tearDown() {
        repository.deleteCar()
        repository = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateHasNoCar() {
        XCTAssertNil(repository.selectedCar)
        XCTAssertFalse(repository.hasCar)
    }
    
    // MARK: - Save Car Tests
    
    func testSaveCarUpdatesSelectedCar() {
        let car = makeCar()
        repository.saveCar(car)
        
        XCTAssertNotNil(repository.selectedCar)
        XCTAssertEqual(repository.selectedCar?.id, car.id)
        XCTAssertTrue(repository.hasCar)
    }
    
    func testSaveCarWithAllProperties() {
        let car = makeCar(
            make: "Toyota",
            model: "Camry",
            year: 2024,
            tankCapacity: 60
        )
        repository.saveCar(car)
        
        XCTAssertEqual(repository.selectedCar?.make, "Toyota")
        XCTAssertEqual(repository.selectedCar?.model, "Camry")
        XCTAssertEqual(repository.selectedCar?.year, 2024)
        XCTAssertEqual(repository.selectedCar?.tankCapacity, 60)
    }
    
    func testSaveCarOverwritesPreviousCar() {
        let firstCar = makeCar(make: "Toyota", model: "Corolla")
        let secondCar = makeCar(make: "Honda", model: "Civic")
        
        repository.saveCar(firstCar)
        repository.saveCar(secondCar)
        
        XCTAssertEqual(repository.selectedCar?.make, "Honda")
        XCTAssertEqual(repository.selectedCar?.model, "Civic")
    }
    
    // MARK: - Update Car Image Tests
    
    func testUpdateCarImageWhenCarExists() {
        let car = makeCar()
        repository.saveCar(car)
        
        let imageData = "test image data".data(using: .utf8)!
        repository.updateCarImage(imageData)
        
        XCTAssertEqual(repository.selectedCar?.imageData, imageData)
    }
    
    func testUpdateCarImageWhenNoCarDoesNothing() {
        let imageData = "test image data".data(using: .utf8)!
        repository.updateCarImage(imageData)
        
        XCTAssertNil(repository.selectedCar)
    }
    
    // MARK: - Update Tank Capacity Tests
    
    func testUpdateTankCapacityWhenCarExists() {
        let car = makeCar(tankCapacity: 50)
        repository.saveCar(car)
        
        repository.updateTankCapacity(70)
        
        XCTAssertEqual(repository.selectedCar?.tankCapacity, 70)
    }
    
    func testUpdateTankCapacityWhenNoCarDoesNothing() {
        repository.updateTankCapacity(70)
        
        XCTAssertNil(repository.selectedCar)
    }
    
    // MARK: - Delete Car Tests
    
    func testDeleteCarRemovesCar() {
        let car = makeCar()
        repository.saveCar(car)
        
        repository.deleteCar()
        
        XCTAssertNil(repository.selectedCar)
        XCTAssertFalse(repository.hasCar)
    }
    
    func testDeleteCarWhenNoCarDoesNothing() {
        // Should not crash
        repository.deleteCar()
        
        XCTAssertNil(repository.selectedCar)
    }
    
    // MARK: - Car Model Tests
    
    func testCarDisplayNameWithYear() {
        let car = makeCar(make: "BMW", model: "3 Series", year: 2023)
        
        XCTAssertEqual(car.displayName, "2023 BMW 3 Series")
    }
    
    func testCarDisplayNameWithoutYear() {
        let car = makeCar(make: "BMW", model: "3 Series", year: nil)
        
        XCTAssertEqual(car.displayName, "BMW 3 Series")
    }
    
    func testCarEquatable() {
        let id = UUID()
        let car1 = Car(id: id, make: "Toyota", model: "Corolla", year: 2024, tankCapacity: 50)
        let car2 = Car(id: id, make: "Toyota", model: "Corolla", year: 2024, tankCapacity: 50)
        
        XCTAssertEqual(car1, car2)
    }
    
    func testCarCodable() throws {
        let original = makeCar(make: "Honda", model: "Civic", year: 2024, tankCapacity: 47)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Car.self, from: data)
        
        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.make, decoded.make)
        XCTAssertEqual(original.model, decoded.model)
        XCTAssertEqual(original.year, decoded.year)
        XCTAssertEqual(original.tankCapacity, decoded.tankCapacity)
    }
    
    // MARK: - Car Database Tests
    
    func testCarDatabaseHasMakes() {
        XCTAssertGreaterThan(CarDatabase.makes.count, 30, "Should have many car makes")
    }
    
    func testCarDatabaseMakesHaveModels() {
        for make in CarDatabase.makes {
            XCTAssertFalse(make.models.isEmpty, "\(make.name) should have models")
        }
    }
    
    func testCarDatabaseTankCapacityLookup() {
        let capacity = CarDatabase.tankCapacity(make: "Toyota", model: "Camry")
        
        XCTAssertNotNil(capacity)
        XCTAssertEqual(capacity, 60)
    }
    
    func testCarDatabaseTankCapacityLookupInvalidMake() {
        let capacity = CarDatabase.tankCapacity(make: "InvalidMake", model: "Corolla")
        
        XCTAssertNil(capacity)
    }
    
    func testCarDatabaseTankCapacityLookupInvalidModel() {
        let capacity = CarDatabase.tankCapacity(make: "Toyota", model: "InvalidModel")
        
        XCTAssertNil(capacity)
    }
    
    func testCarDatabaseModelsForMake() {
        let toyotaModels = CarDatabase.models(for: "Toyota")
        
        XCTAssertGreaterThan(toyotaModels.count, 10, "Toyota should have many models")
    }
    
    func testCarDatabaseModelsForInvalidMake() {
        let models = CarDatabase.models(for: "InvalidMake")
        
        XCTAssertTrue(models.isEmpty)
    }
    
    func testCarDatabaseElectricVehiclesHaveZeroTankCapacity() {
        // Tesla models should all have 0 tank capacity
        let teslaModels = CarDatabase.models(for: "Tesla")
        
        for model in teslaModels {
            XCTAssertEqual(model.tankCapacity, 0, "Tesla \(model.name) should have 0 tank capacity (electric)")
        }
    }
    
    func testCarDatabaseContainsExpectedBrands() {
        let makeNames = CarDatabase.makes.map { $0.name }
        
        // Popular brands that should definitely be present
        let expectedBrands = ["Toyota", "Honda", "BMW", "Mercedes-Benz", "Volkswagen", "Hyundai", "Kia"]
        
        for brand in expectedBrands {
            XCTAssertTrue(makeNames.contains(brand), "Should contain \(brand)")
        }
    }
    
    func testCarDatabaseContainsTurkishBrand() {
        let makeNames = CarDatabase.makes.map { $0.name }
        
        XCTAssertTrue(makeNames.contains("TOGG"), "Should contain Turkish brand TOGG")
    }
    
    func testCarDatabaseTankCapacitiesAreReasonable() {
        for make in CarDatabase.makes {
            for model in make.models {
                // Tank capacity should be 0 (electric) or between 30-150 liters
                let isElectric = model.tankCapacity == 0
                let isReasonable = model.tankCapacity >= 30 && model.tankCapacity <= 150
                
                XCTAssertTrue(isElectric || isReasonable, 
                             "\(make.name) \(model.name) has unusual tank capacity: \(model.tankCapacity)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func makeCar(
        id: UUID = UUID(),
        make: String = "Test Make",
        model: String = "Test Model",
        year: Int? = 2024,
        tankCapacity: Double = 50,
        imageData: Data? = nil
    ) -> Car {
        Car(
            id: id,
            make: make,
            model: model,
            year: year,
            tankCapacity: tankCapacity,
            imageData: imageData
        )
    }
}
