import SwiftUI

struct MilestoneBadge: View {
    let milestone: Milestone
    @State private var animate = false
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "circle.fill")
                    .font(.largeTitle)
                    .scaleEffect(2.0)
                    .foregroundStyle(milestone.color.opacity(0.1))
                
                Image(systemName: milestone.icon)
                    .font(.title)
                    .foregroundStyle(milestone.color)
                    .symbolEffect(.bounce, value: animate)
            }
            .padding()
            
            Text(milestone.title)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
        }
        .onAppear {
            animate.toggle()
        }
    }
}

struct MilestoneRow: View {
    let milestones: [Milestone]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(milestones) { milestone in
                    MilestoneBadge(milestone: milestone)
                }
            }
            .padding()
        }
    }
}

