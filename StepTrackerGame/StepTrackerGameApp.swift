import SwiftUI

@main
struct StepTrackerGameApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environment(\.colorScheme, .light)
        }
    }
}
