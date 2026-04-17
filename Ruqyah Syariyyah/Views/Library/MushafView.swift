import SwiftUI

struct MushafView: View {
    let verses: [RuqyahVerse]

    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // Get group name from first verse
    private var groupName: String {
        verses.first?.group ?? "Verses"
    }

    /// Check if the first verse is the Bismillah
    private var hasBismillah: Bool {
        guard let firstVerse = verses.first else { return false }
        let text = firstVerse.arabicText.trimmingCharacters(in: .whitespacesAndNewlines)
        let scalars = Array(text.unicodeScalars)
        // First scalar should be ba (ب U+0628), and short enough to be just Bismillah
        guard scalars.first?.value == 0x0628, scalars.count < 80 else { return false }
        return text.contains("\u{0631}\u{064E}\u{0651}\u{062D}\u{0650}\u{064A}\u{0645}\u{0650}")
    }

    /// Verses to display in the main mushaf flow (excluding Bismillah if present)
    private var mushafVerses: [RuqyahVerse] {
        hasBismillah ? Array(verses.dropFirst()) : verses
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Green Header Bar with Icons
                    HStack {
                        // Close button
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        // List icon - return to verse-by-verse view
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }

                        Spacer()
                            .frame(width: 20)

                        // Play button
                        Button {
                            playAllVerses()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 36, height: 36)

                                Image(systemName: "play.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primaryGreen)
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.spacingMedium)
                    .padding(.vertical, 12)
                    .background(Color.primaryGreen)

                    ScrollView {
                        VStack(spacing: AppConstants.spacingMedium) {
                            // Title Card
                            Text(groupName)
                                .font(.poppins(22, weight: .semibold))
                                .foregroundColor(.primaryGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.adaptiveSurface(colorScheme))
                                .cornerRadius(AppConstants.radiusLarge)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .padding(.horizontal, AppConstants.spacingMedium)

                            // Arabic Text Card - All verses combined
                            VStack(spacing: 0) {
                                // Bismillah centered at top if present
                                if hasBismillah, let firstVerse = verses.first {
                                    Text(firstVerse.arabicText)
                                        .font(.amiriQuran(26))
                                        .foregroundColor(.adaptiveText(colorScheme))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, AppConstants.spacingLarge)
                                        .padding(.bottom, AppConstants.spacingMedium)
                                        .padding(.horizontal, AppConstants.spacingLarge)
                                }

                                // Remaining verses in mushaf style
                                if !mushafVerses.isEmpty {
                                    combinedArabicText
                                        .padding(AppConstants.spacingLarge)
                                }
                            }
                            .background(Color.adaptiveSurface(colorScheme))
                            .cornerRadius(AppConstants.radiusLarge)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, AppConstants.spacingMedium)

                            // Translation Section
                            VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
                                Text("Translation")
                                    .font(.poppins(20, weight: .bold))
                                    .foregroundColor(.adaptiveText(colorScheme))
                                    .padding(.bottom, 4)

                                ForEach(Array(mushafVerses.enumerated()), id: \.element.id) { index, verse in
                                    translationRow(verse: verse, index: index + 1)
                                }
                            }
                            .padding(AppConstants.spacingLarge)
                            .background(Color.adaptiveSurface(colorScheme))
                            .cornerRadius(AppConstants.radiusLarge)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.bottom, audioPlayerViewModel.showMiniPlayer ? 80 : AppConstants.spacingXLarge)
                        }
                        .padding(.top, AppConstants.spacingMedium)
                    }
                }

                // Mini Player overlay at bottom
                if audioPlayerViewModel.showMiniPlayer {
                    MiniPlayerView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color.adaptiveBackground(colorScheme))
            .navigationBarHidden(true)
            .animation(.easeInOut(duration: 0.25), value: audioPlayerViewModel.showMiniPlayer)
        }
    }

    // MARK: - Play All Verses
    private func playAllVerses() {
        guard !verses.isEmpty else { return }
        // Enable auto-play for Play All mode
        audioPlayerViewModel.setPlaylist(verses, startIndex: 0, autoPlay: true)
        audioPlayerViewModel.playVerse(verses[0])
    }

    // MARK: - Combined Arabic Text with Verse Numbers
    private var combinedArabicText: some View {
        // Build attributed text with verse numbers (excluding Bismillah if separated)
        let combinedText = mushafVerses.enumerated().map { index, verse in
            let offset = hasBismillah ? index + 2 : index + 1
            let verseNumber = verse.verseNumber ?? toArabicNumeral(offset)
            return "\(verse.arabicText) ﴿\(verseNumber)﴾"
        }.joined(separator: " ")

        return Text(combinedText)
            .font(.amiriQuran(26))
            .foregroundColor(.adaptiveText(colorScheme))
            .multilineTextAlignment(.trailing)
            .lineSpacing(20)
            .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Translation Row
    private func translationRow(verse: RuqyahVerse, index: Int) -> some View {
        HStack(alignment: .top, spacing: AppConstants.spacingMedium) {
            // Arabic numeral in green circle
            ZStack {
                Circle()
                    .stroke(Color.primaryGreen, lineWidth: 1.5)
                    .frame(width: 32, height: 32)

                Text(toArabicNumeral(index))
                    .font(.poppins(14, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }

            // Translation text
            Text(verse.translation(for: contentViewModel.language))
                .font(.poppins(15, weight: .regular))
                .foregroundColor(.adaptiveSecondaryText(colorScheme))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Helper: Convert to Arabic Numerals
    private func toArabicNumeral(_ number: Int) -> String {
        let arabicNumerals = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
        var result = ""
        var num = number

        if num == 0 {
            return arabicNumerals[0]
        }

        while num > 0 {
            let digit = num % 10
            result = arabicNumerals[digit] + result
            num /= 10
        }

        return result
    }
}

#Preview {
    MushafView(verses: [
        RuqyahVerse(
            arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            englishTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            malayTranslation: "Dengan nama Allah, Yang Maha Pemurah.",
            group: "Surah Al-Fatihah",
            reference: "Al-Fatihah 1:1",
            verseNumber: "١"
        ),
        RuqyahVerse(
            arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ",
            englishTranslation: "[All] praise is [due] to Allah, Lord of the worlds -",
            malayTranslation: "Segala puji tertentu bagi Allah.",
            group: "Surah Al-Fatihah",
            reference: "Al-Fatihah 1:2",
            verseNumber: "٢"
        ),
        RuqyahVerse(
            arabicText: "ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            englishTranslation: "The Entirely Merciful, the Especially Merciful,",
            malayTranslation: "Yang Maha Pemurah, lagi Maha Mengasihani.",
            group: "Surah Al-Fatihah",
            reference: "Al-Fatihah 1:3",
            verseNumber: "٣"
        ),
        RuqyahVerse(
            arabicText: "مَـٰلِكِ يَوْمِ ٱلدِّينِ",
            englishTranslation: "Sovereign of the Day of Recompense.",
            malayTranslation: "Yang Menguasai hari pembalasan.",
            group: "Surah Al-Fatihah",
            reference: "Al-Fatihah 1:4",
            verseNumber: "٤"
        )
    ])
    .environmentObject(ContentViewModel())
    .environmentObject(SettingsViewModel())
    .environmentObject(AudioPlayerViewModel())
}
