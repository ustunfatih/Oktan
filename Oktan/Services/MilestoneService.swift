import Foundation
import SwiftUI

struct Milestone: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    var dateAchieved: Date?
}

@Observable
final class MilestoneService {
    var milestones: [Milestone] = []
    
    func checkMilestones(entries: [FuelEntry], summary: FuelSummary) {
        var newMilestones: [Milestone] = []
        
        // 1. First Drop
        if let firstEntry = entries.sorted(by: { $0.date < $1.date }).first {
            newMilestones.append(Milestone(
                id: "first_drop",
                title: "First Drop",
                description: "Logged your first fill-up!",
                icon: "drop.fill",
                color: .blue,
                dateAchieved: firstEntry.date
            ))
        }
        
        // 2. Economy Master (Best efficiency)
        if let bestEfficiency = entries.compactMap({ $0.litersPer100KM }).min(), bestEfficiency > 0 {
            newMilestones.append(Milestone(
                id: "economy_master",
                title: "Economy Master",
                description: "Achieved your best efficiency: \(String(format: "%.1f", bestEfficiency)) L/100km",
                icon: "leaf.fill",
                color: .green,
                dateAchieved: entries.first(where: { $0.litersPer100KM == bestEfficiency })?.date
            ))
        }
        
        // 3. Long Haul (Longest distance)
        if let maxDistance = entries.compactMap({ $0.distance }).max(), maxDistance > 0 {
            newMilestones.append(Milestone(
                id: "long_haul",
                title: "Long Haul",
                description: "Longest trip on a single tank: \(Int(maxDistance)) km",
                icon: "road.lanes",
                color: .orange,
                dateAchieved: entries.first(where: { $0.distance == maxDistance })?.date
            ))
        }
        
        // 4. Road Warrior (Total Distance)
        let totalDist = summary.totalDistance
        if totalDist >= 1000 {
            newMilestones.append(Milestone(
                id: "road_warrior_1000",
                title: "Road Warrior I",
                description: "Reached 1,000 km total distance!",
                icon: "crown.fill",
                color: .purple,
                dateAchieved: Date() // Simplified for now
            ))
        }
        
        self.milestones = newMilestones
    }
}

