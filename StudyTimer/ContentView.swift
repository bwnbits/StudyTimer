import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: TimerStore
    @State private var taskText = ""
    @State private var reminderText = ""
    @State private var reminderDate = Date().addingTimeInterval(3600)
    @State private var customMinutes = "30"

    private let presets: [(String, TimeInterval)] = [("15m", 15 * 60), ("25m", 25 * 60), ("50m", 50 * 60)]

    var body: some View {
        VStack(spacing: 0) {
            header
            timerPanel
            Divider()
            lowerPanel
        }
        .frame(minWidth: 620, minHeight: 620)
        .padding(28)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("STUDY TIMER")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text("One clear block at a time.")
                    .font(.title2.weight(.semibold))
            }
            Spacer()
            Text(Date(), style: .time)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 26)
    }

    private var timerPanel: some View {
        VStack(spacing: 20) {
            Text(store.remaining.clockText)
                .font(.system(size: 78, weight: .medium, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())

            ProgressView(value: store.progress)
                .tint(store.isRunning ? .green : .indigo)
                .frame(maxWidth: 400)

            HStack(spacing: 10) {
                ForEach(presets, id: \.0) { preset in
                    Button(preset.0) { store.setDuration(preset.1) }
                        .buttonStyle(.bordered)
                        .tint(store.duration == preset.1 ? .indigo : .secondary)
                        .disabled(store.isRunning)
                }

                HStack(spacing: 6) {
                    TextField("Min", text: $customMinutes)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 54)
                        .multilineTextAlignment(.trailing)
                    Button("Set") { setCustomDuration() }
                        .buttonStyle(.bordered)
                }
                .disabled(store.isRunning)
            }

            HStack(spacing: 12) {
                Button(store.isRunning ? "Pause" : "Start") {
                    store.isRunning ? store.pause() : store.start()
                }
                .buttonStyle(.borderedProminent)
                .tint(store.isRunning ? .orange : .indigo)
                .keyboardShortcut(.defaultAction)

                Button("Lap") { store.addLap() }
                    .buttonStyle(.bordered)
                    .disabled(!store.isRunning)

                Button("Reset") { store.reset() }
                    .buttonStyle(.bordered)
            }
        }
        .padding(.bottom, 28)
    }

    private var lowerPanel: some View {
        HStack(alignment: .top, spacing: 28) {
            taskList
            reminderList
        }
        .padding(.top, 24)
    }

    private var taskList: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("TASKS", count: store.tasks.filter { !$0.isDone }.count)
            HStack {
                TextField("Add a task", text: $taskText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addTask() }
                Button("Add") { addTask() }
                    .buttonStyle(.bordered)
            }
            if store.tasks.isEmpty {
                Text("No tasks yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.tasks) { task in
                    HStack(spacing: 8) {
                        Button { store.toggleTask(task) } label: {
                            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(task.isDone ? .green : .secondary)
                        }
                        .buttonStyle(.plain)
                        Text(task.title)
                            .strikethrough(task.isDone)
                            .foregroundStyle(task.isDone ? .secondary : .primary)
                        Spacer()
                        Button { store.deleteTask(task) } label: {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var reminderList: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("REMINDERS", count: store.reminders.count)
            HStack {
                TextField("Reminder", text: $reminderText)
                    .textFieldStyle(.roundedBorder)
                Button("Add") { addReminder() }
                    .buttonStyle(.bordered)
            }
            DatePicker("At", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
            if store.reminders.isEmpty {
                Text("No reminders yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.reminders) { reminder in
                    HStack {
                        Image(systemName: "bell")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading) {
                            Text(reminder.title)
                            Text(reminder.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(reminder.date, style: .time)
                            .font(.caption.monospacedDigit())
                        Button { store.deleteReminder(reminder) } label: {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionTitle(_ title: String, count: Int) -> some View {
        HStack {
            Text(title).font(.caption.weight(.bold)).foregroundStyle(.secondary)
            Text("\(count)").font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
    }

    private func addTask() {
        store.addTask(taskText)
        taskText = ""
    }

    private func addReminder() {
        store.addReminder(reminderText, at: reminderDate)
        reminderText = ""
        reminderDate = Date().addingTimeInterval(3600)
    }

    private func setCustomDuration() {
        guard let minutes = Double(customMinutes), minutes.isFinite, minutes > 0 else { return }
        store.setDuration(minutes * 60)
    }
}
