import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class TrackingViewModel: ObservableObject {
    @Published var sessions: [SessionRecord] = []
    @Published var currentSession: SessionRecord?
    @Published var isSessionActive: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var isLoading: Bool = false
    @Published var showSessionComplete: Bool = false
    @Published var lastCompletedDuration: Int = 0

    private var timer: Timer?
    private var modelContext: ModelContext?
    private var sessionStartTime: Date?

    init() {}

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await loadSessions()
        }
    }

    // MARK: - Session Timer
    func startSession(type: SessionType, notes: String? = nil) {
        guard !isSessionActive else { return }

        sessionStartTime = Date()
        elapsedSeconds = 0
        isSessionActive = true

        currentSession = SessionRecord(
            sessionType: type,
            notes: notes
        )

        startTimer()
    }

    func pauseSession() {
        stopTimer()
    }

    func resumeSession() {
        guard isSessionActive else { return }
        startTimer()
    }

    func endSession() async {
        stopTimer()

        guard let session = currentSession else {
            isSessionActive = false
            return
        }

        session.durationSeconds = elapsedSeconds
        session.completed = true

        lastCompletedDuration = elapsedSeconds

        await saveSession(session)

        currentSession = nil
        isSessionActive = false
        elapsedSeconds = 0
        sessionStartTime = nil

        showSessionComplete = true
    }

    func cancelSession() {
        stopTimer()
        currentSession = nil
        isSessionActive = false
        elapsedSeconds = 0
        sessionStartTime = nil
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Data Operations
    func loadSessions() async {
        guard let context = modelContext else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            var descriptor = FetchDescriptor<SessionRecord>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            descriptor.fetchLimit = 100
            sessions = try context.fetch(descriptor)
        } catch {
            print("Error loading sessions: \(error)")
        }
    }

    private func saveSession(_ session: SessionRecord) async {
        guard let context = modelContext else { return }

        context.insert(session)

        do {
            try context.save()
            sessions.insert(session, at: 0)
        } catch {
            print("Error saving session: \(error)")
        }
    }

    func deleteSession(_ session: SessionRecord) async {
        guard let context = modelContext else { return }

        context.delete(session)

        do {
            try context.save()
            sessions.removeAll { $0.id == session.id }
        } catch {
            print("Error deleting session: \(error)")
        }
    }

    // MARK: - Statistics
    var totalSessions: Int {
        sessions.filter { $0.completed }.count
    }

    var totalMinutes: Int {
        sessions
            .filter { $0.completed }
            .reduce(0) { $0 + $1.durationSeconds } / 60
    }

    var thisWeekSessions: Int {
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions
            .filter { $0.completed && $0.date >= weekStart }
            .count
    }

    var thisWeekMinutes: Int {
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return sessions
            .filter { $0.completed && $0.date >= weekStart }
            .reduce(0) { $0 + $1.durationSeconds } / 60
    }

    var averageSessionMinutes: Int {
        let completedSessions = sessions.filter { $0.completed }
        guard !completedSessions.isEmpty else { return 0 }
        let totalSeconds = completedSessions.reduce(0) { $0 + $1.durationSeconds }
        return totalSeconds / completedSessions.count / 60
    }

    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        let sortedSessions = sessions
            .filter { $0.completed }
            .sorted { $0.date > $1.date }

        for session in sortedSessions {
            let sessionDay = calendar.startOfDay(for: session.date)

            if sessionDay == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if sessionDay < checkDate {
                break
            }
        }

        return streak
    }

    // MARK: - Completion Message
    var completionMessage: String {
        let minutes = lastCompletedDuration / 60
        let streak = currentStreak

        if streak >= 7 {
            return "MashaAllah! \(streak) days in a row. Your consistency is inspiring."
        } else if streak >= 3 {
            return "Alhamdulillah! \(streak)-day streak. Keep it going!"
        } else if minutes >= 10 {
            return "Barakallahu feek! A beautiful \(minutes)-minute session."
        } else {
            return "Alhamdulillah! Every moment of recitation counts."
        }
    }

    // MARK: - Formatting
    var elapsedTimeFormatted: String {
        elapsedSeconds.durationFormatted
    }

    var recentSessions: [SessionRecord] {
        Array(sessions.prefix(5))
    }
}
