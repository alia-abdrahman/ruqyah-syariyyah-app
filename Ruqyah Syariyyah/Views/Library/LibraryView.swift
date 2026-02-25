import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var searchText: String = ""
    @State private var showFavorites: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: AppConstants.spacingMedium),
        GridItem(.flexible(), spacing: AppConstants.spacingMedium)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    GradientHeader(
                        title: "Library",
                        subtitle: "Your spiritual healing collection"
                    ) {
                        SearchBar(text: $searchText, placeholder: "Search verses...")
                            .padding(.top, 8)
                    }
                    .frame(height: 220)

                    VStack(spacing: AppConstants.spacingMedium) {
                        // Welcome Banner
                        welcomeBanner
                            .padding(.horizontal, AppConstants.spacingMedium)

                        // Favorites Toggle
                        HStack {
                            Text("Collections")
                                .font(.headingSmall)
                                .foregroundColor(.adaptiveText(colorScheme))

                            Spacer()

                            Button {
                                showFavorites.toggle()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: showFavorites ? "heart.fill" : "heart")
                                    Text("Favorites")
                                }
                                .font(.bodySmall)
                                .foregroundColor(showFavorites ? .red : .textSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(showFavorites ? Color.red.opacity(0.1) : Color.clear)
                                .cornerRadius(AppConstants.radiusSmall)
                            }
                        }
                        .padding(.horizontal, AppConstants.spacingMedium)

                        if contentViewModel.isLoading {
                            ProgressView()
                                .frame(height: 200)
                        } else if showFavorites {
                            favoritesSection
                        } else if !searchText.isEmpty {
                            searchResultsSection
                        } else {
                            collectionsGrid
                        }
                    }
                    .padding(.top, AppConstants.spacingMedium)
                }
            }
            .background(Color.adaptiveBackground(colorScheme))
            .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Welcome Banner
    private var welcomeBanner: some View {
        HStack(spacing: 16) {
            Text("Begin your Islamic spiritual healing by recitations of holy verses of the Quran.")
                .font(.poppins(16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 70, height: 70)

                Image(systemName: "book.fill")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.primaryGreen, Color.primaryGreenDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    // MARK: - Collections Grid
    private var collectionsGrid: some View {
        LazyVGrid(columns: columns, spacing: AppConstants.spacingMedium) {
            ForEach(contentViewModel.collections) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection)) {
                    CollectionCard(collection: collection)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppConstants.spacingMedium)
        .padding(.bottom, AppConstants.spacingXLarge)
    }

    // MARK: - Search Results
    private var searchResultsSection: some View {
        let results = contentViewModel.searchVerses(searchText)

        return VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
            Text("\(results.count) results")
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, AppConstants.spacingMedium)

            if results.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search term")
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: AppConstants.spacingMedium) {
                    ForEach(results) { verse in
                        NavigationLink(destination: VerseDetailView(verse: verse)) {
                            CompactVerseCard(
                                verse: verse,
                                isFavorite: contentViewModel.isFavorite(verse)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppConstants.spacingMedium)
            }
        }
        .padding(.bottom, AppConstants.spacingXLarge)
    }

    // MARK: - Favorites Section
    private var favoritesSection: some View {
        let favorites = contentViewModel.favoriteVerses

        return VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
            if favorites.isEmpty {
                ContentUnavailableView(
                    "No Favorites",
                    systemImage: "heart",
                    description: Text("Tap the heart icon on any verse to add it to favorites")
                )
                .frame(height: 200)
            } else {
                Text("\(favorites.count) favorites")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, AppConstants.spacingMedium)

                LazyVStack(spacing: AppConstants.spacingMedium) {
                    ForEach(favorites) { verse in
                        NavigationLink(destination: VerseDetailView(verse: verse)) {
                            CompactVerseCard(
                                verse: verse,
                                isFavorite: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppConstants.spacingMedium)
            }
        }
        .padding(.bottom, AppConstants.spacingXLarge)
    }
}

#Preview {
    LibraryView()
        .environmentObject(ContentViewModel())
        .environmentObject(SettingsViewModel())
}
