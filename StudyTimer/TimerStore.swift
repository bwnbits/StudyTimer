import Foundation
import Combine
import WidgetKit
import AppKit
import UserNotifications

struct StudyTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone = false

    init(title: String) {
        id = UUID()
        self.title = title
    }
}

struct Reminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var date: Date

    init(title: String, date: Date) {
        id = UUID()
        self.title = title
        self.date = date
    }
}

private struct SavedState: Codable {
    var duration: TimeInterval
    var elapsed: TimeInterval
    var targetDate: Date?
    var laps: [TimeInterval]
    var tasks: [StudyTask]
    var reminders: [Reminder]
}

@MainActor
final class TimerStore: ObservableObject {
    @Published var duration: TimeInterval = 25 * 60
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var startDate: Date?
    @Published private(set) var targetDate: Date?
    @Published private(set) var laps: [TimeInterval] = []
    @Published var tasks: [StudyTask] = []
    @Published var reminders: [Reminder] = []

    private var timer: AnyCancellable?
    private let defaults = UserDefaults(suiteName: "group.com.bwnbits.studytimer") ?? .standard
    private let stateKey = "studyTimer.state"
    private let notifiedReminderKey = "studyTimer.notifiedReminders"

    init() {
        load()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh()
            }
    }

    var isRunning: Bool { targetDate != nil }
    var remaining: TimeInterval { max(duration - currentElapsed(), 0) }
    var progress: Double { duration > 0 ? min(currentElapsed() / duration, 1) : 0 }

    func setDuration(_ duration: TimeInterval) {
        guard !isRunning else { return }
        self.duration = duration
        elapsed = 0
        laps = []
        save()
    }

    func start() {
        guard !isRunning, remaining > 0 else { return }
        startDate = Date()
        targetDate = Date().addingTimeInterval(remaining)
        save()
    }

    func pause() {
        guard isRunning else { return }
        elapsed = currentElapsed()
        startDate = nil
        targetDate = nil
        save()
    }

    func reset() {
        elapsed = 0
        startDate = nil
        targetDate = nil
        laps = []
        save()
    }

    func addLap() {
        guard isRunning else { return }
        laps.insert(currentElapsed(), at: 0)
        save()
    }

    func addTask(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.insert(StudyTask(title: trimmed), at: 0)
        save()
    }

    func toggleTask(_ task: StudyTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        save()
    }

    func deleteTask(_ task: StudyTask) {
        tasks.removeAll { $0.id == task.id }
        save()
    }

    func addReminder(_ title: String, at date: Date) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        reminders.append(Reminder(title: trimmed, date: date))
        reminders.sort { $0.date < $1.date }
        save()
        scheduleReminder(reminders.last { $0.title == trimmed && $0.date == date } ?? reminders.last!)
    }

    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        save()
    }

    func currentElapsed(at date: Date = Date()) -> TimeInterval {
        guard let startDate else { return elapsed }
        return min(duration, elapsed + max(date.timeIntervalSince(startDate), 0))
    }

    private func refresh() {
        checkMissedReminders()
        guard isRunning else { return }
        if let targetDate, Date() >= targetDate {
            elapsed = duration
            startDate = nil
            self.targetDate = nil
            save()
            NSSound.beep()
            sendNotification(title: "Study session complete", body: "Your \(duration.clockText) session is finished.")
        } else {
            objectWillChange.send()
        }
    }

    private func requestNotificationAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] _, _ in
            Task { @MainActor in
                self?.scheduleAllReminders()
                self?.checkMissedReminders()
            }
        }
    }

    func notificationPermissionStatus() async -> UNAuthorizationStatus {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    func requestNotifications() {
        requestNotificationAccess()
    }

    private func scheduleAllReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: reminders.map { "reminder-\($0.id.uuidString)" })
        for reminder in reminders where reminder.date > Date() {
            scheduleReminder(reminder)
        }
    }

    private func scheduleReminder(_ reminder: Reminder) {
        guard reminder.date > Date() else {
            sendMissedReminderIfNeeded(reminder)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "Your Study Timer reminder is due."
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "reminder-\(reminder.id.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func checkMissedReminders() {
        for reminder in reminders where reminder.date <= Date() {
            sendMissedReminderIfNeeded(reminder)
        }
    }

    private func sendMissedReminderIfNeeded(_ reminder: Reminder) {
        var notified = Set(defaults.stringArray(forKey: notifiedReminderKey) ?? [])
        guard !notified.contains(reminder.id.uuidString) else { return }
        notified.insert(reminder.id.uuidString)
        defaults.set(Array(notified), forKey: notifiedReminderKey)
        NSSound.beep()
        sendNotification(title: "Missed reminder", body: reminder.title)
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: "event-\(UUID().uuidString)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func save() {
        let state = SavedState(duration: duration, elapsed: elapsed, targetDate: targetDate, laps: laps, tasks: tasks, reminders: reminders)
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: stateKey)
            WidgetCenter.shared.reloadTimelines(ofKind: "StudyTimerWidget")
        }
    }

    private func load() {
        guard let data = defaults.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(SavedState.self, from: data) else { return }
        duration = state.duration
        elapsed = state.elapsed
        targetDate = state.targetDate
        if targetDate != nil {
            startDate = Date().addingTimeInterval(-max(duration - (targetDate?.timeIntervalSince(Date()) ?? duration), 0))
        }
        laps = state.laps
        tasks = state.tasks
        reminders = state.reminders
        refresh()
    }
}

extension TimeInterval {
    var clockText: String {
        let total = max(Int(rounded()), 0)
        return String(format: "%02d:%02d:%02d", total / 3600, (total % 3600) / 60, total % 60)
    }
}
