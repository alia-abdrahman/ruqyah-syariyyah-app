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
                        Color.clear.frame(height: 1).id("scrollTop")

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
                    .padding(.top, 32)
                    .padding(.bottom, AppConstants.spacingXLarge)
                }
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
        shareVerseAsImage(verse, colorScheme: colorScheme)
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
