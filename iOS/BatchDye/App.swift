import SwiftUI

@main
struct BatchDyeApp: App {
    @StateObject private var store = BatchDyeStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchdye_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BDHaptics.enabled = hapticsEnabled
                }
        }
    }
}
