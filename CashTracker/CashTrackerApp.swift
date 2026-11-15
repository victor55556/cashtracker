import SwiftUI

@main
struct CashTrackerApp: App {
    @StateObject private var store = CashStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
