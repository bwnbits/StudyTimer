import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject private var store: TimerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STUDY TIMER")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(store.remaining.clockText)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .monospacedDigit()

            ProgressView(value: store.progress)
                .tint(store.isRunning ? .green : .indigo)

            HStack {
                Button(store.isRunning ? "Pause" : "Start") {
                    store.isRunning ? store.pause() : store.start()
                }
                .buttonStyle(.borderedProminent)
                .tint(store.isRunning ? .orange : .indigo)

                Button("Reset") { store.reset() }
                    .buttonStyle(.bordered)
            }

            Divider()

            Button("Open Study Timer") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
            }

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(14)
        .frame(width: 230)
    }
}

struct MenuBarLabel: View {
    @EnvironmentObject private var store: TimerStore

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: store.isRunning ? "timer" : "pause.circle")
            Text(store.remaining.clockText)
                .monospacedDigit()
        }
    }
}
