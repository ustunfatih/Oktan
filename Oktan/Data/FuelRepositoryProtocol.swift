import Foundation
import Combine

/// Protocol defining the fuel repository interface
/// Both legacy (JSON) and SwiftData implementations conform to this
protocol FuelRepositoryProtocol: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
    /// All fuel entries, sorted by date
    var entries: [FuelEntry] { get }
    
    /// Adds a new fuel entry
    @discardableResult
    func add(_ entry: FuelEntry) -> Bool
    
    /// Updates an existing fuel entry
    func update(_ entry: FuelEntry)
    
    /// Deletes a fuel entry
    func delete(_ entry: FuelEntry)
    
    /// Seeds with sample data if empty
    func bootstrapIfNeeded()
    
    /// Returns a summary of all fuel entries
    func summary() -> FuelSummary
    
    /// Exports all entries to CSV format
    func exportToCSV() -> String
    
    /// Creates a shareable CSV file
    func createCSVFile() -> URL?
}

// MARK: - Legacy FuelRepository Conformance

extension FuelRepository: FuelRepositoryProtocol {}
