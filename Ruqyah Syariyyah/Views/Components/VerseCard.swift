import SwiftUI

struct VerseCard: View {
    let verse: RuqyahVerse
    let isFavorite: Bool
    let language: Language
    var isPlaying: Bool = false
    var showPlayButton: Bool = true
    var showActions: Bool = true
    var onFavoriteToggle: (() -> Void)?
    var onPlay: (() -> Void)?
    var onShare: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var animatePlay: Bool = false
    @State private var animateHeart: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: AppConstants.spacingMedium) {
            // Arabic Text
            HStack {
                if let reps = verse.recommendedRepetitions {
                    Text("×\(reps)")
                        .font(.poppins(12, weight: .bold))
                        .foregroundColor(.primaryGreen)
                        .frame(width: 35, height: 35)
                        .background(Color.primaryGreen.opacity(0.1))
                        .clipShape(Circle())
                } else if let number = verse.verseNumber {
                    Text(number.arabicToWesternNumerals)
                        .font(.poppins(13, weight: .semibold))
                        .foregroundColor(.primaryGreen)
                        .frame(width: 35, height: 35)
                        .background(Color.primaryGreen.opacity(0.1))
                        .clipShape(Circle())
                }

                Spacer()

                Text(verse.arabicText)
                    .font(.arabicText(size: settingsViewModel.arabicTextSize))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(12)
            }

            Divider()

            // Translation
            VStack(alignment: .leading, spacing: AppConstants.spacingSmall) {
                Text(verse.translation(for: language))
                    .font(.bodyMedium)
                    .foregroundColor(.adaptiveSecondaryText(colorScheme))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let reference = verse.reference {
                    Text(reference)
                        .font(.bodySmall)
                        .foregroundColor(.primaryGreen)
                }
            }

            // Actions
            if showActions {
                HStack(spacing: AppConstants.spacingMedium) {
                    Spacer()

                    // Show play button if allowed and verse has local audio or reference (for API audio)
                    if showPlayButton && (verse.audioPath != nil || verse.reference != nil) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                animatePlay = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    animatePlay = false
                                }
                            }
                            onPlay?()
                        } label: {
                            ZStack {
                                // Pulse animation ring when playing
                                if isPlaying {
                                    Circle()
                                        .stroke(Color.primaryGreen.opacity(0.3), lineWidth: 2)
                                        .frame(width: 32, height: 32)
                                        .scaleEffect(animatePlay ? 1.3 : 1.0)
                                        .opacity(animatePlay ? 0 : 0.5)
                                        .animation(
                                            .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                                            value: isPlaying
                                        )
                                }

                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.primaryGreen)
                                    .scaleEffect(animatePlay ? 0.85 : 1.0)
                            }
                        }
                    }

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            animateHeart = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                animateHeart = false
                            }
                        }
                        onFavoriteToggle?()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(isFavorite ? .red : .textSecondary)
                            .scaleEffect(animateHeart ? 1.3 : 1.0)
                    }

                    Button {
                        onShare?()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusLarge)
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
    }
}

// MARK: - Compact Verse Card
struct CompactVerseCard: View {
    let verse: RuqyahVerse
    let isFavorite: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.spacingMedium) {
            if let number = verse.verseNumber {
                Text(number.arabicToWesternNumerals)
                    .font(.poppins(11, weight: .semibold))
                    .foregroundColor(.primaryGreen)
                    .frame(width: 30, height: 30)
                    .background(Color.primaryGreen.opacity(0.1))
                    .clipShape(Circle())
            }

            VStack(alignment: .trailing, spacing: AppConstants.spacingSmall) {
                Text(verse.arabicText)
                    .font(.amiriQuran(20))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                if let reference = verse.reference {
                    Text(reference)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            if isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusMedium)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            VerseCard(
                verse: RuqyahVerse(
                    arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
                    englishTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
                    malayTranslation: "Dengan nama Allah, Yang Maha Pemurah, lagi Maha Mengasihani.",
                    group: "Surah Al-Fatihah",
                    reference: "Al-Fatihah 1:1",
                    verseNumber: "١"
                ),
                isFavorite: true,
                language: .english
            )

            CompactVerseCard(
                verse: RuqyahVerse(
                    arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ",
                    englishTranslation: "[All] praise is [due] to Allah, Lord of the worlds",
                    malayTranslation: "Segala puji tertentu bagi Allah",
                    group: "Surah Al-Fatihah",
                    reference: "Al-Fatihah 1:2",
                    verseNumber: "٢"
                ),
                isFavorite: false
            )
        }
        .padding()
    }
    .environmentObject(SettingsViewModel())
}
