import SwiftUI

@main
struct StudyTimerApp: App {
    @StateObject private var store = TimerStore()

    var body: some Scene {
        WindowGroup("Study Timer") {
            ContentView()
                .environmentObject(store)
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(store)
        } label: {
            MenuBarLabel()
                .environmentObject(store)
        }
        .menuBarExtraStyle(.menu)
    }
}
