import SwiftUI

/// A continuous reading view that displays all surahs from a collection in mushaf-style format
/// Each surah shows combined Arabic text (like in Quran) followed by translations
/// Supports auto-scroll and verse highlighting during audio playback
struct CollectionMushafView: View {
    let collection: Collection

    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var lastVisibleGroupId: String?
    @State private var hasScrolledToSaved = false

    // Get all groups for this collection
    private var groups: [VerseGroup] {
        contentViewModel.getGroupsForCollection(collection.id)
    }

    // Get all verses for the collection (for audio playback)
    private var allVerses: [RuqyahVerse] {
        contentViewModel.getVersesForCollection(collection.id)
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

                        // Title
                        Text(collection.name)
                            .font(.poppins(16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        // Play All button
                        Button {
                            playAllVerses()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 36, height: 36)

                                Image(systemName: audioPlayerViewModel.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.primaryGreen)
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.spacingMedium)
                    .padding(.vertical, 12)
                    .background(Color.headerGradient)

                    // Scrollable Content - All Surahs in Mushaf Style with ScrollViewReader
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: AppConstants.spacingLarge) {
                                ForEach(groups) { group in
                                    let verses = contentViewModel.getVersesForGroup(group.collectionId, groupName: group.name)

                                    MushafSurahSection(
                                        groupName: group.name,
                                        verses: verses,
                                        colorScheme: colorScheme,
                                        language: contentViewModel.language,
                                        currentPlayingVerse: audioPlayerViewModel.currentVerse,
                                        isPlaying: audioPlayerViewModel.isPlaying,
                                        isBookmarked: contentViewModel.isBookmarked(collectionId: group.collectionId, groupName: group.name),
                                        onBookmarkToggle: {
                                            Task {
                                                await contentViewModel.toggleBookmark(
                                                    collectionId: group.collectionId,
                                                    groupName: group.name,
                                                    collectionName: collection.name,
                                                    groupDisplayName: group.name
                                                )
                                            }
                                        }
                                    )
                                    .id(group.id) // For scrolling to surah
                                    .onAppear {
                                        lastVisibleGroupId = group.id
                                    }
                                }
                            }
                            .padding(.top, AppConstants.spacingMedium)
                            .padding(.bottom, audioPlayerViewModel.showMiniPlayer ? 100 : AppConstants.spacingXLarge)
                        }
                        .withScrollButtons()
                        .onAppear {
                            // Scroll to last read position when resuming
                            if !hasScrolledToSaved,
                               let lastRead = contentViewModel.lastReadInfo,
                               lastRead.collectionId == collection.id,
                               let groupName = lastRead.groupName {
                                let groupId = "\(collection.id)_\(groupName)"
                                hasScrolledToSaved = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(groupId, anchor: .top)
                                    }
                                }
                            }
                        }
                        .onChange(of: audioPlayerViewModel.currentVerse?.id) { _, newVerseId in
                            // Auto-scroll to the current playing verse's group/surah
                            if let currentVerse = audioPlayerViewModel.currentVerse {
                                let groupId = "\(currentVerse.collection ?? "")_\(currentVerse.group)"
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(groupId, anchor: .top)
                                }
                            }
                        }
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
            .onDisappear {
                // Extract group name from the last visible group ID (format: "collectionId_groupName")
                var visibleGroupName: String?
                var visibleGroupDisplayName: String?
                if let groupId = lastVisibleGroupId {
                    let prefix = collection.id + "_"
                    if groupId.hasPrefix(prefix) {
                        visibleGroupName = String(groupId.dropFirst(prefix.count))
                        visibleGroupDisplayName = visibleGroupName
                    }
                }

                // Only save last read if the visible group is bookmarked
                if let gName = visibleGroupName,
                   contentViewModel.isBookmarked(collectionId: collection.id, groupName: gName) {
                    contentViewModel.saveLastRead(
                        collectionId: collection.id,
                        groupName: visibleGroupName,
                        collectionName: collection.name,
                        groupDisplayName: visibleGroupDisplayName ?? collection.name,
                        mode: "collection"
                    )
                }
            }
        }
    }

    // MARK: - Play All Verses
    private func playAllVerses() {
        guard !allVerses.isEmpty else { return }

        if audioPlayerViewModel.isPlaying {
            audioPlayerViewModel.pause()
        } else {
            audioPlayerViewModel.setPlaylist(allVerses, startIndex: 0, autoPlay: true)
            audioPlayerViewModel.playVerse(allVerses[0])
        }
    }
}

