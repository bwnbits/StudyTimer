import SwiftUI
import WidgetKit

struct WidgetState: Codable {
    let duration: TimeInterval
    let elapsed: TimeInterval
    let targetDate: Date?
}

struct StudyTimerEntry: TimelineEntry {
    let date: Date
    let state: WidgetState?
}

struct StudyTimerProvider: TimelineProvider {
    private let defaults = UserDefaults(suiteName: "group.com.bwnbits.studytimer")

    func placeholder(in context: Context) -> StudyTimerEntry {
        StudyTimerEntry(date: Date(), state: WidgetState(duration: 25 * 60, elapsed: 8 * 60, targetDate: nil))
    }

    func getSnapshot(in context: Context, completion: @escaping (StudyTimerEntry) -> Void) {
        completion(StudyTimerEntry(date: Date(), state: loadState()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StudyTimerEntry>) -> Void) {
        let now = Date()
        let entry = StudyTimerEntry(date: now, state: loadState())
        completion(Timeline(entries: [entry], policy: .after(now.addingTimeInterval(60))))
    }

    private func loadState() -> WidgetState? {
        guard let data = defaults?.data(forKey: "studyTimer.state") else { return nil }
        return try? JSONDecoder().decode(WidgetState.self, from: data)
    }
}

struct StudyTimerWidgetView: View {
    let entry: StudyTimerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("STUDY TIMER", systemImage: "timer")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if let state = entry.state {
                let remaining = state.targetDate.map { max($0.timeIntervalSince(entry.date), 0) } ?? max(state.duration - state.elapsed, 0)
                let progress = state.duration > 0 ? min(1 - remaining / state.duration, 1) : 0

                Spacer()
                Text(remaining.clockText)
                    .font(.system(size: 54, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .center)
                ProgressView(value: progress)
                    .tint(state.targetDate == nil ? .indigo : .green)
                Text(state.targetDate == nil ? "Ready for your next block" : "Session in progress")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                Spacer()
                Text("Open Study Timer to begin")
                    .font(.title3.weight(.semibold))
                Spacer()
            }
        }
        .padding(20)
        .containerBackground(.background, for: .widget)
    }
}

struct StudyTimerWidget: Widget {
    let kind = "StudyTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StudyTimerProvider()) { entry in
            StudyTimerWidgetView(entry: entry)
        }
        .configurationDisplayName("Study Timer")
        .description("A large view of your current study session.")
        .supportedFamilies([.systemLarge])
    }
}

@main
struct StudyTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        StudyTimerWidget()
    }
}

private extension TimeInterval {
    var clockText: String {
        let total = max(Int(rounded()), 0)
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }
}
