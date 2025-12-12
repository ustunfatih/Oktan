import SwiftUI
import RevenueCat

@Observable
class PremiumManager {
    var isPremium = false
    
    init() {
        // Initialize RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "test_HcxhrgEARdQuoUxajGLEasDwAGm")
        
        // Listen for subscription status changes
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                await updatePremiumStatus(customerInfo)
            }
        }
    }
    
    @MainActor
    func updatePremiumStatus(_ info: CustomerInfo) {
        // Check for "Oktan Pro" entitlement
        self.isPremium = info.entitlements["Oktan Pro"]?.isActive == true
    }
    
    /// Restores purchases (called manually if needed, though stream usually handles it)
    func restore() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            await updatePremiumStatus(info)
        } catch {
            print("Restore failed: \(error)")
        }
    }
}
