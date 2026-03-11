import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var searchText: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: AppConstants.spacingMedium),
        GridItem(.flexible(), spacing: AppConstants.spacingMedium)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Header with Favourites Button
                GradientHeader(
                    title: "Library",
                    subtitle: "Your spiritual healing collection",
                    trailingContent: {
                        NavigationLink(destination: FavouritesView()) {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Favourites")
                                    .font(.poppins(13, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                )

                // Scrollable Content
                ScrollView {
                    VStack(spacing: AppConstants.spacingMedium) {
                        // Search Bar
                        SearchBar(text: $searchText, placeholder: "Search verses...")
                            .padding(.horizontal, AppConstants.spacingMedium)

                        // Welcome Banner
                        welcomeBanner
                            .padding(.horizontal, AppConstants.spacingMedium)

                        // Collections Header
                        if searchText.isEmpty {
                            Text("Collections")
                                .font(.headingSmall)
                                .foregroundColor(.adaptiveText(colorScheme))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, AppConstants.spacingMedium)
                        }

                        if contentViewModel.isLoading {
                            ProgressView()
                                .frame(height: 200)
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
        let results = contentViewModel.searchAll(searchText)

        return VStack(alignment: .leading, spacing: AppConstants.spacingMedium) {
            Text("\(results.totalCount) results")
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
                    // Collections Results
                    if !results.collections.isEmpty {
                        Text("Collections")
                            .font(.poppins(14, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, AppConstants.spacingMedium)

                        ForEach(results.collections) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection)) {
                                SearchCollectionRow(collection: collection)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Groups/Surahs Results
                    if !results.groups.isEmpty {
                        Text("Surahs")
                            .font(.poppins(14, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, results.collections.isEmpty ? 0 : AppConstants.spacingSmall)

                        ForEach(results.groups, id: \.group.id) { item in
                            NavigationLink(destination: GroupDetailView(group: item.group)) {
                                SearchGroupRow(group: item.group, collectionName: item.collection.name)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Verses Results
                    if !results.verses.isEmpty {
                        Text("Verses")
                            .font(.poppins(14, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, AppConstants.spacingMedium)
                            .padding(.top, (results.collections.isEmpty && results.groups.isEmpty) ? 0 : AppConstants.spacingSmall)

                        ForEach(results.verses) { verse in
                            NavigationLink(destination: VerseDetailView(verse: verse)) {
                                CompactVerseCard(
                                    verse: verse,
                                    isFavorite: contentViewModel.isFavorite(verse)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, AppConstants.spacingMedium)
            }
        }
        .padding(.bottom, AppConstants.spacingXLarge)
    }

}

// MARK: - Search Collection Row
struct SearchCollectionRow: View {
    let collection: Collection
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: collection.sfSymbol)
                    .font(.system(size: 18))
                    .foregroundColor(.primaryGreen)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(collection.name)
                    .font(.poppins(15, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))

                HStack(spacing: AppConstants.spacingSmall) {
                    Label("\(collection.groupCount) groups", systemImage: "folder")
                    Label("\(collection.totalVerseCount) verses", systemImage: "text.quote")
                }
                .font(.poppins(12, weight: .regular))
                .foregroundColor(.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusMedium)
    }
}

// MARK: - Search Group Row
struct SearchGroupRow: View {
    let group: VerseGroup
    let collectionName: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: AppConstants.spacingMedium) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primaryGreen)
                    .frame(width: 44, height: 44)

                Image(systemName: "book.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(.poppins(15, weight: .semibold))
                    .foregroundColor(.adaptiveText(colorScheme))

                Text("\(collectionName) • \(group.verseCount) verses")
                    .font(.poppins(12, weight: .regular))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Arabic preview
            if let preview = group.arabicPreview {
                Text(preview)
                    .font(.amiriQuran(14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: 80, alignment: .trailing)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(AppConstants.spacingMedium)
        .background(Color.adaptiveSurface(colorScheme))
        .cornerRadius(AppConstants.radiusMedium)
    }
}

#Preview {
    LibraryView()
        .environmentObject(ContentViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(AudioPlayerViewModel())
}
