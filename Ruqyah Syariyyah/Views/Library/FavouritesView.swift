import SwiftUI

struct FavouritesView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var audioPlayerViewModel: AudioPlayerViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var favorites: [RuqyahVerse] {
        contentViewModel.favoriteVerses
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            GradientHeader(
                title: "Favourites",
                subtitle: "\(favorites.count) saved verses",
                showBackButton: true
            )

            // Content
            ScrollView {
                if favorites.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: AppConstants.spacingMedium) {
                        ForEach(favorites) { verse in
                            NavigationLink(destination: VerseDetailView(verse: verse)) {
                                VerseCard(
                                    verse: verse,
                                    isFavorite: true,
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
                    .padding(.top, 32)
                    .padding(.bottom, AppConstants.spacingXLarge)
                }
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
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppConstants.spacingMedium) {
            Spacer()
                .frame(height: 60)

            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "heart")
                    .font(.system(size: 40))
                    .foregroundColor(.primaryGreen)
            }

            Text("No Favourites Yet")
                .font(.poppins(20, weight: .semibold))
                .foregroundColor(.adaptiveText(colorScheme))

            Text("Tap the heart icon on any verse\nto add it to your favourites")
                .font(.poppins(14, weight: .regular))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppConstants.spacingLarge)
    }

    // MARK: - Actions
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
        FavouritesView()
    }
    .environmentObject(ContentViewModel())
    .environmentObject(AudioPlayerViewModel())
    .environmentObject(SettingsViewModel())
}
