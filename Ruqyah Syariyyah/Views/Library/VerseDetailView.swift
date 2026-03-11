import SwiftUI

struct VerseDetailView: View {
    let verse: RuqyahVerse

    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var isCopied: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.spacingLarge) {
                // Arabic Text Card
                VStack(spacing: AppConstants.spacingMedium) {
                    if let number = verse.verseNumber {
                        Text(number.arabicToWesternNumerals)
                            .font(.poppins(16, weight: .semibold))
                            .foregroundColor(.primaryGreen)
                            .frame(width: 45, height: 45)
                            .background(Color.primaryGreen.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Text(verse.arabicText)
                        .font(.arabicText(size: settingsViewModel.arabicTextSize))
                        .foregroundColor(.adaptiveText(colorScheme))
                        .multilineTextAlignment(.center)
                        .lineSpacing(16)
                        .padding(.horizontal)
                }
                .padding(.vertical, AppConstants.spacingLarge)
                .frame(maxWidth: .infinity)
                .background(Color.adaptiveSurface(colorScheme))
                .cornerRadius(AppConstants.radiusLarge)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                // Translation Card
                VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
                    // Language Toggle
                    HStack {
                        Text("Translation")
                            .font(.headingSmall)
                            .foregroundColor(.adaptiveText(colorScheme))

                        Spacer()

                        Picker("Language", selection: Binding(
                            get: { contentViewModel.language },
                            set: { contentViewModel.setLanguage($0) }
                        )) {
                            ForEach(Language.allCases, id: \.self) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }

                    Divider()

                    Text(verse.translation(for: contentViewModel.language))
                        .font(.bodyLarge)
                        .foregroundColor(.adaptiveSecondaryText(colorScheme))
                        .lineSpacing(8)

                    if let reference = verse.reference {
                        HStack {
                            Image(systemName: "book.closed")
                                .foregroundColor(.primaryGreen)
                            Text(reference)
                                .font(.bodyMedium)
                                .foregroundColor(.primaryGreen)
                        }
                    }
                }
                .padding(AppConstants.spacingMedium)
                .background(Color.adaptiveSurface(colorScheme))
                .cornerRadius(AppConstants.radiusLarge)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                // Actions
                HStack(spacing: AppConstants.spacingMedium) {
                    // Favorite
                    ActionButton(
                        icon: contentViewModel.isFavorite(verse) ? "heart.fill" : "heart",
                        title: "Favorite",
                        color: contentViewModel.isFavorite(verse) ? .red : .textSecondary
                    ) {
                        Task {
                            await contentViewModel.toggleFavorite(verse)
                        }
                    }

                    // Copy
                    ActionButton(
                        icon: isCopied ? "checkmark" : "doc.on.doc",
                        title: isCopied ? "Copied" : "Copy",
                        color: isCopied ? .primaryGreen : .textSecondary
                    ) {
                        copyToClipboard()
                    }

                    // Share
                    ActionButton(
                        icon: "square.and.arrow.up",
                        title: "Share",
                        color: .textSecondary
                    ) {
                        shareVerse()
                    }

                    // Play (for local audio or API audio via reference)
                    if verse.audioPath != nil || verse.reference != nil {
                        ActionButton(
                            icon: audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying ? "pause.fill" : "play.fill",
                            title: audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying ? "Pause" : "Play",
                            color: .primaryGreen
                        ) {
                            if audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying {
                                audioPlayerViewModel.pause()
                            } else {
                                audioPlayerViewModel.playSingleVerse(verse)
                            }
                        }
                    }
                }
            }
            .padding(AppConstants.spacingMedium)
        }
        .background(Color.adaptiveBackground(colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(verse.group)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                            .font(.poppins(16, weight: .regular))
                    }
                    .foregroundColor(.primaryGreen)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shareVerse()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func copyToClipboard() {
        let text = """
        \(verse.arabicText)

        \(verse.translation(for: contentViewModel.language))

        \(verse.reference ?? "")
        """

        UIPasteboard.general.string = text
        isCopied = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }

    private func shareVerse() {
        let text = """
        \(verse.arabicText)

        \(verse.translation(for: contentViewModel.language))

        \(verse.reference ?? "")

        - Ruqyah Syar'iyyah App
        """

        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let title: String
    var color: Color = .textSecondary
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppConstants.spacingMedium)
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(AppConstants.radiusMedium)
        }
    }
}

#Preview {
    NavigationStack {
        VerseDetailView(verse: RuqyahVerse(
            arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ",
            englishTranslation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
            malayTranslation: "Dengan nama Allah, Yang Maha Pemurah, lagi Maha Mengasihani.",
            group: "Surah Al-Fatihah",
            reference: "Al-Fatihah 1:1",
            audioPath: "audio.mp3",
            verseNumber: "١"
        ))
    }
    .environmentObject(ContentViewModel())
    .environmentObject(AudioPlayerViewModel())
    .environmentObject(SettingsViewModel())
}
