import SwiftUI

struct GroupDetailView: View {
    let group: VerseGroup

    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showMushafView: Bool = false

    var verses: [RuqyahVerse] {
        contentViewModel.getVersesForGroup(group.collectionId, groupName: group.name)
    }

    /// Whether this group has playable audio (not dhikr/dua without audio files)
    private var groupHasAudio: Bool {
        !AppConstants.noAudioGroups.contains(group.name)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Static Header
            GradientHeader(
                title: group.name,
                subtitle: "\(group.verseCount) verses",
                showBackButton: true
            ) {
                HStack(spacing: AppConstants.spacingMedium) {
                    Button {
                        showMushafView = true
                    } label: {
                        Label("Read", systemImage: "book.fill")
                            .font(.bodySmall)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(AppConstants.radiusSmall)
                    }

                    if groupHasAudio && verses.contains(where: { $0.audioPath != nil || $0.reference != nil }) {
                        Button {
                            playAll()
                        } label: {
                            Label("Listen", systemImage: "play.fill")
                                .font(.bodySmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(AppConstants.radiusSmall)
                        }
                    }
                }
                .padding(.top, 4)
            }

            // Scrollable Verses
            ScrollView {
                LazyVStack(spacing: AppConstants.spacingMedium) {
                    Color.clear.frame(height: 1).id("scrollTop")

                    ForEach(verses) { verse in
                        NavigationLink(destination: VerseDetailView(verse: verse)) {
                            VerseCard(
                                verse: verse,
                                isFavorite: contentViewModel.isFavorite(verse),
                                language: contentViewModel.language,
                                isPlaying: audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying,
                                showPlayButton: groupHasAudio,
                                onFavoriteToggle: {
                                    Task {
                                        await contentViewModel.toggleFavorite(verse)
                                    }
                                },
                                onPlay: {
                                    if audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying {
                                        audioPlayerViewModel.pause()
                                    } else {
                                        audioPlayerViewModel.playSingleVerse(verse)
                                    }
                                },
                                onShare: {
                                    shareVerse(verse)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .bounceOnTap()
                    }

                    // End of list
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.textSecondary.opacity(0.4))
                        Text("You've reached the end")
                            .font(.poppins(12, weight: .regular))
                            .foregroundColor(.textSecondary.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppConstants.spacingMedium)
                    .padding(.bottom, 80)
                    .id("scrollBottom")
                }
                .padding(.horizontal, AppConstants.spacingMedium)
                .padding(.top, AppConstants.spacingMedium)
                .padding(.bottom, AppConstants.spacingXLarge)
            }
            .withScrollButtons()
        }
        .background(Color.adaptiveBackground(colorScheme))
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
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
                    .foregroundColor(.white)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showMushafView) {
            MushafView(verses: verses)
        }
    }

    private func playAll() {
        guard !verses.isEmpty else { return }

        // Enable auto-play for Play All mode
        audioPlayerViewModel.setPlaylist(verses, startIndex: 0, autoPlay: true)
        audioPlayerViewModel.playVerse(verses[0])
    }

    private func shareVerse(_ verse: RuqyahVerse) {
        shareVerseAsImage(verse, colorScheme: colorScheme)
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(group: VerseGroup(
            name: "Surah Al-Fatihah",
            collectionId: "amalan-pendinding-diri",
            sortOrder: 0,
            verseCount: 7
        ))
    }
    .environmentObject(ContentViewModel())
    .environmentObject(AudioPlayerViewModel())
    .environmentObject(SettingsViewModel())
}
