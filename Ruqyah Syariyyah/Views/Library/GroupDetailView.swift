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
        ScrollView {
            VStack(spacing: 0) {
                // Header
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

                        if verses.contains(where: { $0.audioPath != nil }) {
                            Button {
                                playAll()
                            } label: {
                                Label("Play All", systemImage: "play.fill")
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

                // Verses
                LazyVStack(spacing: AppConstants.spacingMedium) {
                    ForEach(verses) { verse in
                        NavigationLink(destination: VerseDetailView(verse: verse)) {
                            VerseCard(
                                verse: verse,
                                isFavorite: contentViewModel.isFavorite(verse),
                                language: contentViewModel.language,
                                onFavoriteToggle: {
                                    Task {
                                        await contentViewModel.toggleFavorite(verse)
                                    }
                                },
                                onPlay: {
                                    audioPlayerViewModel.setPlaylist(verses, startIndex: verses.firstIndex(of: verse) ?? 0)
                                    audioPlayerViewModel.playVerse(verse)
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
                .padding(.top, AppConstants.spacingLarge)
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
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showMushafView) {
            MushafView(verses: verses)
        }
    }

    private func playAll() {
        let playableVerses = verses.filter { $0.audioPath != nil }
        guard !playableVerses.isEmpty else { return }

        audioPlayerViewModel.setPlaylist(playableVerses, startIndex: 0)
        audioPlayerViewModel.playVerse(playableVerses[0])
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