// MARK: - Mushaf Surah Section (Each Surah in Mushaf Style)
private struct MushafSurahSection: View {
    let groupName: String
    let verses: [RuqyahVerse]
    let colorScheme: ColorScheme
    let language: Language
    let currentPlayingVerse: RuqyahVerse?
    let isPlaying: Bool
    let isBookmarked: Bool
    let onBookmarkToggle: () -> Void

    /// Check if the first verse is the Bismillah (بسم الله الرحمن الرحيم)
    private var hasBismillah: Bool {
        guard let firstVerse = verses.first else { return false }
        let text = firstVerse.arabicText.trimmingCharacters(in: .whitespacesAndNewlines)
        // Check for Bismillah using Unicode scalars to avoid grapheme cluster issues
        let scalars = Array(text.unicodeScalars)
        // First scalar should be ba (ب U+0628)
        guard scalars.first?.value == 0x0628 else { return false }
        // Should be a short verse (Bismillah only, not a longer verse starting with Bismillah)
        return scalars.count < 80 && text.contains("\u{0631}\u{064E}\u{0651}\u{062D}\u{0650}\u{064A}\u{0645}\u{0650}")
    }

    /// Verses to display in the main mushaf flow (excluding Bismillah if present)
    private var mushafVerses: [RuqyahVerse] {
        hasBismillah ? Array(verses.dropFirst()) : verses
    }

    var body: some View {
        VStack(spacing: AppConstants.spacingMedium) {
            // Surah Title Header with Bookmark
            HStack {
                Spacer()
                Text(groupName)
                    .font(.poppins(20, weight: .bold))
                    .foregroundColor(.primaryGreen)
                Spacer()
                Button {
                    onBookmarkToggle()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primaryGreen)
                }
            }
            .padding(.horizontal, AppConstants.spacingLarge)
            .padding(.vertical, 16)
            .background(Color.primaryGreen.opacity(0.1))
            .cornerRadius(AppConstants.radiusLarge)
            .padding(.horizontal, AppConstants.spacingMedium)

            // Arabic Text Card - Combined Mushaf Style with verse highlighting
            VStack(spacing: 0) {
                // Bismillah centered at top if present
                if hasBismillah, let firstVerse = verses.first {
                    let isCurrentVerse = currentPlayingVerse?.id == firstVerse.id && isPlaying

                    Text(firstVerse.arabicText)
                        .font(.amiriQuran(28))
                        .foregroundColor(isCurrentVerse ? .primaryGreen : Color.adaptiveTextColor(colorScheme))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppConstants.spacingLarge)
                        .padding(.bottom, AppConstants.spacingMedium)
                        .padding(.horizontal, AppConstants.spacingLarge)
                }

                if !mushafVerses.isEmpty {
                    combinedArabicTextWithHighlighting
                        .padding(AppConstants.spacingLarge)
                }
            }
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(AppConstants.radiusLarge)
            .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
            .padding(.horizontal, AppConstants.spacingMedium)

            // Translation Section
            VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
                Text("Translation")
                    .font(.poppins(18, weight: .bold))
                    .foregroundColor(.adaptiveText(colorScheme))
                    .padding(.bottom, 4)

