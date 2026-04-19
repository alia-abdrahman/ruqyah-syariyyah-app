import Foundation
import SwiftUI

struct AppConstants {
    // MARK: - App Info
    static let appName = "Ruqyah Syar'iyyah"
    static let appNameArabic = "الرقية الشرعية"
    static let appVersion = "1.0.0"

    // MARK: - Spacing
    static let spacingXSmall: CGFloat = 4
    static let spacingSmall: CGFloat = 8
    static let spacingMedium: CGFloat = 16
    static let spacingLarge: CGFloat = 24
    static let spacingXLarge: CGFloat = 32

    // MARK: - Border Radius
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusXLarge: CGFloat = 20

    // MARK: - Text Sizes
    static let textSizeSmall: CGFloat = 12
    static let textSizeBody: CGFloat = 16
    static let textSizeTitle: CGFloat = 20
    static let textSizeHeading: CGFloat = 24
    static let textSizeArabic: CGFloat = 28

    // MARK: - Audio
    static let defaultPlaybackSpeed: Float = 1.0
    static let playbackSpeedOptions: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    static let repeatCountOptions: [Int] = [0, 2, 3, 5, 7, 10]

    /// Groups that are dhikr/dua/selawat without audio recordings
    static let noAudioGroups: Set<String> = [
        "Protective Dhikr\nand\nSupplications",
        "Dhikr for Protection",
        "Ya Bariu",
        "Selawat Syifa",
        "Selawat Tafrijiyyah",
        "Selawat Munjiyat",
        "Ruqyah Jibril",
    ]

    // MARK: - Animation Durations
    static let animationDurationShort: Double = 0.2
    static let animationDurationMedium: Double = 0.3
    static let animationDurationLong: Double = 0.5

    // MARK: - UserDefaults Keys
    struct Keys {
        static let language = "language"
        static let themeMode = "themeMode"
        static let lastAudioPosition = "lastAudioPosition"
        static let lastAudioId = "lastAudioId"
        static let reminderEnabled = "reminderEnabled"
        static let reminderTime = "reminderTime"
        static let textSize = "textSize"
        static let isFirstRun = "isFirstRun"
        static let arabicTextSize = "arabicTextSize"
        static let lastReadCollectionId = "lastReadCollectionId"
        static let lastReadGroupName = "lastReadGroupName"
        static let lastReadCollectionName = "lastReadCollectionName"
        static let lastReadGroupDisplayName = "lastReadGroupDisplayName"
        static let lastReadMode = "lastReadMode"
        static let lastReadDate = "lastReadDate"
    }
}
