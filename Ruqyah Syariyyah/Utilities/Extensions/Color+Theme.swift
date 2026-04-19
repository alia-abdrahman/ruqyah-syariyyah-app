import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let primaryGreen = Color(hex: "2D6A4F")
    static let primaryGreenLight = Color(hex: "86C5A3")
    static let primaryGreenDark = Color(hex: "1B4D36")

    // MARK: - Accent Colors
    static let accentPurple = Color(hex: "8B5CF6")
    static let accentGold = Color(hex: "F59E0B")
    static let accentBlue = Color(hex: "3B82F6")

    // MARK: - Background Colors
    static let backgroundLight = Color(hex: "F9FAFB")
    static let backgroundDark = Color(hex: "111827")

    // MARK: - Surface Colors
    static let surfaceLight = Color.white
    static let surfaceDark = Color(hex: "1F2937")

    // MARK: - Text Colors
    static let textPrimary = Color(hex: "111827")
    static let textSecondary = Color(hex: "6B7280")
    static let textDark = Color.white
    static let textDarkSecondary = Color(hex: "9CA3AF")

    // MARK: - Gradients
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryGreenLight, primaryGreen],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var headerGradient: LinearGradient {
        LinearGradient(
            colors: [primaryGreen, primaryGreenDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var verseCardGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "B5D8C7"), Color(hex: "5BA88A"), Color(hex: "2D6A4F")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let mintBackgroundLight = Color(hex: "EEF6F1")
    static let mintBackgroundDark = Color(hex: "1A2E24")

    static func adaptiveMint(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? mintBackgroundDark : mintBackgroundLight
    }

    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme-Aware Colors
extension Color {
    static func adaptiveBackground(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? backgroundDark : backgroundLight
    }

    static func adaptiveSurface(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? surfaceDark : surfaceLight
    }

    static func adaptiveText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textDark : textPrimary
    }

    static func adaptiveSecondaryText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? textDarkSecondary : textSecondary
    }

    static func adaptivePrimary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? primaryGreenLight : primaryGreen
    }
}
