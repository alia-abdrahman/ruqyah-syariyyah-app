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

                    // Show Play button if verses have audio (local or API via reference)
                    if verses.contains(where: { $0.audioPath != nil || $0.reference != nil }) {
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
                .padding(.top, AppConstants.spacingSmall)
            }
            .frame(height: 200)

            // Scrollable Verses
            ScrollView {
                LazyVStack(spacing: AppConstants.spacingMedium) {
                    ForEach(verses) { verse in
                        NavigationLink(destination: VerseDetailView(verse: verse)) {
                            VerseCard(
                                verse: verse,
                                isFavorite: contentViewModel.isFavorite(verse),
                                language: contentViewModel.language,
                                isPlaying: audioPlayerViewModel.currentVerse?.id == verse.id && audioPlayerViewModel.isPlaying,
                                onFavoriteToggle: {
                                    Task {
                                        await contentViewModel.toggleFavorite(verse)
                                    }
                                },
                                onPlay: {
                                    // Toggle play/pause for this verse
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
                    }
                }
                .padding(.horizontal, AppConstants.spacingMedium)
                .padding(.top, AppConstants.spacingMedium)
                .padding(.bottom, AppConstants.spacingMedium)
            }
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