                ForEach(Array(mushafVerses.enumerated()), id: \.element.id) { index, verse in
                    let isCurrentVerse = currentPlayingVerse?.id == verse.id && isPlaying

                    translationRow(verse: verse, index: index + 1, isHighlighted: isCurrentVerse)
                }
            }
            .padding(AppConstants.spacingLarge)
            .background(Color.adaptiveSurface(colorScheme))
            .cornerRadius(AppConstants.radiusLarge)
            .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 3)
            .padding(.horizontal, AppConstants.spacingMedium)
        }
    }

    // MARK: - Combined Arabic Text with Verse Highlighting (Mushaf Style)
    private var combinedArabicTextWithHighlighting: some View {
        // Build attributed string with highlighting for current verse
        let attributedText = buildAttributedText()

        return Text(attributedText)
            .font(.amiriQuran(28))
            .multilineTextAlignment(.trailing)
            .lineSpacing(20)
            .environment(\.layoutDirection, .rightToLeft)
    }

    private func buildAttributedText() -> AttributedString {
        var fullText = AttributedString()
        let versesToRender = mushafVerses

        for (index, verse) in versesToRender.enumerated() {
            let offset = hasBismillah ? index + 2 : index + 1
            let verseNumber = verse.verseNumber ?? toArabicNumeral(offset)
            let isCurrentVerse = currentPlayingVerse?.id == verse.id && isPlaying

            // Verse text - change color to green when playing (contrasts with white bg)
            var verseText = AttributedString(verse.arabicText)
            if isCurrentVerse {
                verseText.foregroundColor = Color.primaryGreen
            } else {
                verseText.foregroundColor = Color.adaptiveTextColor(colorScheme)
            }

            // Verse number
            var verseNumberText = AttributedString(" ﴿\(verseNumber)﴾")
            verseNumberText.foregroundColor = isCurrentVerse ? Color.primaryGreen : Color.primaryGreen.opacity(0.5)

            // Spacing
            var spacing = AttributedString(" ")
            spacing.foregroundColor = Color.adaptiveTextColor(colorScheme)

            fullText.append(verseText)
            fullText.append(verseNumberText)
            if index < versesToRender.count - 1 {
                fullText.append(spacing)
            }
        }

        return fullText
    }

    // MARK: - Translation Row
    private func translationRow(verse: RuqyahVerse, index: Int, isHighlighted: Bool) -> some View {
        HStack(alignment: .top, spacing: AppConstants.spacingMedium) {
            // Arabic numeral in circle
            ZStack {
                Circle()
                    .stroke(Color.primaryGreen, lineWidth: 1.5)
                    .frame(width: 28, height: 28)

                Text(toArabicNumeral(index))
                    .font(.poppins(12, weight: .medium))
                    .foregroundColor(.primaryGreen)
            }

            // Translation text - green color when playing
            VStack(alignment: .leading, spacing: 4) {
                Text(verse.translation(for: language))
                    .font(.poppins(14, weight: .regular))
                    .foregroundColor(isHighlighted ? .primaryGreen : .adaptiveSecondaryText(colorScheme))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                // Reference
                if let reference = verse.reference {
                    Text("(\(reference))")
                        .font(.poppins(12, weight: .medium))
                        .foregroundColor(.primaryGreen.opacity(0.8))
                }
            }
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

// MARK: - Color Extension for AttributedString
extension Color {
    static func adaptiveTextColor(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .black
    }
}

#Preview {
    CollectionMushafView(collection: Collection(
        id: "amalan-pendinding-diri",
        name: "Self-Protection Recitations",
        nameArabic: "أعمال حماية النفس",
        description: "Protection prayers and verses from the Holy Quran for spiritual shielding",
        icon: "shield",
        sortOrder: 1,
        groupCount: 10,
        totalVerseCount: 38
    ))
    .environmentObject(ContentViewModel())
    .environmentObject(SettingsViewModel())
    .environmentObject(AudioPlayerViewModel())
}
