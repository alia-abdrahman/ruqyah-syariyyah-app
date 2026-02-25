import Foundation

// MARK: - Language
enum Language: String, CaseIterable, Codable {
    case english = "en"
    case malay = "ms"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .malay: return "Bahasa Melayu"
        }
    }
}

// MARK: - Session Type
enum SessionType: String, CaseIterable, Codable {
    case audio = "audio"
    case reading = "reading"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .audio: return "Audio Session"
        case .reading: return "Reading Session"
        case .custom: return "Custom Session"
        }
    }

    var icon: String {
        switch self {
        case .audio: return "headphones"
        case .reading: return "book"
        case .custom: return "sparkles"
        }
    }
}

// MARK: - Theme Mode
enum ThemeMode: String, CaseIterable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - Category
enum Category: String, CaseIterable, Codable {
    case all = "All"
    case quran = "Quran"
    case dua = "Dua"
    case dhikr = "Dhikr"

    var displayName: String {
        rawValue
    }
}
