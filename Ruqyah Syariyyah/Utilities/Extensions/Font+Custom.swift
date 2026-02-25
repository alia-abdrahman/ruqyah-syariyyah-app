import SwiftUI
import UIKit

extension Font {
    // MARK: - Poppins Font
    static func poppins(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let weightName: String
        switch weight {
        case .bold:
            weightName = "Bold"
        case .semibold:
            weightName = "SemiBold"
        case .medium:
            weightName = "Medium"
        case .light:
            weightName = "Light"
        default:
            weightName = "Regular"
        }

        // Try custom font, fall back to system if not available
        if UIFont(name: "Poppins-\(weightName)", size: size) != nil {
            return .custom("Poppins-\(weightName)", size: size)
        }
        return .system(size: size, weight: weight)
    }

    // MARK: - Arabic Font (Amiri Quran)
    static func amiriQuran(_ size: CGFloat) -> Font {
        // Try custom font, fall back to system if not available
        if UIFont(name: "AmiriQuran-Regular", size: size) != nil {
            return .custom("AmiriQuran-Regular", size: size)
        }
        return .system(size: size)
    }

    // MARK: - System Fallback with Poppins
    static var headingLarge: Font {
        poppins(32, weight: .bold)
    }

    static var headingMedium: Font {
        poppins(AppConstants.textSizeHeading, weight: .bold)
    }

    static var headingSmall: Font {
        poppins(AppConstants.textSizeTitle, weight: .semibold)
    }

    static var bodyLarge: Font {
        poppins(AppConstants.textSizeBody, weight: .regular)
    }

    static var bodyMedium: Font {
        poppins(14, weight: .regular)
    }

    static var bodySmall: Font {
        poppins(AppConstants.textSizeSmall, weight: .regular)
    }

    static var arabicText: Font {
        amiriQuran(AppConstants.textSizeArabic)
    }

    static func arabicText(size: CGFloat) -> Font {
        amiriQuran(size)
    }

    static var caption: Font {
        poppins(11, weight: .regular)
    }

    static var button: Font {
        poppins(AppConstants.textSizeBody, weight: .semibold)
    }
}

// MARK: - View Extension for Arabic Text
extension View {
    func arabicTextStyle(size: CGFloat = AppConstants.textSizeArabic, color: Color = .textPrimary) -> some View {
        self
            .font(.amiriQuran(size))
            .foregroundColor(color)
            .multilineTextAlignment(.trailing)
            .lineSpacing(12)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
