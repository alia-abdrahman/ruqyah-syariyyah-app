import SwiftUI
import UIKit

/// Mirrors the VerseDetailView layout but rendered as a single flat image
/// (no ScrollView, no action buttons, with branding).
struct ShareCardView: View {
    let verse: RuqyahVerse
    let colorScheme: ColorScheme

    var body: some View {
        VStack(spacing: 20) {
            // Group title
            Text(verse.group)
                .font(.poppins(18, weight: .semibold))
                .foregroundColor(.adaptiveText(colorScheme))
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            // Arabic Text Card
            VStack(spacing: 12) {
                if let number = verse.verseNumber {
                    Text(number)
                        .font(.poppins(14, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                        .frame(width: 38, height: 38)
                        .background(Color.primaryGreen.opacity(0.1))
                        .clipShape(Circle())
                }

                Text(verse.arabicText)
                    .font(.amiriQuran(24))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .multilineTextAlignment(.center)
                    .lineSpacing(14)
                    .padding(.horizontal, 8)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)

            // Translation Card
            VStack(alignment: .leading, spacing: 12) {
                Text("Translation")
                    .font(.poppins(16, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))

                Rectangle()
                    .fill(Color.adaptiveSecondaryText(colorScheme).opacity(0.2))
                    .frame(height: 0.5)

                // English
                VStack(alignment: .leading, spacing: 4) {
                    Text("English")
                        .font(.poppins(11, weight: .regular))
                        .foregroundColor(.adaptiveSecondaryText(colorScheme))

                    Text(verse.translation(for: .english))
                        .font(.poppins(14, weight: .regular))
                        .foregroundColor(.adaptiveSecondaryText(colorScheme))
                        .lineSpacing(6)
                }

                Rectangle()
                    .fill(Color.adaptiveSecondaryText(colorScheme).opacity(0.1))
                    .frame(height: 0.5)

                // Malay
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bahasa Melayu")
                        .font(.poppins(11, weight: .regular))
                        .foregroundColor(.adaptiveSecondaryText(colorScheme))

                    Text(verse.translation(for: .malay))
                        .font(.poppins(14, weight: .regular))
                        .foregroundColor(.adaptiveSecondaryText(colorScheme))
                        .lineSpacing(6)
                }

                // Reference
                if let reference = verse.reference {
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 13))
                            .foregroundColor(.primaryGreen)
                        Text(reference)
                            .font(.poppins(13, weight: .medium))
                            .foregroundColor(.primaryGreen)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)

            // Branding
            HStack(spacing: 8) {
                Image("ShareIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text("MyRuqyah")
                    .font(.poppins(12, weight: .medium))
                    .foregroundColor(.primaryGreen.opacity(0.5))
            }
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(width: 390)
        .background(Color.adaptiveBackground(colorScheme))
    }
}

// MARK: - Render & Share

@MainActor
func shareVerseAsImage(_ verse: RuqyahVerse, colorScheme: ColorScheme) {
    let view = ShareCardView(verse: verse, colorScheme: colorScheme)
    let renderer = ImageRenderer(content: view)
    renderer.scale = UIScreen.main.scale

    guard let image = renderer.uiImage else { return }

    let activityVC = UIActivityViewController(
        activityItems: [image],
        applicationActivities: nil
    )

    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let window = windowScene.windows.first,
       let rootVC = window.rootViewController {
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        rootVC.present(activityVC, animated: true)
    }
}

#Preview {
    ShareCardView(
        verse: RuqyahVerse(
            arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            englishTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            malayTranslation: "Dengan nama Allah, Yang Maha Pemurah, lagi Maha Mengasihani.",
            group: "Surah Al-Fatihah",
            reference: "Al-Fatihah 1:1",
            verseNumber: "١"
        ),
        colorScheme: .light
    )
}
