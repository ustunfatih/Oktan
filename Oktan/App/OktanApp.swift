import SwiftUI

@main
struct OktanApp: App {
    @StateObject private var repository = FuelRepository()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(repository)
                    .opacity(showSplash ? 0 : 1)
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                // Dismiss splash after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var repository: FuelRepository

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            TrackingView()
                .tabItem {
                    Label("Tracking", systemImage: "fuelpump.fill")
                }

            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "chart.bar.fill")
                }
        }
        .tint(DesignSystem.ColorPalette.primaryBlue)
        .onAppear { repository.bootstrapIfNeeded() }
    }
}
