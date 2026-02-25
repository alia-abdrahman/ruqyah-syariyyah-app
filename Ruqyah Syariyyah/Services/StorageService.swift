import Foundation
import SwiftUI
import Combine

@MainActor
class StorageService: ObservableObject {
    static let shared = StorageService()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Language
    var language: Language {
        get {
            guard let rawValue = defaults.string(forKey: AppConstants.Keys.language),
                  let language = Language(rawValue: rawValue) else {
                return .english
            }
            return language
        }
        set {
            defaults.set(newValue.rawValue, forKey: AppConstants.Keys.language)
        }
    }

    // MARK: - Theme Mode
    var themeMode: ThemeMode {
        get {
            guard let rawValue = defaults.string(forKey: AppConstants.Keys.themeMode),
                  let mode = ThemeMode(rawValue: rawValue) else {
                return .system
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: AppConstants.Keys.themeMode)
        }
    }

    // MARK: - First Run
    var isFirstRun: Bool {
        get {
            !defaults.bool(forKey: AppConstants.Keys.isFirstRun)
        }
        set {
            defaults.set(!newValue, forKey: AppConstants.Keys.isFirstRun)
        }
    }

    // MARK: - Reminder Settings
    var reminderEnabled: Bool {
        get {
            defaults.bool(forKey: AppConstants.Keys.reminderEnabled)
        }
        set {
            defaults.set(newValue, forKey: AppConstants.Keys.reminderEnabled)
        }
    }

    var reminderTime: Date {
        get {
            defaults.object(forKey: AppConstants.Keys.reminderTime) as? Date ?? defaultReminderTime
        }
        set {
            defaults.set(newValue, forKey: AppConstants.Keys.reminderTime)
        }
    }

    private var defaultReminderTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    // MARK: - Text Size
    var arabicTextSize: CGFloat {
        get {
            let size = defaults.double(forKey: AppConstants.Keys.arabicTextSize)
            return size > 0 ? size : AppConstants.textSizeArabic
        }
        set {
            defaults.set(newValue, forKey: AppConstants.Keys.arabicTextSize)
        }
    }

    // MARK: - Audio State
    var lastAudioPosition: Double {
        get {
            defaults.double(forKey: AppConstants.Keys.lastAudioPosition)
        }
        set {
            defaults.set(newValue, forKey: AppConstants.Keys.lastAudioPosition)
        }
    }

    var lastAudioId: String? {
        get {
            defaults.string(forKey: AppConstants.Keys.lastAudioId)
        }
        set {
            defaults.set(newValue, forKey: AppConstants.Keys.lastAudioId)
        }
    }

    // MARK: - Reset
    func resetAll() {
        let keys = [
            AppConstants.Keys.language,
            AppConstants.Keys.themeMode,
            AppConstants.Keys.isFirstRun,
            AppConstants.Keys.reminderEnabled,
            AppConstants.Keys.reminderTime,
            AppConstants.Keys.arabicTextSize,
            AppConstants.Keys.lastAudioPosition,
            AppConstants.Keys.lastAudioId
        ]

        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }
}
