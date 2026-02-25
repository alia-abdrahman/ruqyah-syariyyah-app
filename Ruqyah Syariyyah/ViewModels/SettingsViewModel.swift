import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var themeMode: ThemeMode {
        didSet {
            StorageService.shared.themeMode = themeMode
        }
    }

    @Published var language: Language {
        didSet {
            StorageService.shared.language = language
        }
    }

    @Published var reminderEnabled: Bool {
        didSet {
            StorageService.shared.reminderEnabled = reminderEnabled
            updateReminder()
        }
    }

    @Published var reminderTime: Date {
        didSet {
            StorageService.shared.reminderTime = reminderTime
            updateReminder()
        }
    }

    @Published var arabicTextSize: CGFloat {
        didSet {
            StorageService.shared.arabicTextSize = arabicTextSize
        }
    }

    @Published var isNotificationAuthorized: Bool = false

    private let notificationService = NotificationService.shared

    init() {
        let storage = StorageService.shared
        self.themeMode = storage.themeMode
        self.language = storage.language
        self.reminderEnabled = storage.reminderEnabled
        self.reminderTime = storage.reminderTime
        self.arabicTextSize = storage.arabicTextSize

        Task {
            await checkNotificationStatus()
        }
    }

    // MARK: - Theme
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    // MARK: - Notifications
    func checkNotificationStatus() async {
        await notificationService.checkAuthorizationStatus()
        isNotificationAuthorized = notificationService.isAuthorized
    }

    func requestNotificationPermission() async {
        let granted = await notificationService.requestAuthorization()
        isNotificationAuthorized = granted
        if granted && reminderEnabled {
            updateReminder()
        }
    }

    private func updateReminder() {
        if reminderEnabled && isNotificationAuthorized {
            notificationService.scheduleDailyReminder(at: reminderTime)
        } else {
            notificationService.cancelDailyReminder()
        }
    }

    // MARK: - Text Size
    static let textSizeRange: ClosedRange<CGFloat> = 20...40

    var textSizeLabel: String {
        switch arabicTextSize {
        case ...24: return "Small"
        case 25...32: return "Medium"
        default: return "Large"
        }
    }

    // MARK: - Reset
    func resetAllSettings() {
        StorageService.shared.resetAll()
        themeMode = .system
        language = .english
        reminderEnabled = false
        arabicTextSize = AppConstants.textSizeArabic
    }

    // MARK: - App Info
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
